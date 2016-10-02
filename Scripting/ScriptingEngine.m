//
//  ScriptingEngine.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/13/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ScriptingEngine.h"


@implementation ScriptingEngine

- (BOOL) engineNeedsReinit
{
    return NO;
}

- (void) engineReinit:(AtlantisState *)state
{
    return;
}

- (NSString *) scriptEngineName
{
    return nil;
}

- (NSString *) scriptEngineVersion
{
    return nil;
}

- (NSString *) scriptEngineCopyright
{
    return nil;
}

- (id) executeFunction:(NSString *)string withState:(AtlantisState *)state
{
    return nil;
}

@end
