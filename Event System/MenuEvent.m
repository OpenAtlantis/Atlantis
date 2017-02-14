//
//  MenuEvent.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "MenuEvent.h"
#import "BaseCondition.h"

@implementation RDMenuEvent

- (BOOL) isEnabled
{
    return YES;
}

- (BOOL) shouldExecute:(AtlantisState *) state
{
    if (![self eventConditions] || ([[self eventConditions] count] == 0))
        return YES;
        
    BOOL result;

    if ([self eventConditionsAnded])
        result = YES;
    else
        result = NO;
        
    NSEnumerator *conditionEnum = [[self eventConditions] objectEnumerator];
    
    BaseCondition *conditionWalk;
    
    while (conditionWalk = [conditionEnum nextObject]) {
        if ([self eventConditionsAnded]) {
            result = result & [conditionWalk isTrueForState:state];
        }
        else {
            result = result | [conditionWalk isTrueForState:state];
        }
    }
    
    return result;
}

@end
