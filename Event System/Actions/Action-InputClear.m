//
//  Action-InputClear.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-InputClear.h"
#import "AtlantisState.h"

@implementation Action_InputClear

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Input: Clear Input Window";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Clear the current input window.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    [state textToInput:@""];
    return NO;
}


@end
