//
//  ToolbarSearchController.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/28/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDTextField.h"

@interface ToolbarSearchController : NSObject {

    IBOutlet NSView *               _rdSearchView;
    IBOutlet RDTextField *          _rdSearchField;

}

- (void) controlTextDidCommitText:(NSNotification *) notification;
- (void) cancelButtonClicked:(id) sender;

- (NSView *) contentView;

@end
