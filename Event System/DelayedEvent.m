//
//  DelayedEvent.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/8/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "DelayedEvent.h"


@implementation DelayedEvent

- (id) init
{
    self = [super init];
    if (self) {
        _rdTargetDate = nil;
    }
    return self;
}

- (void) dealloc
{
    [_rdTargetDate release];
    [super dealloc]; 
}

- (NSDate *) targetDate
{
    return _rdTargetDate;
}

- (void) setTargetDate:(NSDate *)date
{
    [_rdTargetDate release];
    _rdTargetDate = [date retain];
}
@end
