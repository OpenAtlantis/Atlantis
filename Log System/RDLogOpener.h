//
//  RDLogOpener.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/15/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AtlantisState.h"

@class RDHotkeyState;

@interface RDLogOpener : NSObject {

    IBOutlet NSPopUpButton              *_rdLogTypes;
    IBOutlet NSButton                   *_rdSpawnOnlyButton;
    IBOutlet NSButton                   *_rdScrollbackButton;
    IBOutlet NSButton                   *_rdTimestampButton;
    
    IBOutlet NSView                     *_rdOptionsView;
    IBOutlet NSButton                   *_rdOptionsButton;
    
    AtlantisState                       *_rdState;
    
    NSSavePanel                         *_rdSavePanel;
    NSString                            *_rdTempFilename;

    NSDictionary                        *_rdCurrentOptions;

}

- (id) initWithState:(AtlantisState *) state;
- (id) initWithHotkeyState:(RDHotkeyState *)state;

- (BOOL) openPanel;

- (IBAction) logTypeChanged:(id) sender;
- (IBAction) logTypeOptions:(id) sender;

@end
