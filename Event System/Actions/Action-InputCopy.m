//
//  Action-InputCopy.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-InputCopy.h"
#import "AtlantisState.h"


@implementation Action_InputCopy

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Input: Copy Contents to Clipboard";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Copy the current contents of the input window to the clipboard.";
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
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
        [pasteboard setString:inputContents forType:NSStringPboardType];        
    }

    return NO;
}


@end
