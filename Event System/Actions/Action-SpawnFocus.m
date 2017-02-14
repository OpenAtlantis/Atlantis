//
//  Action-SpawnFocus.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-SpawnFocus.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"
#import "NSStringExtensions.h"
#import <Lemuria/Lemuria.h>

@implementation Action_SpawnFocus

#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdSpawnPath = nil;
    }
    return self;
}

- (id) initWithPath:(NSString *) path
{
    self = [self init];
    if (self) {
        _rdSpawnPath = [[path copyWithZone:nil] retain];
    }
    return self;
}

- (void) dealloc
{
    [_rdSpawnPath release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdSpawnPath = [[coder decodeObjectForKey:@"action.spawnPath"] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder;
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_rdSpawnPath forKey:@"action.spawnPath"];
}

#pragma mark Action Implementation

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Spawn: Focus on Specific Spawn";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Focuses on a specific named spawn out of all available.";
}

- (NSString *) actionDescription
{
    // TODO: Localize
    NSString *result = [NSString stringWithFormat:@"Focus specifically on the spawn '%@'.",
                        _rdSpawnPath ? _rdSpawnPath : @""];
                        
    return result;
}


+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeEvent) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    id <RDNestedViewDescriptor> focusMe = nil;
    NSString *path = [_rdSpawnPath expandWithDataIn:[state data]];
    
    focusMe = [[RDNestedViewManager manager] viewByPath:path];
    
    if (!focusMe && [state world]) {
        // Make an attempt to find a sub-spawn of the world.
        NSString *tempString = [NSString stringWithFormat:@"%@:%@", [[state world] basePath], path];
        focusMe = [[RDNestedViewManager manager] viewByPath:tempString];
    }
    
    if (focusMe) {
        [[RDNestedViewManager manager] selectView:focusMe];
    }
    else
        NSBeep();

    return NO;
}

#pragma mark Configuration Glue

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_FocusSpawn" owner:self];
    }
    
    if (_rdSpawnPath)
        [_rdActualText setStringValue:_rdSpawnPath];
    else
        [_rdActualText setStringValue:@""];
        
    [_rdActualText setDelegate:self];
    
    return _rdInternalConfigurationView;
}

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    [_rdSpawnPath release];
    _rdSpawnPath = [[_rdActualText stringValue] retain];
}


@end
