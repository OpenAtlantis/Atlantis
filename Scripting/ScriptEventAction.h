//
//  ScriptEventAction.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/25/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AtlantisState.h"
#import "PTHotKeyCenter.h"
#import "PTKeyCombo.h"

@interface ScriptEventAction : NSObject {

    NSString                *_rdType;
    NSString                *_rdFunction;
    NSString                *_rdLanguage;
    NSString                *_rdWorld;
    NSString                *_rdPattern;
    
    NSString                *_rdAlias;

    NSTimeInterval           _rdSeconds;
    NSMutableDictionary     *_rdLastFired;
    int                      _rdCountdown;
    
    PTKeyCombo              *_rdKeys;
    PTHotKey                *_rdKeyRegistration;
    BOOL                     _rdGlobal;
}

- (id) initForLine:(NSString *)pattern withLanguage:(NSString *)eventLanguage inWorld:(NSString *)world withFunction:(NSString *)eventFunction withInterval:(NSTimeInterval)seconds repeatCount:(int) repeat;
- (id) initForType:(NSString *)eventType withLanguage:(NSString *)eventLanguage inWorld:(NSString *)world withFunction:(NSString *)eventFunction withInterval:(NSTimeInterval)seconds repeatCount:(int) repeat;
- (id) initForAlias:(NSString *)alias withLanguage:(NSString *)eventLanguage inWorld:(NSString *)world withFunction:(NSString *)eventFunction withInterval:(NSTimeInterval)seconds;
- (id) initForHotkey:(PTKeyCombo *)key globally:(BOOL)globalKey withLanguage:(NSString *)eventLanguage inWorld:(NSString *)world withFunction:(NSString *)eventFunction withInterval:(NSTimeInterval)seconds;

- (void) disable;

- (NSString *) eventType;
- (NSString *) eventPattern;
- (NSString *) eventLanguage;
- (NSString *) eventWorld;
- (NSString *) eventFunction;

- (int) countdown;

- (void) executeForState:(AtlantisState *)state;
- (void) execute:(id) sender;

- (PTKeyCombo *)keyCode;
- (NSString *) alias;

@end

