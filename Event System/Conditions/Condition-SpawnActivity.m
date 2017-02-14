//
//  Condition-SpawnActivity.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/26/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-SpawnActivity.h"
#import "AtlantisState.h"
#import <Lemuria/Lemuria.h>
#import "RDAtlantisSpawn.h"

@implementation Condition_SpawnActivity

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Spawn: Does Not Have Activity Indicator";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"The current spawn does not have an activity indicator.";
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    RDAtlantisSpawn *spawn = [state spawn];

    if (spawn) {
        return ![[RDNestedViewManager manager] hasActivitySelf:spawn];
    }

    return NO;
}


@end
