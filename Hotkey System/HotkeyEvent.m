//
//  HotkeyEvent.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "HotkeyEvent.h"
#import "AtlantisState.h"
#import "BaseAction.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisSpawn.h"

#import "PTKeyComboPanel.h"
#import "PTHotKeyCenter.h"

@class HotkeyCollection;

@implementation HotkeyEvent

#pragma Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdGlobal = NO;
        _rdKeyCombo = nil;
        _rdKey = nil;
    }
    return self;
}

- (id) initWithActions:(NSArray *) actions forKey:(PTKeyCombo *)key global:(BOOL) global
{
    self = [self init];
    if (self) {
        _rdGlobal = global;
        _rdKeyCombo = [key retain];
        _rdEnabled = YES;
        [_rdActions addObjectsFromArray:actions];
        
        if (_rdGlobal)
            [self registerKeyBinding];
    }
    return self;
}


- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdGlobal = [coder decodeBoolForKey:@"hotkey.global"];
        _rdKey = nil;
        
        id keyTemp = [coder decodeObjectForKey:@"hotkey.key"];
        
        _rdKeyCombo = [[PTKeyCombo alloc] initWithPlistRepresentation:keyTemp];
        
        if (_rdGlobal) {
            [self registerKeyBinding];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    [coder encodeBool:_rdGlobal forKey:@"hotkey.global"];
    [coder encodeObject:[_rdKeyCombo plistRepresentation] forKey:@"hotkey.key"];
}

- (void) dealloc
{
    [self unregisterKeyBinding];
    [_rdKey release];
    [_rdKeyCombo release];
    [super dealloc];
}

#pragma Hotkey Implementation

- (PTKeyCombo *) keyCombo
{
    return _rdKeyCombo;
}

- (void) setKeyCombo:(PTKeyCombo *) key
{
    [self unregisterKeyBinding];
    [_rdKeyCombo release];
    _rdKeyCombo = [key retain];
    
    if (_rdGlobal && _rdEnabled) {
        [self registerKeyBinding];
    }
}

- (BOOL) isGlobal
{
    return _rdGlobal;
}

- (void) execute:(id) sender
{
    if (![NSApp isActive] && _rdGlobal) {
        [NSApp activateIgnoringOtherApps:YES];
    }
    
    [self executeWithCause:@"hotkey" subCause:nil];
}

- (void) registerKeyBinding
{
    if (_rdKey || !_rdGlobal)
        return;
        
    _rdKey = [[PTHotKey alloc] initWithIdentifier:self keyCombo:_rdKeyCombo];
    [_rdKey setTarget:self];
    [_rdKey setAction:@selector(execute:)];
    [[PTHotKeyCenter sharedCenter] registerHotKey:_rdKey];
}

- (void) unregisterKeyBinding
{
    if (!_rdKey || !_rdGlobal)
        return;
        
    [[PTHotKeyCenter sharedCenter] unregisterHotKey:_rdKey];
    [_rdKey release];
    _rdKey = nil;
}


#pragma Event System Protocol

- (NSString *) eventName
{
    return [_rdKeyCombo description];
}

- (NSString *) eventDescription
{
    int count = [_rdActions count];
    
    if (count == 1) {
        id <EventActionProtocol> action = [_rdActions objectAtIndex:0];
        return [action actionDescription];
    }
    else if (count == 0) {
        // TODO: Localize
        return @"<< No Actions Set >>";
    }
    else {
        // TODO: Localize
        NSMutableString *result = [[NSMutableString alloc] init];
        
        NSEnumerator *actionEnumerator = [_rdActions objectEnumerator];
        
        id <EventActionProtocol> actionWalk;
        
        while (actionWalk = [actionEnumerator nextObject]) {
            if ([result length]) {
                if ([result characterAtIndex:[result length] - 1] == '.') {
                    [result replaceCharactersInRange:NSMakeRange([result length] - 1, 1) withString:@", then "];
                }
                else {
                    [result appendString:@", then "];
                }
            }
            [result appendString:[actionWalk actionDescription]];
        }
        
        return result;
    }
}

- (void) eventSetEnabled:(BOOL) enabled
{
    [super eventSetEnabled:enabled];
    
    if ([self eventIsEnabled] && [self isGlobal]) {
        [self registerKeyBinding];
    }
    else {
        [self unregisterKeyBinding];
    }
}

- (BOOL) eventCanEditName
{
    return NO;
}

- (BOOL) eventCanEditNameSpecial
{
    return YES;
}

- (void) hotKeySheetDidEndWithReturnCode: (NSNumber *) returnCode
{
    if ([returnCode intValue] == NSOKButton) {
        PTKeyCombo *key = [[PTKeyComboPanel sharedPanel] keyCombo];

        [self setKeyCombo:key];
        if (![key isValidHotKeyCombo]) {
            [self eventSetEnabled:NO];
        } 
    }
}

- (void) eventEditNameHook
{
    PTKeyCombo *key = [self keyCombo];

    PTKeyComboPanel *panel = [PTKeyComboPanel sharedPanel];
    [panel setKeyCombo:key];
    [panel setKeyBindingName:@"Atlantis Hotkey Binding"];
    [panel runSheeetForModalWindow:[NSApp keyWindow] target:self];    
}

- (void) eventSetName:(NSString *) name
{
    // Override to Do Nothing
}

- (BOOL) eventCanEditDescription
{
    return NO;
}

- (void) eventSetDescription:(NSString *) desc
{
    // Override to Do Nothing
}

- (BOOL) eventSupportsConditions
{
    return NO;
}

- (NSArray *) eventConditions
{
    return nil;
}

- (BOOL) eventConditionsAnded
{
    return NO;
}

- (void) eventSetConditionsAnded:(BOOL) anded
{
    // Do Nothing
}

- (void) eventAddCondition:(id <EventConditionProtocol>) condition
{
    // Do Nothing
}

- (void) eventRemoveCondition:(id <EventConditionProtocol>) condition
{
    // Do Nothing
}

- (id) eventExtraData:(NSString *) dataName
{
    if ([dataName isEqualToString:@"eventGlobal"])
        return [NSNumber numberWithBool:_rdGlobal];
        
    return nil;
}

- (void) eventSetExtraData:(id) data forName:(NSString *) dataName
{
    if ([dataName isEqualToString:@"eventGlobal"]) {
        _rdGlobal = [(NSNumber *) data boolValue];
        
        if (_rdEnabled) {
            if (_rdGlobal) {
                [self registerKeyBinding];
            }
            else {
                [self unregisterKeyBinding];
            }
        }        
    }
}

@end
