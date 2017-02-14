//
//  MCPEditHandler.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "MCPEditHandler.h"
#import "MCPLocalEditor.h"
#import "AtlantisState.h"
#import "MCPMessage.h"

@implementation MCPEditHandler

- (float) minVersion:(NSString *)namespace
{
    return 1.0;
}

- (float) maxVersion:(NSString *)namespace
{
    return 1.0;
}

- (void) handleMessage:(MCPMessage *)message withState:(AtlantisState *)state
{
    MCPLocalEditor *localEdit = [[MCPLocalEditor alloc] initForMessage:message withWorld:[state world]];
    // [[RDAtlantisMainController controller] addLocalEditor:localEdit];
    // [localEdit release];
}


@end
