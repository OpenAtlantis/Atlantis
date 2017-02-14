//
//  Action-LogpanelClose.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-LogpanelClose.h"
#import "RDLogCloser.h"
#import "RDLogType.h"

@implementation Action_LogpanelClose

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Log: Close Logfile";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Close the active logfile (or present the close log panel if more than one log is running).";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSArray *logfiles = [[state world] logfiles];
    
    if ([logfiles count] == 0) {
        NSBeep();
        return NO;
    }
        
    if ([logfiles count] == 1) {
        RDLogType *log = [logfiles objectAtIndex:0];
        [log closeFile];
        [[state world] removeLogfile:log];
        return NO;
    }
    
    RDLogCloser *closer = [[RDLogCloser alloc] initWithState:state];
    [closer openPanel];
    
    return NO;
}


@end
