//
//  Action-CloseLogs.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/18/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-CloseLogs.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation Action_CloseLogs


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Log: Close All Logs in World";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Close all logs in the active world, without prompting.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeEvent) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    if ([state world]) {
        [[state world] closeAllLogfiles];
    }
    return NO;
}



@end
