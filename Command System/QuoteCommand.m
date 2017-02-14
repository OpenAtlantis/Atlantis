//
//  QuoteCommand.m
//  Atlantis
//
//  Created by Rachel Blackman on 5/21/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "QuoteCommand.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"
#import "TextfileUploader.h"

@implementation QuoteCommand

- (NSString *) checkOptionsForState:(AtlantisState *) state
{
    NSDictionary *commandParams = [state extraDataForKey:@"RDCommandParams"];
    
    NSString *target = [commandParams objectForKey:@"RDOptsMainData"];
    
    if (!target) {
        return @"quote command expects a parameter!";
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
    NSString *prefix = [commandParams objectForKey:@"prefix"];
    NSString *suffix = [commandParams objectForKey:@"suffix"];
    NSString *timerInterval = [commandParams objectForKey:@"delay"];
    
    NSTimeInterval timerLen = 1;
    
    if (timerInterval) {
        timerLen = [timerInterval intValue];
    }

    if (!target) {
        [[state world] outputStatus:@"No file specified for quote." toSpawn:[state spawnPath]];
        return;
    }

    TextfileUploader *quoteEngine =
        [[TextfileUploader alloc] initWithFile:[target stringByExpandingTildeInPath] forWorld:[state world] atInterval:timerLen withPrefix:prefix suffix:suffix];
    
    if (quoteEngine)    
        [[state world] outputStatus:[NSString stringWithFormat:@"Uploading '%@'", target] toSpawn:[state spawnPath]];
    else
        [[state world] outputStatus:@"Error in upload engine!" toSpawn:[state spawnPath]];
}


@end
