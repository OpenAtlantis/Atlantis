//
//  WaitCommand.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/8/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "WaitCommand.h"
#import "Action-WorldSend.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation WaitCommand

- (NSString *) checkOptionsForState:(AtlantisState *) state
{
    NSDictionary *commandParams = [state extraDataForKey:@"RDCommandParams"];
    
    NSString *target = [commandParams objectForKey:@"RDOptsMainData"];
    
    if (!target) {
        return @"Wait command expects a parameter!";
    }
    
    NSArray *words = [target componentsSeparatedByString:@" "];
    if ([words count] < 2) {
        return @"Wait command expects a duration and a command!";
    } 
    NSString *first = [words objectAtIndex:0];
    if (![first intValue]) {
        return @"Wait command expects a duration and a command!";        
    }
    
    return nil;
}

- (void) executeForState:(AtlantisState *) state
{
    NSDictionary *commandParams = [state extraDataForKey:@"RDCommandParams"];
    
    NSString *target = [commandParams objectForKey:@"RDOptsMainData"];    
    NSString *first = [[target componentsSeparatedByString:@" "] objectAtIndex:0];
    
    NSString *command = [target substringFromIndex:[first length]];

    Action_WorldSend *action = [[Action_WorldSend alloc] initWithString:command];
    [[state world] addQueuedAction:action withDelay:[first intValue]];
    [action release];
}


@end
