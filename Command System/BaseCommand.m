//
//  BaseCommand.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "BaseCommand.h"
#import "AtlantisState.h"

@implementation BaseCommand

- (NSString *) checkOptionsForState:(AtlantisState *) state
{
    return @"Cannot execute base command!";
}

- (void) executeForState:(AtlantisState *) state
{

}

@end
