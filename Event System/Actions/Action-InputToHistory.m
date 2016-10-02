//
//  Action-InputToHistory.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-InputToHistory.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation Action_InputToHistory

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Input: Copy Contents to Command History";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Add to the current contents of the input window to the command history, as if it had been sent to the world.";
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
        if ([state world])
            [[state world] addToCommandHistory:inputContents];
            [[state world] setCommandHistoryPoint:-1];
    }

    return NO;
}


@end
