//
//  Action-TextOmitActivity.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/26/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-TextOmitActivity.h"
#import "AtlantisState.h"


@implementation Action_TextOmitActivity

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Text: Do Not Trigger Activity Notice";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Do not mark the current spawn as having activity.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeEvent)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    if (![state stringData])
        return NO;
    
    [[state stringData] addAttribute:@"RDActivityOmitLine" value:@"yes" range:NSMakeRange(0,[[state stringData] length])];
    
    return NO;
}


@end
