//
//  Condition-ViewActive.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-ViewActive.h"
#import "AtlantisState.h"

@implementation Condition_ViewActive

#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdWantsActive = NO;
    }
    return self;
}

- (id) initWantsActive:(BOOL) active
{
    self = [self init];
    if (self) {
        _rdWantsActive = active;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdWantsActive = [coder decodeBoolForKey:@"activity.wantsActive"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    [coder encodeBool:_rdWantsActive forKey:@"activity.wantsActive"];
}

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Spawn: Is/Is Not Active Spawn";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"The spawn is (or is not) the active spawn.";
}

- (NSString *) conditionDescription
{
    // TODO: Localize
    NSString *descString = [NSString stringWithFormat:@"The spawn %@ the currently active spawn.",
                _rdWantsActive ? @"is" : @"is not"];
                
    return descString;
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    BOOL activeView = [state spawnIsActive];

    if (_rdWantsActive) {
        return activeView;
    }
    else {
        return !activeView;
    }
}

#pragma mark Configuration Goo

- (void) wantsActivityChanged:(id) sender
{
    if ([_rdActivityChooser indexOfItem:[_rdActivityChooser selectedItem]] == 0)
        _rdWantsActive = YES;
    else
        _rdWantsActive = NO;
    
}

- (NSView *) conditionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"CondConf_ViewActive" owner:self];
    }

    [_rdActivityChooser setTarget:self];
    [_rdActivityChooser setAction:@selector(wantsActivityChanged:)];
    
    if (_rdWantsActive) {
        [_rdActivityChooser selectItemAtIndex:0];
    }
    else {
        [_rdActivityChooser selectItemAtIndex:1];    
    }
    
    return _rdInternalConfigurationView;
}

@end
