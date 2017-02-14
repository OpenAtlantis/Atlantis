//
//  LuaScriptingEngine.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/30/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "LuaScriptingEngine.h"
#import "NSFileManagerExtensions.h"
#import "AtlantisState.h"
#import "ScriptBridge.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisMainController.h"
#import "NSAttributedStringAdditions.h"


@implementation LuaScriptingEngine

- (id) init
{
    self = [super init];
    if (self) {
        _rdLuaInterpreter = nil;
        _rdBridge = nil;
        _rdLuaLock = [[NSLock alloc] init]; 
        [self engineReinit:nil];     
    }
    return self;
}

- (void) dealloc
{
    if (_rdLuaInterpreter) {
        [_rdLuaInterpreter tearDown];
        [_rdLuaInterpreter release];
        _rdLuaInterpreter = nil;
    }
    [_rdLuaLock release]; 
    [_rdBridge release];
    [super dealloc];
}

- (void) engineReinit:(AtlantisState *)state
{
    if (![_rdLuaLock tryLock]) {
        return;
    }

    if (_rdLuaInterpreter) {
        [_rdLuaInterpreter tearDown];
        [_rdLuaInterpreter release];
    }
    
    _rdLuaInterpreter = [[LCLua readyLua] retain];
    [_rdLuaInterpreter setup];

    [[RDAtlantisMainController controller] removeAllScriptedEventsForLanguage:@"Lua"];

    NSString *libPath = @"~/Library/Atlantis/Scripts";

    [[NSFileManager defaultManager] createDirectoriesToFile:[libPath stringByAppendingPathComponent:@"foo"]];
    
    @try {
        NSString *bundleModulePath = [[NSBundle mainBundle] bundlePath];
        bundleModulePath = [bundleModulePath stringByAppendingPathComponent:@"Contents"];
        bundleModulePath = [bundleModulePath stringByAppendingPathComponent:@"Scripts"];
        [_rdLuaInterpreter runFileAtPath:[bundleModulePath stringByAppendingPathComponent:@"Atlantis.lua"]];

        if (!_rdBridge) {
            _rdBridge = [[ScriptBridge alloc] init];    
        }
        [_rdLuaInterpreter pushGlobalObject:_rdBridge withName:@"ScriptBridge"];
        
        NSDate *compareMe = [NSDate distantPast];
        
        NSString *scriptPath = [libPath stringByExpandingTildeInPath];
        
        NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:scriptPath];
        NSString *filename;
        
        while (filename = [dirEnum nextObject]) {
            NSDictionary *fileAttrs = [[NSFileManager defaultManager] fileAttributesAtPath:[scriptPath stringByAppendingPathComponent:filename] traverseLink:YES];
            
            NSDate *tempDate = [fileAttrs objectForKey:NSFileModificationDate];
            
            if ([[filename pathExtension] isEqualToString:@"lua"]) {
                if ([tempDate timeIntervalSinceDate:compareMe] > 0) {
                    compareMe = tempDate;
                }
                
                [_rdLuaInterpreter runFileAtPath:[scriptPath stringByAppendingPathComponent:filename]];
            }
        }
        [compareMe retain];
        [_rdNewestModificationDate release];
        _rdNewestModificationDate = compareMe;
    }
    @catch (NSException *e)
    {
        // Ensure we try a re-init again next time.
        [_rdNewestModificationDate release];
        _rdNewestModificationDate = [[NSDate distantPast] copy];
        
        NSLog([NSString stringWithFormat:@"Lua exception: %@", [e description]]); 
        if (state && [state world]) {
            if ([state spawn]) {
                [[state world] handleStatusOutput:[e description] onSpawn:[state spawn]];
            }
        }
    }
    @finally {        
        [_rdLuaLock unlock];
    }
}

- (BOOL) engineNeedsReinit
{
    NSDate *compareMe = [NSDate distantPast];
    
    NSString *scriptPath = @"~/Library/Atlantis/Scripts";
    scriptPath = [scriptPath stringByExpandingTildeInPath];

    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:scriptPath];
    NSString *filename;
    
    while (filename = [dirEnum nextObject]) {
        NSDictionary *fileAttrs = [[NSFileManager defaultManager] fileAttributesAtPath:[scriptPath stringByAppendingPathComponent:filename] traverseLink:YES];
        
        if ([[filename pathExtension] isEqualToString:@"lua"]) { 
            NSDate *tempDate = [fileAttrs objectForKey:NSFileModificationDate];
            
            if ([tempDate timeIntervalSinceDate:compareMe] > 0) {
                compareMe = tempDate;
            }
        }
    }
    
    if (![compareMe isEqualToDate:_rdNewestModificationDate]) {
        return YES;
    }
    else
        return NO;
}

- (NSString *) scriptEngineName
{
    return @"Lua";
}

- (NSString *) scriptEngineVersion
{
    return @"5.1";
}

- (NSString *) scriptEngineCopyright
{
    return @"1994-2007 Lua.org, PUC-Rio.";
}

- (id) executeFunction:(NSString *)string withState:(AtlantisState *)state
{
    int counter = 0;
    BOOL locked = [_rdLuaLock tryLock];
    struct timespec tsp;
    tsp.tv_nsec = 5;
    
    while ((counter < 2000) && !locked) {
        counter++;
        nanosleep(&tsp,NULL);
        locked = [_rdLuaLock tryLock];
    }
    
    if (!locked)
        return nil;

    NSMutableDictionary *tempDict = [[state scriptSafeData] mutableCopy];
    
    NSDictionary *tempStateVar = [[RDAtlantisMainController controller] tempStateVars];
    if (tempStateVar) {
        NSEnumerator *tempEnum = [tempStateVar keyEnumerator];
        NSString *walk;
        while (walk = [tempEnum nextObject]) {
            [tempDict setObject:[tempStateVar objectForKey:walk] forKey:[NSString stringWithFormat:@"temp.%@",walk]];
        } 
    }

    NSString *finalFunction = [string copy];

    if ([[state extraDataForKey:@"event.cause"] isEqualToString:@"command"]) {
        NSRange testRange;
        NSString *fullCommandText = [[state extraDataForKey:@"RDCommandParams"] objectForKey:@"RDOptsFullString"];
        
        testRange = [finalFunction rangeOfString:@"("];
        if (testRange.length == 0) {
            NSString *oldFunction = finalFunction;
            finalFunction = [[NSString alloc] initWithFormat:@"%@(\"%@\")", oldFunction, fullCommandText ? fullCommandText : @""];
            [oldFunction release];
        }
    }

    [_rdLuaInterpreter pushDictionaryAsTable:tempDict withName:@"AtlantisState"];
       
    @try {
        [_rdLuaInterpreter runBuffer:finalFunction];        
    }
    @catch (NSException *e) {
        NSLog([NSString stringWithFormat:@"Lua exception: %@", [e description]]); 
        if ([state world]) {
            if ([state spawn]) {
                [[state world] handleStatusOutput:[e description] onSpawn:[state spawn]];
            }
        }
    }
    @finally {
        [finalFunction release];
        [tempDict release];
        if (locked)
            [_rdLuaLock unlock];
    }
    
    return nil;
}



@end
