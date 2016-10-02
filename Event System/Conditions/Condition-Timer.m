//
//  Condition-Timer.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/18/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-Timer.h"
#import "AtlantisState.h"

@implementation Condition_Timer

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Timer: Event Runs Every ...";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Execute this event on a given interval.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeEvent)
        return [NSNumber numberWithBool:YES];

    return [NSNumber numberWithBool:NO];
}

- (id) init
{
    self = [super init];
    if (self) {
        _rdInterval = 60;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdInterval = [coder decodeDoubleForKey:@"timer.interval"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    [coder encodeDouble:_rdInterval forKey:@"timer.interval"];
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    NSDate *lastDate = [state extraDataForKey:@"RDLastFired"];
    if (!lastDate)
        return NO;
    
    if ([[NSDate date] timeIntervalSinceDate:lastDate] >= _rdInterval)
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
        [NSBundle loadNibNamed:@"CondConf_Timer" owner:self];
    }

    [_rdActualText setDelegate:self];
    [_rdActualText setDoubleValue:_rdInterval];
    
    return _rdInternalConfigurationView;
}


@end
