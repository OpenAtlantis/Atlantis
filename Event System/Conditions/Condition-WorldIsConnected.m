//
//  Condition-WorldIsConnected.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-WorldIsConnected.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation Condition_WorldIsConnected

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"World: World is Connected";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Check that the current world is connected.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];

    return [NSNumber numberWithBool:NO];
}


#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    // Subclasses override this
    if (![state world])
        return NO;

    return [[state world] isConnected];
}


@end
