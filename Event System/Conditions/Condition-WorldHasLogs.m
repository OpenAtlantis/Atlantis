//
//  Condition-WorldHasLogs.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/28/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-WorldHasLogs.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"


@implementation Condition_WorldHasLogs

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"World: Has Open Logs";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Check that our active world has open logs.";
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    // Subclasses override this
    if (![state world])
        return NO;
        
    if ([[[state world] logfiles] count])
        return YES;
        
    return NO;
}


@end
