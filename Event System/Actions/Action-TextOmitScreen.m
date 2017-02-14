//
//  Action-TextOmitScreen.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/14/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-TextOmitScreen.h"
#import "AtlantisState.h"

@implementation Action_TextOmitScreen

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Text: Gag Line from Screen";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Do not display the current line of text in any spawns.";
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
    
    [[state stringData] addAttribute:@"RDScreenOmitLine" value:@"yes" range:NSMakeRange(0,[[state stringData] length])];
    
    return NO;
}


@end
