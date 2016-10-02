//
//  Action-Beep.m
//  Atlantis
//
//  Created by Rachel Blackman on 8/18/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-Beep.h"


@implementation Action_Beep

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Atlantis: Beep";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Trigger the system 'beep' noise (or screen flash).";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    return [NSNumber numberWithBool:YES];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSBeep();
    
    return NO;
}



@end
