//
//  RDAtlantisFilter.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDAtlantisFilter.h"


@implementation RDAtlantisFilter

- (id) initWithWorld:(RDAtlantisWorldInstance *) world
{
    _rdWorld = world;
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (RDAtlantisWorldInstance *) world
{
    return _rdWorld;
}

- (void) filterInput:(id) input
{
    // Override this in subclasses
    return;
}

- (void) filterOutput:(id) output
{
    // Override this in subclasses
    return;
}

- (void) worldWasRefreshed
{
    return;
}

@end
