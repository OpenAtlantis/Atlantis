//
//  AtlantisState.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisSpawn.h"
#import "NSAttributedStringAdditions.h"
#import <Lemuria/Lemuria.h>

@implementation AtlantisState

#pragma mark Initialization

+ (AtlantisState *) genericStateForWorld:(RDAtlantisWorldInstance *) world
{
    AtlantisState *newState = [[AtlantisState alloc] initWithString:nil inWorld:world forSpawn:nil];
    return newState;
}

- (id) initWithString:(NSMutableAttributedString *)string inWorld:(RDAtlantisWorldInstance *)world forSpawn:(RDAtlantisSpawn *) spawn
{
    self = [super init];
    if (self) {
        _rdEventLine = [string retain];
        _rdEventWorld = world;
        _rdEventSpawn = spawn;
        _rdEventSpawnPath = [[spawn internalPath] copy];
        
        id <RDNestedViewDescriptor> curSpawn = [[RDNestedViewManager manager] currentFocusedView];
        if (curSpawn == spawn) {
            _rdEventSpawnIsActive = YES;
        }
        else {
            _rdEventSpawnIsActive = NO;
        }
        
        _rdEventExtraData = [[NSDictionary dictionaryWithDictionary:[world baseStateInfo]] mutableCopy];        
        _rdScriptSafeData = [[NSDictionary dictionaryWithDictionary:[world baseStateInfo]] mutableCopy];        

        if (_rdEventSpawn) {
            [self setExtraData:[_rdEventSpawn viewPath] forKey:@"event.spawn"];
        }        
        if (_rdEventLine) {
            [self setExtraData:[_rdEventLine string] forKey:@"event.line"];
            [_rdScriptSafeData setObject:[_rdEventLine stringAsAML] forKey:@"event.script.lineAML"];
        } 
        id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];

        if (!curView) {
            NSArray *windows = [NSApp orderedWindows];
            
            RDNestedViewWindow *window = nil;
            NSEnumerator *windowEnum = [windows objectEnumerator];
            NSWindow *walk;
            
            while (!window && (walk = [windowEnum nextObject])) {
                if ([walk isKindOfClass:[RDNestedViewWindow class]]) {
                    window = (RDNestedViewWindow *)walk;
                }
            }
            
            if (window) {
                curView = [[window displayView] selectedView];
            }
        }

        if (curView && [(NSObject *)curView isKindOfClass:[RDAtlantisSpawn class]]) {
            [self setExtraData:[curView viewPath] forKey:@"application.spawn"];
        }

        NSString *windowUID = [[RDNestedViewManager manager] currentWindowUID];
        if (windowUID)
            [self setExtraData:windowUID forKey:@"application.windowUID"];
            
        if ([world isConnected]) {
            NSTimeInterval secs = [[NSDate date] timeIntervalSinceDate:[world connectedSince]];
            [self setExtraData:[NSString stringWithFormat:@"%d", secs] forKey:@"world.connected"];
        }
        else {
            [self setExtraData:@"-1" forKey:@"world.connected"];
        }
        
    }
    return self;
}

- (void) dealloc
{
    [_rdEventLine release];
    [_rdEventSpawnPath release];
    [_rdScriptSafeData release];
    [_rdEventExtraData release];
    [super dealloc];
}

#pragma mark Accessors

-(NSMutableAttributedString *) stringData
{
    return _rdEventLine;
}

-(void) setStringData:(NSAttributedString *)newStringData
{
    if (_rdEventLine && newStringData) {
        [_rdEventLine setAttributedString:newStringData];
        [_rdScriptSafeData setObject:[newStringData stringAsAML] forKey:@"event.script.lineAML"];
        [self setExtraData:[newStringData string] forKey:@"event.line"];
    }    
}

-(RDAtlantisWorldInstance *) world
{
    return _rdEventWorld;
}

-(RDAtlantisSpawn *) spawn
{
    return _rdEventSpawn;
}

-(NSString *) spawnPath
{
    return _rdEventSpawnPath;
}

-(BOOL) spawnIsActive
{
    return _rdEventSpawnIsActive;
}

-(id) extraDataForKey:(NSString *) key
{
    return [_rdEventExtraData objectForKey:key];
}

