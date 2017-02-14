//
//  Action-UploadpanelOpen.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/28/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-UploadpanelOpen.h"
#import "UploadPanel.h"

@implementation Action_UploadpanelOpen


+ (NSString *) actionName
{
    // TODO: Localize
    return @"World: Open Upload Panel";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Open a panel to select a file to upload to the world.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    UploadPanel *opener = [[UploadPanel alloc] initWithState:state];
    return [opener openPanel];
}


@end
