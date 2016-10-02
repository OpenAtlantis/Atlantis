//
//  MCPDispatch.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "MCPDispatch.h"
#import "MCPMessage.h"
#import "MCPHandler.h"

@implementation MCPDispatch

- (id) init
{
    self = [super init];
    if (self) {
        _rdHandlers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [_rdHandlers release];
    [super dealloc];
}

- (void) registerHandler:(MCPHandler *)handler forNamespace:(NSString *)namespace
{
    [_rdHandlers setObject:handler forKey:namespace];
}

- (NSArray *) handlers
{
    return [_rdHandlers allValues];
}

- (NSArray *) namespaces
{
    return [_rdHandlers allKeys];
}

- (MCPHandler *) handlerForNamespace:(NSString *)namespace
{
    return [_rdHandlers objectForKey:namespace];
}

- (void) dispatchMessage:(MCPMessage *)message forState:(AtlantisState *)state
{
    MCPHandler *handler = [_rdHandlers objectForKey:[message namespace]];
    if (handler) {
        [handler handleMessage:message withState:state];
    }
}


@end
