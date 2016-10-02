//
//  MCPNegotiateHandler.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "MCPNegotiateHandler.h"
#import "MCPMessage.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisMainController.h"
#import "MCPDispatch.h"

@implementation MCPNegotiateHandler


- (float) minVersion:(NSString *)namespace
{
    return 1.0;
}

- (float) maxVersion:(NSString *)namespace
{
    return 2.0;
}

- (void) handleMessage:(MCPMessage *)message withState:(AtlantisState *)state
{
    if ([[message command] isEqualToString:@"can"]) {
        NSString *package = [message attributeText:@"package"];
        NSString *minVersion = [message attributeText:@"min-version"];
        NSString *maxVersion = [message attributeText:@"max-version"];
        
        float minVersionF = [minVersion floatValue];
        float maxVersionF = [maxVersion floatValue];
        
        [[state world] addMcpPackage:package min:minVersionF max:maxVersionF];
    }
    else if ([[message command] isEqualToString:@"end"]) {
        // Show our MCP-negotiate-can stuff
        NSEnumerator *handlerEnum = [[[[RDAtlantisMainController controller] mcpDispatch] namespaces] objectEnumerator];
        
        NSString *namespaceWalk = nil;
        
        while (namespaceWalk = [handlerEnum nextObject]) {
            if (![namespaceWalk isEqualToString:@"mcp"] && [[state world] supportsMcpPackage:namespaceWalk]) {
                MCPHandler *mcpWalk = [[[RDAtlantisMainController controller] mcpDispatch] handlerForNamespace:namespaceWalk];
                [mcpWalk negotiated:state];
            }
        }
    }
}



@end
