//
//  ScriptingDispatch.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/13/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ScriptingDispatch.h"
#import "ScriptingEngine.h"
#import "RDAtlantisMainController.h"
#import "AtlantisState.h"

@implementation ScriptingDispatch

- (id) init
{
    self = [super init];
    if (self) {
        _rdScriptingEngines = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [_rdScriptingEngines release];
    [super dealloc];
}

- (void) addScriptingEngine:(ScriptingEngine *)engine
{
    if (engine && [engine scriptEngineName])
        [_rdScriptingEngines setObject:engine forKey:[engine scriptEngineName]];
}

- (ScriptingEngine *) engineForLanguage:(NSString *) language
{
    return [_rdScriptingEngines objectForKey:language];
}

- (NSArray *) languages
{
    return [[_rdScriptingEngines allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (void) refreshEngines:(AtlantisState *)state
{
    NSEnumerator *engineEnum = [_rdScriptingEngines objectEnumerator];
    
    ScriptingEngine *walk;
    
    while (walk = [engineEnum nextObject]) {
        if ([walk engineNeedsReinit]) 
            [walk engineReinit:state];
    }
}

- (id) executeScript:(NSString *) scriptString withState:(AtlantisState *)state inLanguage:(NSString *)language
{
    ScriptingEngine *engine = [self engineForLanguage:language];
    
    if (!engine)
        return NO;

    CFUUIDRef   uuid;
    CFStringRef string;
 
    uuid = CFUUIDCreate( NULL );
    string = CFUUIDCreateString( NULL, uuid );
        
    [state setExtraData:(NSString *)string forKey:@"event.uuid"];
    [[RDAtlantisMainController controller] addState:state forSession:(NSString *)string];

    id result = [engine executeFunction:scriptString withState:state];

    [[RDAtlantisMainController controller] finishedSession:(NSString *)string];
    
    CFRelease(string);
    CFRelease(uuid);
    
    return result;
}

@end
