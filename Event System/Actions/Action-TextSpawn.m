//
//  Action-TextSpawn.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/26/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-TextSpawn.h"
#import "AtlantisState.h"
#import "NSStringExtensions.h"

@implementation Action_TextSpawn

- (id) init
{
    self = [super init];
    if (self) {
        _rdSpawnPath = nil;
        _rdCopyText = YES;
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
        _rdCopyText = [coder decodeBoolForKey:@"action.copy"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder;
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_rdSpawnPath forKey:@"action.spawnPath"];
    [coder encodeBool:_rdCopyText forKey:@"action.copy"];
}


#pragma mark Action Implementation

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Text: Copy or Move to Spawn";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Copy or move text to another spawn.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeEvent)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSArray *tempArray;
    NSMutableArray *workArray;
    
    NSRange effRange;
    NSDictionary *attrs;
    
    if (![[state stringData] length])
        return NO;
    
    attrs = [[state stringData] attributesAtIndex:0 effectiveRange:&effRange];
    tempArray = [attrs objectForKey:@"RDExtraSpawns"];
    
    if (tempArray) {
        workArray = [tempArray mutableCopy];
    }
    else {
        workArray = [[NSMutableArray alloc] init];
    }

    NSString *expandPath = [_rdSpawnPath expandWithDataIn:[state data]];

    [workArray addObject:expandPath];
    
    unsigned stringLen = [[state stringData] length];
    effRange = NSMakeRange(0,stringLen);
    
    [[state stringData] addAttribute:@"RDExtraSpawns" value:[NSArray arrayWithArray:workArray] range:effRange];
    [[state stringData] addAttribute:@"RDExtraSpawnMove" value:[NSNumber numberWithBool:!_rdCopyText] range:effRange];

    [workArray release];

    return NO;
}

#pragma mark Configuration Glue

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_TextSpawn" owner:self];
    }
    
    [_rdSpawnPathField setDelegate:self];
    
    if (_rdSpawnPath)
        [_rdSpawnPathField setStringValue:_rdSpawnPath];
    else
        [_rdSpawnPathField setStringValue:@""];

    if (_rdCopyText)
        [_rdCopyTextButton selectItemAtIndex:0];
    else
        [_rdCopyTextButton selectItemAtIndex:1];
    
    return _rdInternalConfigurationView;
}

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    [_rdSpawnPath release];
    _rdSpawnPath = [[_rdSpawnPathField stringValue] retain];
}

- (void) copyMoveChanged:(id) sender
{
    int selected = [_rdCopyTextButton indexOfSelectedItem];
    
    if (selected == 0)
        _rdCopyText = YES;
    else
        _rdCopyText = NO;
}



@end
