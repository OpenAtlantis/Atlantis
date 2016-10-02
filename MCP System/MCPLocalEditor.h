//
//  MCPLocalEditor.h
//  Atlantis
//
//  Created by Rachel Blackman on 9/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MCPMessage;
@class RDAtlantisWorldInstance;

@interface MCPLocalEditor : NSWindowController {

    IBOutlet NSTextView                  *_rdTextEditor;
    
    IBOutlet NSButton                    *_rdSendButton;
    IBOutlet NSButton                    *_rdCancelButton;
    
    MCPMessage                           *_rdOriginMessage;
    RDAtlantisWorldInstance              *_rdWorld;

}

- (id) initForMessage:(MCPMessage *)message withWorld:(RDAtlantisWorldInstance *)world;

- (IBAction) send:(id) sender;
- (IBAction) cancel:(id) sender;

@end
