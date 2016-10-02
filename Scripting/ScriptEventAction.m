//
//  ScriptEventAction.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/25/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "ScriptEventAction.h"
#import "ScriptingDispatch.h"
#import "ScriptingEngine.h"
#import "AtlantisState.h"
#import "PTHotKeyCenter.h"
#import "PTHotKey.h"
#import "RDAtlantisMainController.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisSpawn.h"
#import "NSStringExtensions.h"
#import <Lemuria/Lemuria.h>


@interface ScriptEventAction (Private)
- (void) execute:(id) sender;
- (void) executeWithCause:(NSString *) cause subCause:(id) subcause;
@end

@implementation ScriptEventAction

- (id) initForLine:(NSString *)pattern withLanguage:(NSString *)eventLanguage inWorld:(NSString *)world withFunction:(NSString *)eventFunction withInterval:(NSTimeInterval)seconds repeatCount:(int) repeats
{
    self = [super init];
    if (self) {
        _rdType = [[NSString alloc] initWithString:@"line"];
        _rdPattern = [pattern copy];
        _rdLanguage = [eventLanguage copy];
        _rdWorld = [world copy];
        _rdFunction = [eventFunction copy];
        _rdKeys = nil;
        _rdAlias = nil;
        _rdSeconds = seconds;
        _rdLastFired = [[NSMutableDictionary alloc] init];
        _rdCountdown = repeats;    
    }
    return self;
}

- (id) initForType:(NSString *)eventType withLanguage:(NSString *)eventLanguage inWorld:(NSString *)world withFunction:(NSString *)eventFunction withInterval:(NSTimeInterval)seconds repeatCount:(int)repeats
{
    self = [super init];
    if (self) {
        _rdType = [eventType copy];
        _rdPattern = nil;
        _rdLanguage = [eventLanguage copy];
        _rdWorld = [world copy];
        _rdFunction = [eventFunction copy];
        _rdKeys = nil;
        _rdAlias = nil;
        _rdSeconds = seconds;
        _rdLastFired = [[NSMutableDictionary alloc] init];
        _rdCountdown = repeats;
    }
    return self;
}

- (id) initForAlias:(NSString *)alias withLanguage:(NSString *)eventLanguage inWorld:(NSString *)world withFunction:(NSString *)eventFunction withInterval:(NSTimeInterval)seconds 
{
    self = [super init];
    if (self) {
        _rdType = [[NSString stringWithString:@"command"] retain];
        _rdPattern = nil;
        _rdLanguage = [eventLanguage copy];
        _rdWorld = [world copy];
        _rdFunction = [eventFunction copy];
        _rdKeys = nil;
        _rdAlias = [alias copy];    
        _rdSeconds = seconds;
        _rdLastFired = [[NSMutableDictionary alloc] init];
        _rdCountdown = -1;
    }
    return self;
}


- (id) initForHotkey:(PTKeyCombo *)key globally:(BOOL)globalKey withLanguage:(NSString *)eventLanguage inWorld:(NSString *)world withFunction:(NSString *)eventFunction withInterval:(NSTimeInterval)seconds
{
    self = [super init];
    if (self) {
        _rdType = [[NSString stringWithString:@"hotkey"] retain];
        _rdPattern = nil;
        _rdLanguage = [eventLanguage copy];
        _rdWorld = [world copy];
        _rdFunction = [eventFunction copy];
        _rdKeys = [key retain];
        _rdGlobal = globalKey;
        _rdAlias = nil;
        if (_rdGlobal) {
            _rdKeyRegistration = [[PTHotKey alloc] initWithIdentifier:self keyCombo:_rdKeys];
            [_rdKeyRegistration setTarget:self];
            [_rdKeyRegistration setAction:@selector(execute:)];
            [[PTHotKeyCenter sharedCenter] registerHotKey:_rdKeyRegistration];
        }
        else {
            _rdKeyRegistration = nil;
        }
        _rdSeconds = seconds;
        _rdLastFired = [[NSMutableDictionary alloc] init];
        _rdCountdown = -1;
    }
    return self;
}

- (void) executeWithCause:(NSString *) cause subCause:(id) subcause
{
    RDAtlantisWorldInstance *world = nil;
    RDAtlantisSpawn *spawn = nil;
    
    id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];

    if (curView && [(NSObject *)curView isKindOfClass:[RDAtlantisSpawn class]]) {
        spawn = (RDAtlantisSpawn *)curView;
    }
    
    if (spawn) {
        world = [spawn world];
    }

    AtlantisState *state = nil;
    
    if ([cause isEqualToString:@"line"])
        state = [[AtlantisState alloc] initWithString:(NSMutableAttributedString*)subcause inWorld:world forSpawn:spawn];
    else
        state = [[AtlantisState alloc] initWithString:(NSMutableAttributedString*)subcause inWorld:world forSpawn:spawn];
    
    [state setExtraData:[NSString stringWithString:cause] forKey:@"event.cause"];
    if ([cause isEqualToString:@"statechange"]) {
        [state setExtraData:[NSString stringWithString:[subcause string]] forKey:@"event.statechange"];
    }
    [self executeForState:state];
    [state release];
}

- (void) execute:(id) sender
{
    [self executeWithCause:@"hotkey" subCause:nil];
}

- (void) disable
{
    if (_rdKeyRegistration) {
        [[PTHotKeyCenter sharedCenter] unregisterHotKey:_rdKeyRegistration];
        [_rdKeyRegistration release];
    }
    _rdKeyRegistration = nil;
}

- (void) dealloc
{
    [_rdLastFired release];

    [_rdKeys release];
        
    [_rdAlias release];
    
    [_rdLanguage release];
    [_rdType release];
    [_rdPattern release];
    [_rdFunction release];
    [_rdWorld release];
    [super dealloc];
}

- (NSString *) eventPattern
{
    return _rdPattern;
}

- (NSString *) eventLanguage
{
    return _rdLanguage;
}

- (NSString *) eventType
{
    return _rdType;
}

- (NSString *) eventFunction
{
    return _rdFunction;
}

- (NSString *) eventWorld
{
    return _rdWorld;
}

- (int) countdown
{
    return _rdCountdown;
}

- (PTKeyCombo *) keyCode
{
    return _rdKeys;
}

- (NSString *) alias
{
    return _rdAlias;
}

- (void) executeForState:(AtlantisState *)state
{
    RDAtlantisWorldInstance *world = [state world];

    if (world) {
        NSDate *lastFired = [_rdLastFired objectForKey:[world uuid]];
        if (lastFired) {
            NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:lastFired];
            if ((unsigned int)delta < _rdSeconds)
                return;
        }
        else {
            [_rdLastFired setObject:[NSDate date] forKey:[world uuid]];
            if (_rdSeconds)
                return;
        }
    }

    NSString *worldName = [state extraDataForKey:@"world.name"];
    NSString *eventWorld = [self eventWorld];
    if ((!eventWorld || [eventWorld isEqualToString:@""]) || (worldName && [[worldName lowercaseString] isEqualToString:[eventWorld lowercaseString]])) {
        ScriptingDispatch *scriptSystem = [[RDAtlantisMainController controller] scriptDispatch];
        
        if (scriptSystem) {
            NSString *finalFunction = [[self eventFunction] expandWithDataIn:[state data]];
            [scriptSystem executeScript:finalFunction withState:state inLanguage:[self eventLanguage]];
            if (_rdCountdown > 0) {
                _rdCountdown--;
            }
                            
            if (world)
                [_rdLastFired setObject:[NSDate date] forKey:[world uuid]];
        }
    }
}


@end
