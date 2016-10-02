//
//  Action-OutputCopy.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/3/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-OutputCopy.h"
#import "AtlantisState.h"

@implementation Action_OutputCopy

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Spawn: Copy Selected Text to Clipboard";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Copy the selected text in the spawn to the clipboard.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSString *highlightContents = [state textFromHighlight];
    if (highlightContents && [highlightContents length]) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
        [pasteboard setString:highlightContents forType:NSStringPboardType];        
    }
    [highlightContents release];

    return NO;
}



@end
