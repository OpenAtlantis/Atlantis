//
//  Action-WorldDisconnect.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-WorldDisconnect.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"


@implementation Action_WorldDisconnect

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Connection: Disconnect";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Disconnect the current connection, if it is connected.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeEvent) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    if ([state world] && [[state world] isConnecting])
        [[state world] disconnectWithMessage:@"Disconnected by user event."];

    return NO;
}


@end
