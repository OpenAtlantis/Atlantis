//
//  ToolbarWorldStatusController.h
//  Atlantis
//
//  Created by Rachel Blackman on 9/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AtlantisState;
@class RDAtlantisWorldInstance;

@interface ToolbarWorldStatusController : NSObject {

    IBOutlet NSView         *_rdStatusView;
    IBOutlet NSTextField    *_rdConnectedString;
    IBOutlet NSButton       *_rdSSLButton;
    IBOutlet NSButton       *_rdMCCPButton;
    IBOutlet NSButton       *_rdMCPButton;

}

- (NSView *) contentView;

- (IBAction) buttonPushed:(id) sender;
- (void) updateForWorld:(RDAtlantisWorldInstance *)world;
- (void) updateForState:(AtlantisState *)state;

@end
