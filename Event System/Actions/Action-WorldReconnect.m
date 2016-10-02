//
//  Action-WorldReconnect.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-WorldReconnect.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"


@implementation Action_WorldReconnect

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Connection: Reconnect";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Reconnect the current connection, if it's disconnected.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeEvent) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    if ([state world] && ![[state world] isConnected])
        [[state world] connect];

    return NO;
}


@end
