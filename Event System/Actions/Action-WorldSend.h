//
//  Action-WorldSend.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_WorldSend : BaseAction <NSTextFieldDelegate> {

    NSString                *_rdString;
    bool                     _rdSplitLines;
    
    IBOutlet NSView         *_rdInternalConfigurationView;
    IBOutlet NSTextField    *_rdActualText;
    IBOutlet NSButton       *_rdSplitLineToggle;

}

- (id) initWithString:(NSString *) string;
- (IBAction) lineSplitToggled:(id)sender;

@end
