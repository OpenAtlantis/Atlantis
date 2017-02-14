//
//  Condition-AtlantisVisible.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/12/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "Condition-AtlantisVisible.h"


@implementation Condition_AtlantisVisible

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Atlantis: Application is visible.";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Atlantis is not hidden and has at least one window that is not miniaturized.";
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    NSArray *windows = [NSApp windows];
    BOOL isVisible = NO;
    
    NSEnumerator *windowEnum = [windows objectEnumerator];
    NSWindow *window;
    
    while (window = [windowEnum nextObject]) {
        if ([window isVisible] && ![window isMiniaturized]) {
            isVisible = YES;
        }
    }
    
    return isVisible;
}


@end
