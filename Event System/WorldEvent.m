//
//  WorldEvent.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/7/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldEvent.h"
#import "AtlantisState.h"

@implementation WorldEvent

- (id) init
{
    self = [super init];
    if (self) {
        _rdLastFired = [[NSMutableDictionary alloc] init];    
    }
    return self;
}

- (void) dealloc
{
    [_rdLastFired release];
    [super dealloc];
}

- (BOOL) shouldExecute:(AtlantisState *) state
{
    if (_rdLastFired) {
        NSDate *tempDate = [_rdLastFired objectForKey:[state extraDataForKey:@"world.name"]];
        if (tempDate)
            [state setExtraData:tempDate forKey:@"RDLastFired"];
        else
            [state setExtraData:[NSDate distantPast] forKey:@"RDLastFired"];
    }

    return [super shouldExecute:state];
}

- (void) executeForState:(AtlantisState *) state
{
    [super executeForState:state];
    
    if (_rdLastFired)
        [_rdLastFired setObject:[NSDate date] forKey:[state extraDataForKey:@"world.name"]];
}

@end
