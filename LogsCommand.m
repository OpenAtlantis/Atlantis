//
//  LogsCommand.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/30/11.
//  Copyright 2011 Riverdark Studios. All rights reserved.
//

#import "LogsCommand.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation LogsCommand

- (NSString *) checkOptionsForState:(AtlantisState *) state
{
    return nil;
}

- (void) executeForState:(AtlantisState *) state
{
    RDAtlantisWorldInstance *world = [state world];
    NSArray *logs = [world logfiles];
    
    if ([logs count]) {
        RDLogType *log;
        NSEnumerator *logEnum = [logs objectEnumerator];

        while (log = [logEnum nextObject]) {
            NSString *targetName = nil;
            if ([log spawnPath]) {
                if ([[log spawnPath] length])
                    targetName = [NSString stringWithFormat:@"Logging spawn %@ to", [log spawnPath]];
                else
                    targetName = [NSString stringWithFormat:@"Logging root spawn to"];
            }
            else {
                targetName = [NSString stringWithFormat:@"Logging world to"];
            }
            NSString *tempString = [NSString stringWithFormat:@"%@ %@", targetName, [log filename]];
            [[state world] outputStatus:tempString toSpawn:[state spawnPath]];
        }
    }
    else {
        [[state world] outputStatus:[NSString stringWithFormat:@"No logs open for %@", [[state world] basePath]] toSpawn:[state spawnPath]];
    }
}

@end
