//
//  Action-NextSpawn.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-NextSpawn.h"
#import <Lemuria/Lemuria.h>

@implementation Action_NextSpawn

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Spawn: Next Active Spawn";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Change focus to the next spawn with unseen activity.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    if (![[RDNestedViewManager manager] selectNextActiveView])
        NSBeep();
        
    return NO;
}

@end
