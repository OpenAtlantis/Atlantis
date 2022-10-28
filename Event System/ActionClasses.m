//
//  ActionClasses.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ActionClasses.h"
#import <objc/runtime.h>
#import <objc/message.h>

NSInteger actionSort(id obj1, id obj2, void *context)
{
    NSString *s1;
    NSString *s2;
    
    NSString* (*SendReturningString)(id, SEL) = (NSString* (*)(id, SEL))objc_msgSend;
    
    s1 = SendReturningString((Class)obj1,@selector(actionName));
    s2 = SendReturningString((Class)obj2,@selector(actionName));

    return [s1 compare:s2];
}

@implementation ActionClasses

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

- (void) registerActionClass:(Class) actionClass
{
    if (class_getInstanceMethod(actionClass,@selector(executeForState:))) {
        [_rdClasses addObject:actionClass];
        [_rdClasses sortUsingFunction:actionSort context:NULL];
    }
}

- (unsigned) actionClassCount
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
        
    NSString* (*SendReturningString)(id, SEL) = (NSString* (*)(id, SEL))objc_msgSend;
    
    Class aClass = (Class)[_rdClasses objectAtIndex:index];
    if (aClass) {
        result = SendReturningString(aClass,@selector(actionName));
    }
    
    return result;
}

- (BaseAction *) instanceOfClassAtIndex:(unsigned) index
{
    if (index >= [_rdClasses count])
        return nil;
        
    BaseAction *result = nil;
        
    Class aClass = (Class)[_rdClasses objectAtIndex:index];
    if (aClass) {
        result = (BaseAction *)class_createInstance(aClass,0);
    }
    
    return result;
}

- (NSArray *) actionsForType:(AtlantisEventType) type
{
    NSEnumerator *actionClassEnum = [_rdClasses objectEnumerator];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    Class walkClass;
    
    NSNumber* (*SendTypeReturningNumber)(id, SEL, AtlantisEventType) = (NSNumber* (*)(id, SEL, AtlantisEventType))objc_msgSend;
    
    while (walkClass = [actionClassEnum nextObject]) {
        NSNumber * result = SendTypeReturningNumber(walkClass, @selector(validForType:), type);
        if (result && [result boolValue])
            [tempArray addObject:walkClass];
    }
    
    return tempArray;
}

@end
