//
//  Action-HistoryPrev.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-HistoryPrev.h"

#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation Action_HistoryPrev

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Input: Command History, Previous";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Move one step backwards in the command history for the current input window.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    if ([state world]) {
        int pointer = [[state world] commandHistoryPoint];
        
        if (pointer == -1) {
            NSString *holdover = [state textFromInput];
            [[state world] setCommandHoldover:holdover];
        }
        
        pointer++;
        
        NSArray *commands = [[state world] commandHistory];
        if (pointer >= [commands count]) {
            NSBeep();
        }
        else {
            NSString *curHistory = [commands objectAtIndex:pointer];
            [[state world] setCommandHistoryPoint:pointer];
            [state textToInput:curHistory];
        }
    }
    
    return NO;
}

@end
