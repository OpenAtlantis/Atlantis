//
//  PerlScriptingEngine.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/13/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "PerlScriptingEngine.h"
#import "NSFileManagerExtensions.h"
#import "AtlantisState.h"
#import "ScriptBridge.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisMainController.h"
#import "NSAttributedStringAdditions.h"
//#import <CamelBones/Runtime.h>
#import <Growl/Growl.h>

@implementation PerlScriptingEngine

- (id) init
{
    self = [super init];
//    if (self) {
//        _rdPerlInterpreter = nil;
//        _rdWrapperDone = NO;
//        _rdPerlLock = [[NSLock alloc] init]; 
//        [self engineReinit:nil];     
//    }
    return self;
}

- (void) dealloc
{
//    if (_rdPerlInterpreter) {
//        [_rdPerlInterpreter release];
//        _rdPerlInterpreter = nil;
//    }
//    [_rdPerlLock release]; 
    [super dealloc];
}

- (void) engineReinit:(AtlantisState *)state
{
    return;
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"disablePerl"])
//        return;
//
//    if (![_rdPerlLock tryLock]) {
//        return;
//    }
//
//    if (![CBPerl isAvailable]) {
//        if (!_rdPerlDisabled) {
//            _rdPerlDisabled = YES;
//            BOOL warned = [[NSUserDefaults standardUserDefaults] boolForKey:@"perlWarned"];
//            if ([GrowlApplicationBridge isGrowlRunning]) {
//                [GrowlApplicationBridge
//                    notifyWithTitle:@"Perl Unavailable"
//                        description:@"Atlantis was unable to find an appropriate Perl library, and has disabled Perl scripting."
//                   notificationName:@"User Defined"
//                           iconData:nil
//                           priority:0
//                           isSticky:!warned
//                       clickContext:nil];
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"perlWarned"];
//            }
//            NSLog(@"Perl not available!");
//        }
//        return;
//    }
//
//    if (!_rdPerlInterpreter) {
//        _rdPerlInterpreter = [[CBPerl alloc] init];
//    }
//
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"perlWarned"];
//    [[RDAtlantisMainController controller] removeAllScriptedEventsForLanguage:@"Perl"];
//
//    NSString *libPath = @"~/Library/Atlantis/Scripts";
//
//    [[NSFileManager defaultManager] createDirectoriesToFile:[libPath stringByAppendingPathComponent:@"foo"]];
//
//    @try {
//        [_rdPerlInterpreter useModule:@"CamelBones"];
//        [_rdPerlInterpreter useLib:[libPath stringByExpandingTildeInPath]];
//
//        NSString *bundleModulePath = [[NSBundle mainBundle] bundlePath];
//        bundleModulePath = [bundleModulePath stringByAppendingPathComponent:@"Contents"];
//        bundleModulePath = [bundleModulePath stringByAppendingPathComponent:@"Scripts"];
//        [_rdPerlInterpreter useLib:bundleModulePath];
//        [_rdPerlInterpreter useModule:@"Atlantis"];
//
//        if (!_rdWrapperDone) {
//            CBWrapObjectiveCClass([ScriptBridge class]);
//            CBWrapObjectiveCClass([AtlantisState class]);
//            ScriptBridge *bridge = [[ScriptBridge alloc] init];
//            [_rdPerlInterpreter setValue:bridge forKey:@"ScriptBridge"];
//            _rdWrapperDone = YES;
//        }
//
//        NSDate *compareMe = [NSDate distantPast];
//
//        NSString *scriptPath = @"~/Library/Atlantis/Scripts";
//        scriptPath = [scriptPath stringByExpandingTildeInPath];
//
//        NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:scriptPath];
//        NSString *filename;
//
//        NSMutableArray *modules = [[[NSMutableArray alloc] init] autorelease];
//
//        while (filename = [dirEnum nextObject]) {
//            NSDictionary *fileAttrs = [[NSFileManager defaultManager] fileAttributesAtPath:[scriptPath stringByAppendingPathComponent:filename] traverseLink:YES];
//
//            NSDate *tempDate = [fileAttrs objectForKey:NSFileModificationDate];
//
//            if ([[filename pathExtension] isEqualToString:@"pm"]) {
//                if ([tempDate timeIntervalSinceDate:compareMe] > 0) {
//                    compareMe = tempDate;
//                }
//
//                NSString *moduleName = [filename stringByDeletingPathExtension];
//                [_rdPerlInterpreter eval:[NSString stringWithFormat:@"delete $INC{\'%@'};", filename]];
//                [_rdPerlInterpreter eval:[NSString stringWithFormat:@"use %@", moduleName]];
//                [modules addObject:moduleName];
//            }
//        }
//        [compareMe retain];
//        [_rdNewestModificationDate release];
//        _rdNewestModificationDate = compareMe;
//
//        NSEnumerator *modEnum = [modules objectEnumerator];
//        NSString *module;
//        while (module = [modEnum nextObject]) {
//            NSString *tempString = [NSString stringWithFormat:@"if (defined &%@::initialize_module) { %@::initialize_module(); }", module, module];
//            [_rdPerlInterpreter eval:tempString];
//        }
//    }
//    @catch (NSException *e)
//    {
//        // Ensure we try a re-init again next time.
//        [_rdNewestModificationDate release];
//        _rdNewestModificationDate = [[NSDate distantPast] copy];
//
//        NSLog([NSString stringWithFormat:@"Perl exception: %@", [e description]]);
//        if (state && [state world]) {
//            if ([state spawn]) {
//                [[state world] handleStatusOutput:[e description] onSpawn:[state spawn]];
//            }
//        }
//    }
//    @finally {
//        [_rdPerlLock unlock];
//    }
}

