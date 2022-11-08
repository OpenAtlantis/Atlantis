//
//  WorldInfoEditor.h
//  Atlantis
//
//  Created by Rachel Blackman on 9/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WorldConfigurationTab.h"

@interface WorldInfoEditor : WorldConfigurationTab <NSTextViewDelegate, NSTextFieldDelegate> {

    IBOutlet NSView                  *_rdConfigView;
    
    IBOutlet NSTextView              *_rdDescription;
    IBOutlet NSTextField             *_rdWebsite;
    
    IBOutlet NSImageView             *_rdIconWell;
    
    IBOutlet NSButton                *_rdIconOverride;

}

- (IBAction) launchWebsite:(id) sender;

@end
