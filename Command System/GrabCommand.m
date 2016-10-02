//
//  GrabCommand.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "GrabCommand.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation GrabCommand

- (NSString *) checkOptionsForState:(AtlantisState *) state
{
    NSDictionary *commandParams = [state extraDataForKey:@"RDCommandParams"];
    
    NSString *target = [commandParams objectForKey:@"RDOptsMainData"];
    
    if (!target) {
        return @"Grab command expects a parameter!";
    }
    else if ([commandParams count] > 2) {
        return @"Grab command expects only one parameter!";
    }
    
    NSRange findSlash = [target rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    if (findSlash.location == NSNotFound)
        return @"Grab command expects a parameter in the form 'object/attribute'!";
    
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

    NSString *object;
    NSString *attribute;

    NSRange findSlash = [target rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    object = [target substringToIndex:findSlash.location];
    attribute = [target substringFromIndex:findSlash.location + 1];    
    
    BOOL rhost = [[[state world] preferenceForKey:@"atlantis.world.rhost"] boolValue];
    
    NSString *grabOutputString = [NSString stringWithFormat:@"@pemit%@ %%#=1234%@ %@ %@=[edit(get(%@/%@),%%r,%%%%r)]", rhost ? @"/noansi" : @"", grabPass, attribute, object, object, attribute];
    [[state world] sendString:grabOutputString];
}


@end
