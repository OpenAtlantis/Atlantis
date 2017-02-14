//
//  MCPHandler.h
//  Atlantis
//
//  Created by Rachel Blackman on 9/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AtlantisState;
@class MCPMessage;

@interface MCPHandler : NSObject {

}

- (void) handleMessage:(MCPMessage *)message withState:(AtlantisState *)state;
- (float) minVersion:(NSString *)namespace;
- (float) maxVersion:(NSString *)namespace;

- (void) negotiated:(AtlantisState *)state;

@end
