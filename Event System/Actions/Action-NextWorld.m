//
//  Action-NextWorld.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/15/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-NextWorld.h"
#import <Lemuria/Lemuria.h>

@implementation Action_NextWorld


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Spawn: Next Spawn in Window";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Move to the next spawn in the current window.";
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
            id <RDNestedViewDescriptor> nextView = [display nextView];
            
            if (nextView) {
                handled = YES;
                [[RDNestedViewManager manager] selectView:nextView];
            }
        }
    }

    if (!handled)
        NSBeep();

    return NO;
}



@end
