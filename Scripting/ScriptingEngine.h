//
//  ScriptingEngine.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/13/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AtlantisState;

@interface ScriptingEngine : NSObject {

}

- (id) executeFunction:(NSString *)string withState:(AtlantisState *)state;

- (BOOL) engineNeedsReinit;
- (void) engineReinit:(AtlantisState *)state;

- (NSString *) scriptEngineName;
- (NSString *) scriptEngineVersion;
- (NSString *) scriptEngineCopyright;

@end
