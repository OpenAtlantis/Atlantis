//
//  Action-TextOmitLog.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/14/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-TextOmitLog.h"
#import "AtlantisState.h"

@implementation Action_TextOmitLog

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Text: Gag Line from Logs";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Do not put the current line of text in any open logfiles.";
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
    
    [[state stringData] addAttribute:@"RDLogOmitLine" value:@"yes" range:NSMakeRange(0,[[state stringData] length])];
    
    return NO;
}


@end
