//
//  Action-GlobalDisconnect.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/16/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-GlobalDisconnect.h"
#import "RDAtlantisMainController.h"
#import "RDAtlantisWorldInstance.h"

@implementation Action_GlobalDisconnect

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Connection: Disconnect All Worlds";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Disconnect all connected worlds.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeEvent) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSEnumerator *worldEnum = [[RDAtlantisMainController controller] worldWalk];

    RDAtlantisWorldInstance *world;
    
    while (world = [worldEnum nextObject]) {
        if ([world isConnected]) {
            [world disconnectWithMessage:@"Disconnected by user event."];
        }
    }

    return NO;}



@end
