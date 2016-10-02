//
//  Action-OutputCopyInput.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/3/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-OutputCopyInput.h"
#import "AtlantisState.h"
#import "RDAtlantisSpawn.h"

@implementation Action_OutputCopyInput

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Spawn: Copy Selected Text to Input Window";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Insert the selected text in the spawn to the input window.";
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
        [[state spawn] stringInsertIntoInput:highlightContents];
    }
    [highlightContents release];

    return NO;
}



@end
