//
//  Condition-WorldIdle.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-WorldIdle.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation Condition_WorldIdle

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"World: User Idle for at least ...";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Execute this event when the user (you) has not sent anything to the world for X seconds.";
}

- (id) init
{
    self = [super init];
    if (self) {
        _rdInterval = 600;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdInterval = [coder decodeDoubleForKey:@"idle.interval"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    [coder encodeDouble:_rdInterval forKey:@"idle.interval"];
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    if (![state world])
        return NO;
        
    if (![[state world] isConnected])
        return NO;
        
    NSDate *lastNetActivity = [[state world] lastNetActivity];

    if ([[NSDate date] timeIntervalSinceDate:lastNetActivity] >= _rdInterval)
        return YES;
    
    return NO;
}

#pragma mark Configuration

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    _rdInterval = [_rdActualText doubleValue];
}


- (NSView *) conditionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"CondConf_WorldIdle" owner:self];
    }

    [_rdActualText setDelegate:self];
    [_rdActualText setDoubleValue:_rdInterval];
    
    return _rdInternalConfigurationView;
}


@end
