//
//  RDSpawnConfigRecord.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/11/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDSpawnConfigRecord.h"


@implementation RDSpawnConfigRecord

- (id) initWithPath:(NSString *)path forPatterns:(NSArray *)patterns withExceptions:(NSArray *)exceptions weight:(unsigned)weight defaultsActive:(BOOL)active activePatterns:(NSArray *)activePatterns maxLines:(unsigned) lines prefix:(NSString *)prefix statusBar:(BOOL)status;
{
    self = [super init];
    if (self) {
        _rdPatterns = nil;
        _rdExceptions = nil;
        _rdSpawnPrefix = nil;
        _rdSpawnWeight = weight;
        _rdMaxLines = lines;
        _rdDefaultsActive = active;
        if (patterns)
            _rdPatterns = [patterns retain];
        if (exceptions)
            _rdExceptions = [exceptions retain];
        if (activePatterns)
            _rdActiveExceptions = [activePatterns retain];
        
        _rdStatusBar = status;
            
        _rdSpawnPath = [path retain];
        if (prefix)
            _rdSpawnPrefix = [prefix retain];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [self init];
    if (self) {
        NSArray *tempArray;
        int version = [[coder decodeObjectForKey:@"spawn.version"] intValue]; 
    
        _rdSpawnPath = [[coder decodeObjectForKey:@"spawn.path"] retain];
        _rdSpawnWeight = (unsigned)[[coder decodeObjectForKey:@"spawn.weight"] intValue];
        _rdDefaultsActive = [coder decodeBoolForKey:@"spawn.activity"];
        _rdMaxLines = (unsigned)[[coder decodeObjectForKey:@"spawn.lines"] intValue];

        tempArray = [coder decodeObjectForKey:@"spawn.patterns"];
        if (tempArray) {
            _rdPatterns = [tempArray retain];
        }
        else
            _rdPatterns = nil;
            
        tempArray = [coder decodeObjectForKey:@"spawn.exceptions"];
        if (tempArray)
            _rdExceptions = [tempArray retain];
        else
            _rdExceptions = nil;
            
        NSString *tempString = [coder decodeObjectForKey:@"spawn.prefix"];
        if (tempString)
            _rdSpawnPrefix = [tempString retain];

        if (version >= 2)
            _rdStatusBar = [coder decodeBoolForKey:@"spawn.statusBar"];
        else
            _rdStatusBar = YES;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[NSNumber numberWithInt:2] forKey:@"spawn.version"];
    [coder encodeBool:_rdDefaultsActive forKey:@"spawn.activity"];
    [coder encodeObject:_rdSpawnPath forKey:@"spawn.path"];
    [coder encodeObject:[NSNumber numberWithInt:_rdSpawnWeight] forKey:@"spawn.weight"];
    [coder encodeObject:[NSNumber numberWithInt:_rdMaxLines] forKey:@"spawn.lines"];
    [coder encodeBool:_rdStatusBar forKey:@"spawn.statusBar"];
    
    if (_rdPatterns)
        [coder encodeObject:_rdPatterns forKey:@"spawn.patterns"];
    if (_rdExceptions)
        [coder encodeObject:_rdExceptions forKey:@"spawn.exceptions"];
    if (_rdSpawnPrefix)
        [coder encodeObject:_rdSpawnPrefix forKey:@"spawn.prefix"];
}

- (void) dealloc
{
    [_rdPatterns release];
    [_rdExceptions release];
    [_rdActiveExceptions release];
    [_rdSpawnPath release];
    [super dealloc];
}

- (NSString *) path
{
    return _rdSpawnPath;
}

- (BOOL) matches:(NSString *) string
{
    BOOL result = NO;
    
    if (_rdPatterns) {
        NSEnumerator *patternEnum = [_rdPatterns objectEnumerator];
        
        RDStringPattern *patternWalk;
        
        while (!result && (patternWalk = [patternEnum nextObject])) {
            result = [patternWalk patternMatchesString:string];
        }
    }
    else
        result = YES;

    if (result && _rdExceptions) {
        NSEnumerator *patternEnum = [_rdExceptions objectEnumerator];
        
        RDStringPattern *patternWalk;
        
        while (result && (patternWalk = [patternEnum nextObject])) {
            if ([patternWalk patternMatchesString:string]) 
                result = NO;
        }
    }

    return result;
}

- (unsigned) weight
{
    return _rdSpawnWeight;
}

- (unsigned) maxLines
{
    return _rdMaxLines;
}

- (NSString *) prefix
{
    return _rdSpawnPrefix;
}

- (void) setPrefix:(NSString *)prefix
{
    [_rdSpawnPrefix release];
    _rdSpawnPrefix = [prefix retain];
}

- (BOOL) defaultActive
{
    return _rdDefaultsActive;
}

- (BOOL) statusBar
{
    return _rdStatusBar;
}

- (void) setStatusBar:(BOOL) statusBar
{
    _rdStatusBar = statusBar;
}

- (NSArray *) activeExceptions
{
    return _rdActiveExceptions;
}

- (NSArray *) patterns
{
    return _rdPatterns;
}

- (NSArray *) exceptions
{
    return _rdExceptions;
}

@end
