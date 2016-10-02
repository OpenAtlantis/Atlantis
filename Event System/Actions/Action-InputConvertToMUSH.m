//
//  Action-InputConvertToMUSH.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/31/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-InputConvertToMUSH.h"
#import "AtlantisState.h"

@implementation Action_InputConvertToMUSH


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Input: Convert Input to MUSH Format";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Convert the contents of the input window to MUSH format.";
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
        
        [newInput replaceOccurrencesOfString:@"\r\n" withString:@"%r" options:0 range:NSMakeRange(0,[newInput length])];
        [newInput replaceOccurrencesOfString:@"\n\r" withString:@"%r" options:0 range:NSMakeRange(0,[newInput length])];
        [newInput replaceOccurrencesOfString:@"\r" withString:@"%r" options:0 range:NSMakeRange(0,[newInput length])];
        [newInput replaceOccurrencesOfString:@"\n" withString:@"%r" options:0 range:NSMakeRange(0,[newInput length])];
        [newInput replaceOccurrencesOfString:@"\t" withString:@"%t" options:0 range:NSMakeRange(0,[newInput length])];

        unsigned pos = 0;
        BOOL inSpace = NO;
        
        while (pos < [newInput length]) {
            unichar curChar = [newInput characterAtIndex:pos];
            
            if (curChar == ' ') {
                if (inSpace) {
                    [newInput replaceCharactersInRange:NSMakeRange(pos,1) withString:@"%b"];
                    pos++;
                }
                inSpace = YES;
            }
            else
                inSpace = NO;
            pos++;
        }
        
        [state textToInput:newInput];
        [newInput release];
    }

    return NO;
}



@end
