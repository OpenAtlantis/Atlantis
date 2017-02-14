//
//  Condition-AtlantisFocus.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-AtlantisFocus.h"


@implementation Condition_AtlantisFocus

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Atlantis: Not Active Application";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Atlantis is not the presently active application.";
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    if ([NSApp isActive])
        return NO;
    else
        return YES;
}

@end
