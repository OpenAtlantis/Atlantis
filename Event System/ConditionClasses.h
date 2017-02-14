//
//  ConditionClasses.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseCondition.h"

@interface ConditionClasses : NSObject {

    NSMutableArray              *_rdClasses;

}

- (void) registerConditionClass:(Class) conditionClass;
- (unsigned) conditionClassCount;

- (Class) classAtIndex:(unsigned) index;
- (NSString *) stringForClassAtIndex:(unsigned) index;
- (BaseCondition *) instanceOfClassAtIndex:(unsigned) index;

- (NSArray *) conditions;
- (NSArray *) conditionsForType:(AtlantisEventType) eventType;

@end