-(void) setExtraData:(id) extraData forKey:(NSString *) key
{
    [_rdEventExtraData setObject:extraData forKey:key];
    if ([extraData isKindOfClass:[NSString class]]) {
        [_rdScriptSafeData setObject:extraData forKey:key];
    }
    else if ([key isEqualToString:@"RDCommandParams"]) 
    {
        NSString *walk;
        NSDictionary *commandOptions = (NSDictionary *)extraData;
        NSEnumerator *optEnum = [commandOptions keyEnumerator];
        while (walk = [optEnum nextObject]) {
            if (![walk isEqualToString:@"RDOptsMainData"] && ![walk isEqualToString:@"RDOptsFullString"]) {
                [_rdScriptSafeData setObject:[commandOptions objectForKey:walk] forKey:[NSString stringWithFormat:@"command.%@",walk]];
            }
            else if ([walk isEqualToString:@"RDOptsMainData"]) {
                [_rdScriptSafeData setObject:[commandOptions objectForKey:walk] forKey:[NSString stringWithString:@"command.data"]];
            }
            else if ([walk isEqualToString:@"RDOptsFullString"]) {
                [_rdScriptSafeData setObject:[NSString stringWithFormat:@"%@ %@", [self extraDataForKey:@"event.command"], [commandOptions objectForKey:walk]] forKey:[NSString stringWithString:@"event.script.command"]];
            }
        }
    }
    else if ([key isEqualToString:@"RDRegexpMatchData"]) {
        int loop;
        NSArray *regExpArray = (NSArray *)extraData;
        
        for (loop = 0; loop < [regExpArray count]; loop++) {
            [_rdScriptSafeData setObject:[regExpArray objectAtIndex:loop] forKey:[NSString stringWithFormat:@"regexp.%d", loop]];
        }
    }
}

-(void) addExtraDataFrom:(NSDictionary *)dict
{
    NSEnumerator *dataEnum = [dict keyEnumerator];
    NSString *keyWalk;
    
    while (keyWalk = [dataEnum nextObject]) {
        [self setExtraData:[dict objectForKey:keyWalk] forKey:keyWalk];
    }
}

- (void) resetForString:(NSAttributedString *)string
{
    NSAttributedString *oldString = _rdEventLine;
    
    _rdEventLine = [string retain];
    [self setExtraData:[_rdEventLine string] forKey:@"event.line"];
    [_rdScriptSafeData setObject:[string stringAsAML] forKey:@"event.script.lineAML"];
    
    [oldString release];
}


- (void) resetForSpawn:(RDAtlantisSpawn *)spawn
{
    NSString *oldPath = _rdEventSpawnPath;

    _rdEventSpawn = spawn;
    _rdEventSpawnPath = [[spawn internalPath] copy];
    [self setExtraData:[_rdEventSpawn viewPath] forKey:@"event.spawn"];

    id <RDNestedViewDescriptor> curSpawn = [[RDNestedViewManager manager] currentFocusedView];
    if (curSpawn == spawn) {
        _rdEventSpawnIsActive = YES;
    }
    else {
        _rdEventSpawnIsActive = NO;
    }
    
    [oldPath release];
}

- (NSDictionary *) data
{
    return _rdEventExtraData;
}

- (NSDictionary *) scriptSafeData
{
    return _rdScriptSafeData;
}

#pragma mark Convenience

- (BOOL) textToWorld:(NSString *) text
{
    if (_rdEventWorld) {
        [_rdEventWorld sendString:text];
        return YES;
    }
    
    return NO;
}

- (BOOL) textToInput:(NSString *)text
{
    if (_rdEventSpawn) {
        [_rdEventSpawn stringIntoInput:text];
        return YES;
    }
    
    return NO;
}

- (NSString *) textFromInput
{
    if (_rdEventSpawn) {
        return [[_rdEventSpawn stringFromInput] copyWithZone:nil];
    }
    
    return nil;
}

- (NSString *) textFromHighlight
{
    if (_rdEventSpawn) {
        return [[_rdEventSpawn stringFromOutputSelection] copyWithZone:nil];
    }
    
    return nil;
}


- (BOOL) textToCurrentDisplay:(NSAttributedString *)string
{
    if (_rdEventSpawn) {
        [_rdEventSpawn appendString:string];
    }
    
    return NO;
}



@end
