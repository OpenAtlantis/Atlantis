//
//  Action-LogpanelOpen.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-LogpanelOpen.h"
#import "RDLogOpener.h"

@implementation Action_LogpanelOpen

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Log: Open Logfile Panel";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Open a panel to select a logfile and format to save to.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    RDLogOpener *opener = [[RDLogOpener alloc] initWithState:state];
    [opener openPanel];

    return NO;
}


@end
