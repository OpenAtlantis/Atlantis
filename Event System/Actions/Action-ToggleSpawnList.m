//
//  Action-ToggleSpawnList.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/17/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-ToggleSpawnList.h"
#import <Lemuria/Lemuria.h>

@implementation Action_ToggleSpawnList


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Window: Show/Hide Spawn List";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Show or hide the spawn list in the current window.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSWindow *window = [NSApp keyWindow];
    
    if ([window isKindOfClass:[RDNestedViewWindow class]]) {
        id <RDNestedViewDisplay> display = [(RDNestedViewWindow *)window displayView];
        
        if ([display isViewListCollapsed]) {
            [display expandViewList];
        }
        else {
            [display collapseViewList];
        }
    }
    else
        NSBeep();

    return NO;
}



@end
