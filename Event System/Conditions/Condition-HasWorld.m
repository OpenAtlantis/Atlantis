//
//  Condition-HasWorld.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-HasWorld.h"
#import "AtlantisState.h"

@implementation Condition_HasWorld

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"State: Has an Active World";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Check that we have an active world.";
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    // Subclasses override this
    if ([state world])
        return YES;
        
    return NO;
}


@end
