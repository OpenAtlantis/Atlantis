//
//  BaseAction.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EventActionProtocol.h"

@class AtlantisState;

typedef enum {
    AtlantisTypeUI,
    AtlantisTypeEvent,
    AtlantisTypeAlias
} AtlantisEventType;

@interface BaseAction : NSObject <EventActionProtocol,NSCoding> {

}

+ (NSNumber *) validForType:(AtlantisEventType) type;

- (BOOL) executeForState:(AtlantisState *) state;


@end
