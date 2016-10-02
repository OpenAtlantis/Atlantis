//
//  RDFormattedText.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/14/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDLogType.h"

@interface RDFormattedText : RDLogType {

    /* Options thingie */
    IBOutlet NSWindow                   *_rdConfigWindow;
    IBOutlet NSButton                   *_rdWordWrap;
    IBOutlet NSButton                   *_rdSkipLines;
    IBOutlet NSButton                   *_rdCondenseLines;
    IBOutlet NSTextField                *_rdIndentField;
    IBOutlet NSTextField                *_rdCharactersField;

}

- (IBAction) skipToggled:(id) sender;
- (IBAction) wrapToggled:(id) sender;
- (IBAction) makeDefaults:(id) sender;
- (IBAction) okButton:(id) sender;
- (IBAction) cancelButton: (id) sender;

@end
