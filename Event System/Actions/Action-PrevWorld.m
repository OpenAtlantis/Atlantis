//
//  Action-PrevWorld.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/15/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-PrevWorld.h"
#import <Lemuria/Lemuria.h>

@implementation Action_PrevWorld


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Spawn: Prev Spawn in Window";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Move to the previous spawn in the current window.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    BOOL handled = NO;

    NSWindow *window = [NSApp keyWindow];
    if (window && [window isKindOfClass:[RDNestedViewWindow class]]) {
        id <RDNestedViewDisplay> display = [(RDNestedViewWindow *)window displayView];
        if (display) {
            id <RDNestedViewDescriptor> prevView = [display previousView];
            
            if (prevView) {
                handled = YES;
                [[RDNestedViewManager manager] selectView:prevView];
            }
        }
    }

    if (!handled)
        NSBeep();

    return NO;
}

@end
