//
//  Action-WindowClose.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/17/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-WindowClose.h"


@implementation Action_WindowClose


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Window: Close Current Window";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Close the currently active window.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    [[NSApp keyWindow] performClose:self];

    return NO;
}



@end
