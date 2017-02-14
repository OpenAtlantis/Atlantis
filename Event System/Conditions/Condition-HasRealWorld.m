//
//  Condition-HasRealWorld.m
//  Atlantis
//
//  Created by Rachel Blackman on 8/19/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-HasRealWorld.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"


@implementation Condition_HasRealWorld


+ (NSString *) conditionName
{
    // TODO: Localize
    return @"State: Has an Active Non-Temp World";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Check that we have an active world.";
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    if ([state world] && ![[state world] isTemp])
        return YES;
        
    return NO;
}



@end
