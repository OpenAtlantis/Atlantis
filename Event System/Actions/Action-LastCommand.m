//
//  Action-LastCommand.m
//  Atlantis
//
//  Created by Rachel Blackman on 6/8/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-LastCommand.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation Action_LastCommand


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Input: Repeat Last Command";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Re-send the last command sent to the world.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSArray *commands = [[state world] commandHistory];
    if ([commands count]) {
        NSString *lastCommand = [commands objectAtIndex:0];
        
        [state textToWorld:lastCommand];
    }
    else {
        NSBeep();
    }

    return NO;
}



@end
