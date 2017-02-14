//
//  Action-SetTempVar.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/15/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-SetTempVar.h"
#import "RDAtlantisMainController.h"
#import "AtlantisState.h"
#import "NSStringExtensions.h"
#import "RDAtlantisWorldInstance.h"

@implementation Action_SetTempVar

- (id) init
{
    self = [super init];
    if (self) {
        _rdVariableName = nil;
        _rdVariableValue = nil;
        _rdVariableType = nil;
    }
    return self;
}

- (void) dealloc
{
    [_rdVariableType release];
    [_rdVariableName release];
    [_rdVariableValue release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdVariableName = [[coder decodeObjectForKey:@"action.variableName"] retain];
        _rdVariableValue = [[coder decodeObjectForKey:@"action.variableValue"] retain];
        _rdVariableType = [[coder decodeObjectForKey:@"action.variableType"] retain];
        
        if (!_rdVariableType) {
            _rdVariableType = [[NSNumber numberWithUnsignedInt:0] retain];
        }
        
        if (!_rdVariableValue) {
            _rdVariableValue = [[NSString string] retain];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder;
{
    [super encodeWithCoder:coder];
    if (_rdVariableType)
        [coder encodeObject:_rdVariableType forKey:@"action.variableType"];
    if (_rdVariableName)
        [coder encodeObject:_rdVariableName forKey:@"action.variableName"];
    if (_rdVariableValue)
        [coder encodeObject:_rdVariableValue forKey:@"action.variableValue"];
}


#pragma mark Action Implementation

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Script: Set variable.";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Set a scripting variable to a given value.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    return [NSNumber numberWithBool:YES];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSString *newValue = [_rdVariableValue expandWithDataIn:[state data]];  

    int variableType = [_rdVariableType intValue];
    
    switch (variableType) {
        case 0:
            [[RDAtlantisMainController controller] setStateVar:newValue forKey:_rdVariableName];
            break;
            
        case 1:
            [[state world] setInfo:newValue forBaseStateKey:[NSString stringWithFormat:@"worldtemp.%@", _rdVariableName]];
            break;
            
        case 2:
            {
                [[state world] setInfo:newValue forBaseStateKey:[NSString stringWithFormat:@"userconf.%@", _rdVariableName]];
                NSMutableDictionary *userconf = [[[[state world] preferences] preferenceForKey:@"atlantis.userconf" withCharacter:[[state world] character] fallback:NO] mutableCopy];
                if (!userconf) {
                    userconf = [[[NSMutableDictionary alloc] init] retain];
                }
                [userconf setObject:newValue forKey:_rdVariableName];
                [[[state world] preferences] setPreference:[NSDictionary dictionaryWithDictionary:userconf] forKey:@"atlantis.userconf" withCharacter:[[state world] character]];
                [userconf release];
            }
            break;
    }
    
    return NO;
}

#pragma mark Configuration Glue


- (void) variableTypeChanged:(id) sender
{
    [_rdVariableType release];
    _rdVariableType = [[NSNumber numberWithInt:[_rdVariableTypeField indexOfSelectedItem]] retain];
}


- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_SetTempVar" owner:self];
    }
    
    [_rdVariableNameField setDelegate:self];
    [_rdVariableValueField setDelegate:self];
    
    [_rdVariableTypeField setTarget:self];
    [_rdVariableTypeField setAction:@selector(variableTypeChanged:)];
    
    if (_rdVariableName)
        [_rdVariableNameField setStringValue:_rdVariableName];
    else
        [_rdVariableNameField setStringValue:@""];
        
    if (_rdVariableValue)
        [_rdVariableValueField setStringValue:_rdVariableValue];
    else
        [_rdVariableValueField setStringValue:@""];
        
    [_rdVariableTypeField selectItemAtIndex:[_rdVariableType intValue]];
    
    return _rdInternalConfigurationView;
}

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    if ([notification object] == _rdVariableNameField) {
        [_rdVariableName release];
        _rdVariableName = [[_rdVariableNameField stringValue] retain];
        if (!_rdVariableName) {
            _rdVariableName = [[NSString string] retain];
        }
    }
    else if ([notification object] == _rdVariableValueField) {
        [_rdVariableValue release];
        _rdVariableValue = [[_rdVariableValueField stringValue] retain];
        if (!_rdVariableValue) {
            _rdVariableValue = [[NSString string] retain];
        }
    }
}


@end
