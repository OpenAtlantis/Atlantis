//
//  Action-SpawnClose.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/26/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-SpawnClose.h"
#import "AtlantisState.h"
#import "RDAtlantisSpawn.h"
#import <Lemuria/Lemuria.h>

@implementation Action_SpawnClose

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Spawn: Close Current Spawn";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Close the currently active spawn.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeEvent) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];

    if (curView) {
        [[RDNestedViewManager manager] viewRequestedClose:curView];
    }    

    return NO;
}


@end
