//
//  Condition-CharConnected.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/17/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "Condition-CharConnected.h"
#import "AtlantisState.h"

@implementation Condition_CharConnected


#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"World: Login was Just Sent";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"The character login/password has just been sent to the world.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeEvent)
        return [NSNumber numberWithBool:YES];

    return [NSNumber numberWithBool:NO];
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    NSString *statechange = [state extraDataForKey:@"event.statechange"];

    if (statechange)
        if ([statechange caseInsensitiveCompare:@"charlogin"] == NSOrderedSame)
            return YES;

    return NO;
}



@end
