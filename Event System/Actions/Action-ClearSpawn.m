//
//  Action-ClearSpawn.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "Action-ClearSpawn.h"
#import "AtlantisState.h"
#import "RDAtlantisSpawn.h"
#import "NSStringExtensions.h"

@implementation Action_ClearSpawn

- (id) init
{
    self = [super init];
    if (self) {
        _rdTarget = nil;
    }
    return self;
}

- (void) dealloc
{
    [_rdTarget release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdTarget = [[coder decodeObjectForKey:@"action.clearTarget"] retain];
        
        if (!_rdTarget)
            _rdTarget = [[NSString stringWithString:@"%{event.spawn}"] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder;
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_rdTarget forKey:@"action.clearTarget"];
}


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Spawn: Delete all Scrollback";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Delete all scrollback from the current spawn entirely.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    return [NSNumber numberWithBool:YES];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSString *newTarget = [_rdTarget expandWithDataIn:[state data]];
    NSString *finalTarget = nil;
    id <RDNestedViewDescriptor> focusMe = [[RDNestedViewManager manager] viewByPath:newTarget];
    if (!focusMe) {
        NSString *worldBase = [state extraDataForKey:@"world.name"];
        
        if ([newTarget length] >= [worldBase length]) {
            if ([worldBase isEqualToString:[newTarget substringToIndex:[worldBase length]]]) {
                finalTarget = newTarget;
            }
        }
        
        if (!finalTarget) {
            finalTarget = [NSString stringWithFormat:@"%@:%@", worldBase, newTarget];
        }

        focusMe = [[RDNestedViewManager manager] viewByPath:newTarget];    
    }
    
    RDAtlantisSpawn *spawn = nil;
    
    if (focusMe && [((NSObject *)focusMe) isKindOfClass:[RDAtlantisSpawn class]])
        spawn = (RDAtlantisSpawn *)focusMe;

    if (spawn) {
        [spawn clearScrollback];
    }
    
    return NO;
}


- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_ClearSpawn" owner:self];
    }
    
    [_rdActualTargetSpawn setDelegate:self];
    
    if (_rdTarget)
        [_rdActualTargetSpawn setStringValue:_rdTarget];
    else {
        [_rdActualTargetSpawn setStringValue:@"%{event.spawn}"];
        _rdTarget = [[NSString stringWithString:@"%{event.spawn}"] retain];
    }
    
    return _rdInternalConfigurationView;
}

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    if ([notification object] == _rdActualTargetSpawn) {
        [_rdTarget release];
        _rdTarget = [[_rdActualTargetSpawn stringValue] retain];
    }
}


@end
