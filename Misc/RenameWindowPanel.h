//
//  RenameWindowPanel.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/14/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lemuria/Lemuria.h>

@interface RenameWindowPanel : NSWindowController {

    IBOutlet NSPanel            *_rdRenamePanel;
    IBOutlet NSTextField        *_rdRenameText;
    
    RDNestedViewWindow          *_rdWindow;
        
}

+ (RenameWindowPanel *) sharedPanel;

- (void) renameForWindow:(RDNestedViewWindow *) window;

- (IBAction) rename:(id) sender;
- (IBAction) cancel:(id) sender;

@end
