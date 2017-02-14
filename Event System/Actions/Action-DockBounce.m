//
//  Action-DockBounce.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/25/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-DockBounce.h"


@implementation Action_DockBounce


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Dock: Request User Attention";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"If Atlantis is not active, send an Information Request (usually bouncing the dock icon once) to get the user's attention.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeEvent)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    [NSApp requestUserAttention:NSInformationalRequest];

    return NO;
}



@end
