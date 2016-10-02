//
//  Action-HistoryNext.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-HistoryNext.h"

#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation Action_HistoryNext

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Input: Command History, Next";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Move one step forward in the command history for the current input window.";
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

        pointer--;
        
        NSArray *commands = [[state world] commandHistory];
        if (pointer < -1) {
            NSBeep();
        }
        else if (pointer == -1) {
            NSString *holdover = [[state world] commandHoldover];
            if (holdover) {
                [state textToInput:holdover];
            }
            else {
                [state textToInput:@""];
            }
            [[state world] setCommandHistoryPoint:-1];
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
