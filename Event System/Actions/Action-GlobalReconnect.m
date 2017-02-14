//
//  Action-GlobalReconnect.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/12/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "Action-GlobalReconnect.h"
#import "RDAtlantisMainController.h"
#import "RDAtlantisWorldInstance.h"

@implementation Action_GlobalReconnect

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Connection: Reconnect All Worlds";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Reconnect all worlds.";
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
        if (![world isConnected]) {
            [world connect];
        }
    }

    return NO;
}


@end
