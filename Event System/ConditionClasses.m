//
//  ConditionClasses.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ConditionClasses.h"
#import <objc/runtime.h>


int conditionSort(id obj1, id obj2, void *context)
{
    NSString *s1;
    NSString *s2;
    
    s1 = (NSString *)objc_msgSend((Class)obj1,@selector(conditionName));
    s2 = (NSString *)objc_msgSend((Class)obj2,@selector(conditionName));

    return [s1 compare:s2];
}

@implementation ConditionClasses

- (id) init
{
    _rdClasses = [[NSMutableArray alloc] init];
    return self;
}

- (void) dealloc
{
    [_rdClasses release];
    [super dealloc];
}

- (void) registerConditionClass:(Class) conditionClass
{
    if (class_getInstanceMethod(conditionClass,@selector(isTrueForState:))) {
        [_rdClasses addObject:conditionClass];
        [_rdClasses sortUsingFunction:conditionSort context:NULL];
    }
}

- (unsigned) conditionClassCount
{
    return [_rdClasses count];
}

- (Class) classAtIndex:(unsigned) index
{
    return (Class)[_rdClasses objectAtIndex:index];
}

- (NSString *) stringForClassAtIndex:(unsigned) index
{
    if (index >= [_rdClasses count])
        return nil;
        
    NSString *result = nil;
        
    Class aClass = (Class)[_rdClasses objectAtIndex:index];
    if (aClass) {
        result = (NSString *)objc_msgSend(aClass,@selector(conditionName));
    }
    
    return result;
}

- (BaseCondition *) instanceOfClassAtIndex:(unsigned) index
{
    if (index >= [_rdClasses count])
        return nil;
        
    BaseCondition *result = nil;
        
    Class aClass = (Class)[_rdClasses objectAtIndex:index];
    if (aClass) {
        result = (BaseCondition *)class_createInstance(aClass,0);
    }
    
    return result;
}

- (NSArray *) conditions
{
    return _rdClasses;
}


- (NSArray *) conditionsForType:(AtlantisEventType) type
{
    NSEnumerator *conditionClassEnum = [_rdClasses objectEnumerator];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    Class walkClass;
    
    while (walkClass = [conditionClassEnum nextObject]) {
        NSNumber * result = objc_msgSend(walkClass, @selector(validForType:), type);
        if (result && [result boolValue])
            [tempArray addObject:walkClass];
    }
    
    return tempArray;
}


@end
