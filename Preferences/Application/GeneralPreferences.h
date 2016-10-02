//
//  GeneralPreferences.h
//  Atlantis
//
//  Created by Rachel Blackman on 4/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AtlantisPreferencePane.h"

@interface GeneralPreferences : NSObject <AtlantisPreferencePane> {

    IBOutlet  NSView                *_rdConfigView;

    IBOutlet  NSPopUpButton         *_rdBeepBehavior;

    IBOutlet  NSButton              *_rdCheckOnStartup;
    IBOutlet  NSButton              *_rdOpenAddressBook;
    IBOutlet  NSButton              *_rdDoubleConnect;
    
    IBOutlet  NSButton              *_rdFugueEnabled;
    IBOutlet  NSButton              *_rdClearInput;
    IBOutlet  NSButton              *_rdNoSlashies;
    IBOutlet  NSButton              *_rdSilentConvert;
    IBOutlet  NSButton              *_rdAutoShrink;
    IBOutlet  NSTextField           *_rdAutoShrinkLen;
    
    IBOutlet  NSButton              *_rdEasyShortcut;
    IBOutlet  NSButton              *_rdDockBadgeActive;
    IBOutlet  NSButton              *_rdDockBadgeHidden;

}

@end
