//
//  GrabNameCommand.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "GrabNameCommand.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation GrabNameCommand

- (NSString *) checkOptionsForState:(AtlantisState *) state
{
    NSDictionary *commandParams = [state extraDataForKey:@"RDCommandParams"];
    
    NSString *target = [commandParams objectForKey:@"RDOptsMainData"];
    
    if (!target) {
        return @"Gname command expects a parameter!";
    }
    else if ([commandParams count] > 2) {
        return @"Gname command expects only one parameter!";
    }
    
    return nil;
}

- (void) executeForState:(AtlantisState *) state
{
    NSDictionary *commandParams = [state extraDataForKey:@"RDCommandParams"];    
    NSString *target = [commandParams objectForKey:@"RDOptsMainData"];
    NSString *grabPass = [[state world] preferenceForKey:@"atlantis.grab.password"];
    if (!grabPass) {
        grabPass = @"SimpleMUUser";
    }

    BOOL rhost = [[[state world] preferenceForKey:@"atlantis.world.rhost"] boolValue];
    
    NSString *grabOutputString = [NSString stringWithFormat:@"@pemit%@ %%#=1234%@ name %@=[fullname(%@)]", rhost ? @"/noansi" : @"", grabPass, target, target];
    [[state world] sendString:grabOutputString];
}

@end
