//
//  Action-ToggleDrag.m
//  Atlantis
//
//  Created by Rachel Blackman on 8/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-ToggleDrag.h"
#import "RDAtlantisSpawn.h"
#import "RDAtlantisWorldInstance.h"
#import "AtlantisState.h"


@implementation Action_ToggleDrag


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Window: Toggle Drag and Drop of Spawns";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Toggle whether or not drag-and-drop of spawns is allowed.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    BOOL dragDisallowed = [[NSUserDefaults standardUserDefaults] boolForKey:@"lemuria.dragging.disabled"];
    
    dragDisallowed = !dragDisallowed;
    
    [[NSUserDefaults standardUserDefaults] setBool:dragDisallowed forKey:@"lemuria.dragging.disabled"];
    
    if ([state spawn]) {
        [[state world] handleStatusOutput:[NSString stringWithFormat:@"Drag-and-drop of spawns is now %@.\n", (dragDisallowed ? @"disabled" : @"enabled")] onSpawn:[state spawn]];
    }
    
    return NO;
}

@end
