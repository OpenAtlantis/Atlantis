//
//  MCPHandler.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "MCPHandler.h"
#import "AtlantisState.h"
#import "MCPMessage.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisMainController.h"
#import "MCPDispatch.h"

@implementation MCPHandler

- (float) minVersion:(NSString *)namespace
{
    return 2.1;
}

- (float) maxVersion:(NSString *)namespace
{
    return 2.1;
}

- (NSString *) packageName
{
    return @"mcp";
}

- (void) sendSupported:(RDAtlantisWorldInstance *)world
{
    NSString *mcpSessionKey = [world mcpSessionKey];

    MCPMessage *response = [[MCPMessage alloc] initWithNamespace:@"mcp" command:nil];
    [response addText:mcpSessionKey toAttribute:@"authentication-key"];
    [response addText:[NSString stringWithFormat:@"%.01f", [self minVersion:@"mcp"]] toAttribute:@"version"];
    [response addText:[NSString stringWithFormat:@"%.01f", [self maxVersion:@"mcp"]] toAttribute:@"to"];
    NSString *responseString = [response messageString];
    [world sendString:responseString];
    [response release];
    
    // Show our MCP-negotiate-can stuff
    NSEnumerator *handlerEnum = [[[[RDAtlantisMainController controller] mcpDispatch] namespaces] objectEnumerator];
    
    NSString *namespaceWalk = nil;
    NSString *mcpKey = [world mcpSessionKey];
    
    while (namespaceWalk = [handlerEnum nextObject]) {
        if (![namespaceWalk isEqualToString:@"mcp"]) {
            MCPHandler *mcpWalk = [[[RDAtlantisMainController controller] mcpDispatch] handlerForNamespace:namespaceWalk];
            MCPMessage *response = [[MCPMessage alloc] initWithNamespace:@"mcp-negotiate" command:@"can"];
            [response setSessionKey:mcpKey];
            [response addText:namespaceWalk toAttribute:@"package"];
            [response addText:[NSString stringWithFormat:@"%.01f", [mcpWalk minVersion:namespaceWalk]] toAttribute:@"min-version"];
            [response addText:[NSString stringWithFormat:@"%.01f", [mcpWalk maxVersion:namespaceWalk]] toAttribute:@"max-version"];
            NSString *messageString = [response messageString];
            [world sendString:messageString];
            [response release];
        }
    }
    
    MCPMessage *finalMessage = [[MCPMessage alloc] initWithNamespace:@"mcp-negotiate" command:@"end"];
    [finalMessage setSessionKey:mcpKey];
    [finalMessage addText:mcpKey toAttribute:@"mcp-negotiate-end"];
    NSString *finalString = [finalMessage messageString];
    [world sendString:finalString];
    [finalMessage release];    
}

- (void) handleMessage:(MCPMessage *)message withState:(AtlantisState *)state
{
    if ([[message namespace] isEqualToString:@"mcp"]) {
        NSString *remoteMinString = [message attributeText:@"version"];
        NSString *remoteMaxString = [message attributeText:@"to"];
    
        if (remoteMinString && remoteMaxString) {
            float remoteMin = [remoteMinString floatValue];
            float remoteMax = [remoteMaxString floatValue];
        
            BOOL supported = YES;
        
            if ((remoteMin > [self maxVersion:@"mcp"]) || (remoteMax < [self minVersion:@"mcp"]))
                supported = NO;
            
            if (supported) {
                [self performSelector:@selector(sendSupported:) withObject:[state world] afterDelay:1];
                [[state world] setMcpNegotiated:YES];
            }
        }
    }
}

- (void) negotiated:(AtlantisState *)state
{

}

@end
