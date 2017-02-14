//
//  ScriptingDispatch.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/13/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ScriptingEngine;
@class AtlantisState;

@interface ScriptingDispatch : NSObject {

    NSMutableDictionary             *_rdScriptingEngines;

}

- (void) addScriptingEngine:(ScriptingEngine *)engine;
- (ScriptingEngine *) engineForLanguage:(NSString *)language;

- (NSArray *) languages;

- (void) refreshEngines:(AtlantisState *)state;

- (id) executeScript:(NSString *) string withState:(AtlantisState *)state inLanguage:(NSString *)language;

@end
