//
//  Condition-WorldDisconnected.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-WorldDisconnected.h"
#import "AtlantisState.h"

@implementation Condition_WorldDisconnected

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"World: Has Just Disconnected";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"The world has just disconnected.";
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
        if ([statechange caseInsensitiveCompare:@"disconnected"] == NSOrderedSame)
            return YES;

    return NO;
}



@end
