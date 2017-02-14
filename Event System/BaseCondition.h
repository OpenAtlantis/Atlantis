//
//  BaseCondition.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EventConditionProtocol.h"
#import "BaseAction.h"

@class AtlantisState;

@interface BaseCondition : NSObject <NSCoding, EventConditionProtocol> {

}

+ (NSNumber *) validForType:(AtlantisEventType) type;

- (BOOL) isTrueForState:(AtlantisState *) state;

@end
