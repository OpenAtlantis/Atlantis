//
//  Condition-WorldConnected.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-WorldConnected.h"
#import "AtlantisState.h"

@implementation Condition_WorldConnected

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"World: Has Just Connected";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"The world has just connected.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeEvent)
        return [NSNumber numberWithBool:YES];

    return [NSNumber numberWithBool:NO];
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    NSString *statechange = [state extraDataForKey:@"event.statechange"];

    if (statechange)
        if ([statechange caseInsensitiveCompare:@"connected"] == NSOrderedSame)
            return YES;

    return NO;
}


@end
