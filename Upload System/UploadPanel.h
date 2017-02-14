//
//  UploadPanel.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/28/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AtlantisState;

@interface UploadPanel : NSObject {

    IBOutlet NSView                     *_rdOptionsView;
    IBOutlet NSButton                   *_rdCodeButton;
    IBOutlet NSTextField                *_rdDelayField;
    IBOutlet NSTextField                *_rdPrefixField;
    IBOutlet NSTextField                *_rdSuffixField;

    AtlantisState                       *_rdState;
    
    NSOpenPanel                         *_rdPanel;
    
}

- (IBAction) codeToggled:(id) sender;

- (id) initWithState:(AtlantisState *)state;
- (BOOL) openPanel;

@end
