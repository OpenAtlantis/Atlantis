//
//  Action-EatLinefeeds.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-EatLinefeeds.h"
#import "AtlantisState.h"

@implementation Action_EatLinefeeds

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Input: Strip Linefeeds";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Strip linefeeds from the input window.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSString *inputContents = [state textFromInput];
    if (inputContents && [inputContents length]) {
        NSMutableString *newInput = [inputContents mutableCopy];
        
        [newInput replaceOccurrencesOfString:@"\r" withString:@" " options:0 range:NSMakeRange(0,[newInput length])];
        [newInput replaceOccurrencesOfString:@"\n" withString:@" " options:0 range:NSMakeRange(0,[newInput length])];
        [state textToInput:newInput];
        [newInput release];
    }

    return NO;
}

@end