- (BOOL) engineNeedsReinit
{
    return NO;
//    NSDate *compareMe = [NSDate distantPast];
//
//    NSString *scriptPath = @"~/Library/Atlantis/Scripts";
//    scriptPath = [scriptPath stringByExpandingTildeInPath];
//
//    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:scriptPath];
//    NSString *filename;
//
//    while (filename = [dirEnum nextObject]) {
//        NSDictionary *fileAttrs = [[NSFileManager defaultManager] fileAttributesAtPath:[scriptPath stringByAppendingPathComponent:filename] traverseLink:YES];
//
//        if ([[filename pathExtension] isEqualToString:@"pm"]) {
//            NSDate *tempDate = [fileAttrs objectForKey:NSFileModificationDate];
//
//            if ([tempDate timeIntervalSinceDate:compareMe] > 0) {
//                compareMe = tempDate;
//            }
//        }
//    }
//
//    if (![compareMe isEqualToDate:_rdNewestModificationDate]) {
//        return YES;
//    }
//    else
//        return NO;
}

- (NSString *) scriptEngineName
{
    return @"Perl";
}

- (NSString *) scriptEngineVersion
{
//    [_rdPerlInterpreter eval:@"$perlVersion = \"$]\";"];
//    id perlVersion = [_rdPerlInterpreter valueForKey:@"perlVersion"];
//
//    return (NSString *)perlVersion;
}

- (NSString *) scriptEngineCopyright
{
    return @"1987-2004 Larry Wall";
}

- (id) executeFunction:(NSString *)string withState:(AtlantisState *)state
{
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"disablePerl"])
//        return nil;
//
//    if (![CBPerl isAvailable])
//        return nil;
//
//    int counter = 0;
//    BOOL locked = [_rdPerlLock tryLock];
//    struct timespec tsp;
//    tsp.tv_nsec = 5;
//
//    while ((counter < 2000) && !locked) {
//        counter++;
//        nanosleep(&tsp,NULL);
//        locked = [_rdPerlLock tryLock];
//    }
//
//    if (!locked)
//        return nil;
//
//    CBPerlHash *perlHash = nil;
//
//    @try {
//        perlHash = [CBPerlHash dictionaryNamed:@"Atlantis::StateData"];
//        if (!perlHash) {
//            perlHash = [CBPerlHash newDictionaryNamed:@"Atlantis::StateData"];
//            [_rdPerlInterpreter setValue:perlHash forKey:@"Atlantis::StateData"];
//        }
//
//        [perlHash addEntriesFromDictionary:[state scriptSafeData]];
//    }
//    @catch (NSException *e) {
//        NSLog([NSString stringWithFormat:@"Perl exception: %@", [e description]]);
//        if ([state world]) {
//            if ([state spawn]) {
//                [[state world] handleStatusOutput:[e description] onSpawn:[state spawn]];
//            }
//        }
//        if (locked)
//            [_rdPerlLock unlock];
//        return NO;
//    }
//    @finally {
//
//    }
//
//    NSDictionary *tempStateVar = [[RDAtlantisMainController controller] tempStateVars];
//    if (tempStateVar) {
//        NSEnumerator *tempEnum = [tempStateVar keyEnumerator];
//        NSString *walk;
//        while (walk = [tempEnum nextObject]) {
//            [perlHash setObject:[tempStateVar objectForKey:walk] forKey:[NSString stringWithFormat:@"temp.%@",walk]];
//        }
//    }
//
//    NSString *finalFunction = [string copy];
//
//    if ([[state extraDataForKey:@"event.cause"] isEqualToString:@"command"]) {
//        NSRange testRange;
//        NSString *fullCommandText = [[state extraDataForKey:@"RDCommandParams"] objectForKey:@"RDOptsFullString"];
//
//        testRange = [finalFunction rangeOfString:@"("];
//        if (testRange.length == 0) {
//            NSString *oldFunction = finalFunction;
//            finalFunction = [[NSString alloc] initWithFormat:@"%@(\"%@\")", oldFunction, fullCommandText ? fullCommandText : @""];
//            [oldFunction release];
//        }
//    }
//
//
//    id result;
//
//    @try {
//        result = [_rdPerlInterpreter eval:finalFunction];
//    }
//    @catch (NSException *e) {
//        NSLog([NSString stringWithFormat:@"Perl exception: %@", [e description]]);
//        if ([state world]) {
//            if ([state spawn]) {
//                [[state world] handleStatusOutput:[e description] onSpawn:[state spawn]];
//            }
//        }
//    }
//    @finally {
//        [finalFunction release];
//        [perlHash removeAllObjects];
//        if (locked)
//            [_rdPerlLock unlock];
//    }
//
//    return result;
    return nil;
}

@end
