//
//  BaseEvent.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/3/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EventDataProtocol.h"

@class AtlantisState;

@interface BaseEvent : NSObject <EventDataProtocol,NSCoding> {

    NSString                *_rdEventName;
    NSString                *_rdEventDesc;

    BOOL                     _rdEnabled;
    BOOL                     _rdConditionsAnded;

    NSMutableArray          *_rdActions;
    NSMutableArray          *_rdConditions;

    NSMutableDictionary     *_rdLastFired;

}

- (BOOL) shouldExecuteForCause:(NSString *) reason subCause:(id) subcause;
- (BOOL) shouldExecute:(AtlantisState *) state;

- (void) executeWithCause:(NSString *) reason subCause:(id) subcause;
- (void) executeForState:(AtlantisState *) state;

- (BOOL) isEnabled;

@end
