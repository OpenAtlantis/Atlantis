//
//  Action-SpawnPrefix.m
//  Atlantis
//
//  Created by Rachel Blackman on 12/21/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "Action-SpawnPrefix.h"
#import "AtlantisState.h"
#import "NSStringExtensions.h"
#import "RDAtlantisSpawn.h"
#import "RDAtlantisWorldInstance.h"
#import <Lemuria/Lemuria.h>

@interface RDAtlantisWorldInstance (Private)
- (NSString *) realPathForSpawn:(NSString *) path;
@end

@implementation Action_SpawnPrefix

- (id) init
{
    self = [super init];
    if (self) {
        _rdSpawnPath = nil;
        _rdSpawnPrefix = nil;
    }
    return self;
}

- (void) dealloc
{
    [_rdSpawnPath release];
    [_rdSpawnPrefix release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdSpawnPath = [[coder decodeObjectForKey:@"action.spawnPath"] retain];
        _rdSpawnPrefix = [[coder decodeObjectForKey:@"action.spawnPrefix"] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder;
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_rdSpawnPath forKey:@"action.spawnPath"];
    [coder encodeObject:_rdSpawnPrefix forKey:@"action.spawnPrefix"];
}


#pragma mark Action Implementation

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Spawn: Set Spawn Prefix";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Set the input prefix of a spawn.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeEvent) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSString *expandPath = [_rdSpawnPath expandWithDataIn:[state data]];
    NSString *expandPrefix = [_rdSpawnPrefix expandWithDataIn:[state data]];
        
    NSString *realPath = [[state world] realPathForSpawn:expandPath];
    id <RDNestedViewDescriptor> view = [[RDNestedViewManager manager] viewByPath:realPath];
    
    if (view) {
        if ([(NSObject *)view isKindOfClass:[RDAtlantisSpawn class]]) {
            NSString *oldPrefix = [(RDAtlantisSpawn *)view prefix];
            if ([oldPrefix isEqualToString:expandPrefix])
                return NO;
        }
    }    
    
    [[state world] setPrefix:expandPrefix forSpawnPath:expandPath];    
    
    return NO;
}

#pragma mark Configuration Glue

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_SpawnPrefix" owner:self];
    }
    
    [_rdSpawnPathField setDelegate:self];
    [_rdSpawnPrefixField setDelegate:self];
    
    if (_rdSpawnPath)
        [_rdSpawnPathField setStringValue:_rdSpawnPath];
    else
        [_rdSpawnPathField setStringValue:@""];

    if (_rdSpawnPrefix)
        [_rdSpawnPrefixField setStringValue:_rdSpawnPrefix];
    else
        [_rdSpawnPrefixField setStringValue:@""];
    
    return _rdInternalConfigurationView;
}

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    if ([notification object] == _rdSpawnPathField) {
        [_rdSpawnPath release];
        _rdSpawnPath = [[_rdSpawnPathField stringValue] retain];
    }
    else if ([notification object] == _rdSpawnPrefixField) {
        [_rdSpawnPrefix release];
        _rdSpawnPrefix = [[_rdSpawnPrefixField stringValue] retain];
    }

}

@end
