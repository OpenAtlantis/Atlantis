//
//  DelayedEvent.h
//  Atlantis
//
//  Created by Rachel Blackman on 9/8/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseEvent.h"

@interface DelayedEvent : BaseEvent {

    NSDate *                _rdTargetDate;

}

- (NSDate *) targetDate;
- (void) setTargetDate:(NSDate *)date;

@end
