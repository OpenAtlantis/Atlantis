//
//  QuickConnectCommand.m
//  Atlantis
//
//  Created by Rachel Blackman on 8/19/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "QuickConnectCommand.h"
#import "AtlantisState.h"
#import "RDAtlantisMainController.h"

@implementation QuickConnectCommand

- (NSString *) checkOptionsForState:(AtlantisState *) state
{
    NSDictionary *commandParams = [state extraDataForKey:@"RDCommandParams"];
    
    NSString *target = [commandParams objectForKey:@"RDOptsMainData"];
    
    if (!target) {
        return @"qc command expects somewhere to connect to!";
    }
    
    NSArray *components = [target componentsSeparatedByString:@" "];
    if (!components || ([components count] != 2)) {
        return @"qc expects a parameter in the form 'host port'!";
    }
       
    return nil;
}

- (void) executeForState:(AtlantisState *) state
{
    NSDictionary *commandParams = [state extraDataForKey:@"RDCommandParams"];    
    NSString *target = [commandParams objectForKey:@"RDOptsMainData"];
    NSString *codebase = [commandParams objectForKey:@"server"];
    
    if (!target) {
        return;
    }
    
    NSArray *components = [target componentsSeparatedByString:@" "];
    if (!components || ([components count] != 2)) {
        return;
    }
    
    NSString *hostname = [components objectAtIndex:0];
    int port = [[components objectAtIndex:1] intValue];
    
    BOOL isMUSH = YES;
    
    if (codebase) {
        if ([[codebase lowercaseString] isEqualToString:@"mud"])
            isMUSH = NO;
    }
    
    [[RDAtlantisMainController controller] connectTemporaryWorld:hostname port:port mush:isMUSH];
}


@end
