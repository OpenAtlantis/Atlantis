//
//  UlCommand.m
//  Atlantis
//
//  Created by Rachel Blackman on 5/21/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "UlCommand.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"
#import "CodeUploader.h"

@implementation UlCommand

- (NSString *) checkOptionsForState:(AtlantisState *) state
{
    NSDictionary *commandParams = [state extraDataForKey:@"RDCommandParams"];
    
    NSString *target = [commandParams objectForKey:@"RDOptsMainData"];
    
    if (!target) {
        return @"ul command expects a parameter!";
    }
 
    NSFileManager *fileman = [NSFileManager defaultManager];
    
    if (![fileman fileExistsAtPath:[target stringByExpandingTildeInPath]]) {
        return [NSString stringWithFormat:@"No such file '%@'!", target];
    }
       
    return nil;
}

- (void) executeForState:(AtlantisState *) state
{
    NSDictionary *commandParams = [state extraDataForKey:@"RDCommandParams"];    
    NSString *target = [commandParams objectForKey:@"RDOptsMainData"];

    if (!target) {
        [[state world] outputStatus:@"No file specified.  Type: /ul <filename>" toSpawn:[state spawnPath]];
        return;
    }

    CodeUploader *ulEngine =
        [[CodeUploader alloc] initWithFile:[target stringByExpandingTildeInPath] forWorld:[state world] atInterval:0 withPrefix:nil suffix:nil];
        
    if (ulEngine)    
        [[state world] outputStatus:[NSString stringWithFormat:@"Uploading '%@'", target] toSpawn:[state spawnPath]];
    else
        [[state world] outputStatus:@"Error in upload engine!" toSpawn:[state spawnPath]];
}

@end
