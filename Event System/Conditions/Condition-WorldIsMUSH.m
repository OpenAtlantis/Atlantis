//
//  Condition-WorldIsMUSH.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-WorldIsMUSH.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation Condition_WorldIsMUSH

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"World: World is a MUSH";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Check that the current world is a MUSH.";
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    // Subclasses override this
    if (![state world])
        return NO;
        
    NSNumber *type = [[state world] preferenceForKey:@"atlantis.world.codebase"];
    if (!type || ([type intValue] == AtlantisServerTinyMU)) {
        return YES;
    }
        
    return NO;
}


@end
