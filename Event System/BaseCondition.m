//
//  BaseCondition.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "BaseCondition.h"


@implementation BaseCondition

#pragma mark Initialization

- (id) init
{
    self = [super init];
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [self init];
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    // Nothing
}

#pragma Event System Protocol


+ (NSString *) conditionName
{
    return @"Base Condition";
}

+ (NSString *) conditionDescription
{
    return @"This is the base condition, and should never appear!";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    return [NSNumber numberWithBool:YES];
}

- (NSString *) conditionName
{
    return [[self class] conditionName];
}

- (NSString *) conditionDescription
{
    return [[self class] conditionDescription];
}

- (NSView *) conditionConfigurationView
{
    return nil;
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    // Subclasses override this
    return NO;
}

/* Template:

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Base Condition";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"This is the base condition, and should never appear!";
}


#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    // Subclasses override this
    return NO;
}

*/

@end
