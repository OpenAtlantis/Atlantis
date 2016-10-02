//
//  Action-StatusBarDisplay
//  Atlantis
//
//  Created by Rachel Blackman on 6/28/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "Action-StatusBarDisplay.h"
#import "RDAtlantisSpawn.h"
#import "RDAtlantisWorldInstance.h"
#import "AtlantisState.h"

@implementation Action_StatusBarDisplay

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Spawn: Toggle Status Bar Visibility";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Toggle whether the status bar for a given spawn is visible or not.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    RDAtlantisSpawn *spawn = [state spawn];
    RDAtlantisWorldInstance *world = [state world];
    if (spawn && world) {
        [world hideStatusBar:![spawn statusBarHidden] forSpawnPath:[spawn internalPath]];
    }
    else 
        NSBeep();
    
    return NO;
}




@end
