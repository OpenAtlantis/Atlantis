//
//  RDHTMLLog.h
//  Atlantis
//
//  Created by Rachel Blackman on 4/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDLogType.h"

@interface RDHTMLLog : RDLogType {

    IBOutlet NSWindow *             _rdConfigWindow;

    IBOutlet NSButton *            _rdCssEnabled;
    IBOutlet NSTextField *         _rdCssFilename;

    IBOutlet NSButton *            _rdHeaderEnabled;
    IBOutlet NSTextView *          _rdHeaderData;
    
    IBOutlet NSButton *            _rdFooterEnabled;
    IBOutlet NSTextView *          _rdFooterData;
    
    IBOutlet NSButton *            _rdTitleEnabled;
    IBOutlet NSTextField *         _rdTitle;
    
    IBOutlet NSButton *            _rdNbspSpaceEnabled;

}

- (IBAction) cssToggled:(id) sender;
- (IBAction) headerToggled:(id) sender;
- (IBAction) footerToggled:(id) sender;
- (IBAction) titleToggled:(id) sender;
- (IBAction) makeDefaults:(id) sender;
- (IBAction) okButton:(id) sender;
- (IBAction) cancelButton: (id) sender;

@end
