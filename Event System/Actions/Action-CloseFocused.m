//
//  Action-CloseFocused.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/28/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-CloseFocused.h"
#import "RDAtlantisSpawn.h"
#import <Lemuria/Lemuria.h>
#import "AtlantisState.h"

@implementation Action_CloseFocused

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Window: Close Current Focused Element";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Close the currently open spawn, or the window if there are no spawns.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    if ([[NSApp keyWindow] isKindOfClass:[RDNestedViewWindow class]]) {
        id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];

        if (curView) {
            [[RDNestedViewManager manager] viewRequestedClose:curView];
        }
        else
            [[NSApp keyWindow] performClose:self];    
    }
    else if ([NSApp keyWindow]) {
        [[NSApp keyWindow] performClose:self];
    }

    return NO;
}



@end
