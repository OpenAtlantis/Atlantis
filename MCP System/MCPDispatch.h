//
//  MCPDispatch.h
//  Atlantis
//
//  Created by Rachel Blackman on 9/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AtlantisState;
@class MCPHandler;
@class MCPMessage;

@interface MCPDispatch : NSObject {
    
    NSMutableDictionary             *_rdHandlers;
    NSMutableArray                  *_rdAllHandlers;
    
}

- (void) registerHandler:(MCPHandler *)handler forNamespace:(NSString *)namespace;
- (void) dispatchMessage:(MCPMessage *)message forState:(AtlantisState *)state;

- (NSArray *) handlers;
- (NSArray *) namespaces;
- (MCPHandler *) handlerForNamespace:(NSString *) namespace;

@end
