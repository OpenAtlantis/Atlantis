//
//  BaseAction.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "BaseAction.h"


@implementation BaseAction

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

+ (NSString *) actionName
{
    return @"Base Action";
}

+ (NSString *) actionDescription
{
    return @"This is the base action, and should never appear!";
}

- (NSString *) actionName
{
    return [[self class] actionName];
}

- (NSString *) actionDescription
{
    return [[self class] actionDescription];
}

- (NSView *) actionConfigurationView
{
    return nil;
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    return [NSNumber numberWithBool:NO];
}

#pragma Execution

- (BOOL) executeForState:(AtlantisState *) state
{
    // Subclasses override this
    return NO;
}

@end


/* Template

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Action: Foo";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Foo the bar with the baz and stuff.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{

    return NO;
}

*/