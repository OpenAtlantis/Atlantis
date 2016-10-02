//
//  Action-InputConvertFromMUSH.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/31/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-InputConvertFromMUSH.h"
#import "AtlantisState.h"

@implementation Action_InputConvertFromMUSH


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Input: Convert Input from MUSH Format";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Convert the contents of the input window from MUSH format.";
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
        
        [newInput replaceOccurrencesOfString:@"%r" withString:@"\n" options:0 range:NSMakeRange(0,[newInput length])];
        [newInput replaceOccurrencesOfString:@"%t" withString:@"\t" options:0 range:NSMakeRange(0,[newInput length])];
        [newInput replaceOccurrencesOfString:@"%b" withString:@" " options:0 range:NSMakeRange(0,[newInput length])];
        
        [state textToInput:newInput];
        [newInput release];
    }

    return NO;
}

@end
