//
//  Action-StatusSend.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/25/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-StatusSend.h"
#import "NSStringExtensions.h"
#import "AtlantisState.h"
#import "RDAtlantisSpawn.h"
#import "RDAtlantisWorldInstance.h"

#import <Lemuria/Lemuria.h>

@implementation Action_StatusSend

#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdString = nil;
    }
    return self;
}

- (id) initWithString:(NSString *) string
{
    self = [self init];
    if (self) {
        _rdString = [[string copyWithZone:nil] retain];
        _rdTarget = [[NSString stringWithString:@"%{event.spawn}"] retain];
    }
    return self;
}

- (void) dealloc
{
    [_rdString release];
    [_rdTarget release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdString = [[coder decodeObjectForKey:@"action.statusText"] retain];
        _rdTarget = [[coder decodeObjectForKey:@"action.statusTarget"] retain];
        
        if (!_rdTarget)
            _rdTarget = [[NSString stringWithString:@"%{event.spawn}"] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder;
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_rdString forKey:@"action.statusText"];
    [coder encodeObject:_rdTarget forKey:@"action.statusTarget"];
}


#pragma mark Action Implementation

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Spawn: Display Status Text";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Display text in the given spawn.";
}

- (NSString *) actionDescription
{
    // TODO: Localize
    NSString *result = [NSString stringWithFormat:@"Show '%@' in '%@'.",
                        _rdString ? _rdString : @"", _rdTarget];
                        
    return result;
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeEvent) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSString *newString = [_rdString expandWithDataIn:[state data]];
    NSString *newTarget = [_rdTarget expandWithDataIn:[state data]];  
    NSString *finalTarget = nil;
    BOOL inMyWorld = NO;
    
    id <RDNestedViewDescriptor> focusMe = [[RDNestedViewManager manager] viewByPath:newTarget];
    if (!focusMe) {
        NSString *worldBase = [state extraDataForKey:@"world.name"];
        
        if ([newTarget length] >= [worldBase length]) {
            if ([worldBase isEqualToString:[newTarget substringToIndex:[worldBase length]]]) {
                finalTarget = newTarget;
                inMyWorld = YES;
            }
        }
        
        if (!finalTarget) {
            finalTarget = [NSString stringWithFormat:@"%@:%@", worldBase, newTarget];
            inMyWorld = YES;
        }

        focusMe = [[RDNestedViewManager manager] viewByPath:newTarget];    
    }
    
    if (focusMe && [(NSObject *)focusMe isKindOfClass:[RDAtlantisSpawn class]]) {
        RDAtlantisWorldInstance *world = [(RDAtlantisSpawn *)focusMe world];
        NSString *basePath = [world basePath];
        NSString *realPath = [focusMe viewPath];
        if ([realPath length] == [basePath length]) {
            finalTarget = @"";
        }
        else {
            finalTarget = [realPath substringFromIndex:[basePath length] + 1];
        }
        
        [world outputStatus:newString toSpawn:finalTarget];
    }
    else {
        if (inMyWorld && finalTarget) {
            NSString *basePath = [[state world] basePath];
            NSString *realPath = finalTarget;
            if ([realPath length] == [basePath length]) {
                finalTarget = @"";
            }
            else {
                finalTarget = [realPath substringFromIndex:[basePath length] + 1];
            }
            [[state world] outputStatus:newString toSpawn:finalTarget];
        }
        else  // We give up, yargh.
            [[state world] outputStatus:newString toSpawn:[state spawnPath]];
    }

    return NO;
}

#pragma mark Configuration Glue

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_SendStatus" owner:self];
    }
    
    [_rdActualText setDelegate:self];
    [_rdActualTargetSpawn setDelegate:self];
    
    if (_rdString)
        [_rdActualText setStringValue:_rdString];
    else
        [_rdActualText setStringValue:@""];
        
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
    if ([notification object] == _rdActualText) {
        [_rdString release];
        _rdString = [[_rdActualText stringValue] retain];
    }
    else if ([notification object] == _rdActualTargetSpawn) {
        [_rdTarget release];
        _rdTarget = [[_rdActualTargetSpawn stringValue] retain];
    }
}



@end
