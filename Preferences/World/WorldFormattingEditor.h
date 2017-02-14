//
//  WorldFormattingEditor.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/11/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WorldConfigurationTab.h"

@interface WorldFormattingEditor : WorldConfigurationTab {

    IBOutlet NSView             *_rdConfigView;
    
    IBOutlet NSButton           *_rdAnsiDefaults;
    IBOutlet NSColorWell        *_rdAnsiColor00;
    IBOutlet NSColorWell        *_rdAnsiColor01;
    IBOutlet NSColorWell        *_rdAnsiColor02;
    IBOutlet NSColorWell        *_rdAnsiColor03;
    IBOutlet NSColorWell        *_rdAnsiColor04;
    IBOutlet NSColorWell        *_rdAnsiColor05;
    IBOutlet NSColorWell        *_rdAnsiColor06;
    IBOutlet NSColorWell        *_rdAnsiColor07;
    IBOutlet NSColorWell        *_rdAnsiColor08;
    IBOutlet NSColorWell        *_rdAnsiColor09;
    IBOutlet NSColorWell        *_rdAnsiColor10;
    IBOutlet NSColorWell        *_rdAnsiColor11;
    IBOutlet NSColorWell        *_rdAnsiColor12;
    IBOutlet NSColorWell        *_rdAnsiColor13;
    IBOutlet NSColorWell        *_rdAnsiColor14;
    IBOutlet NSColorWell        *_rdAnsiColor15;
    
    IBOutlet NSButton           *_rdAnsiBolding;

    IBOutlet NSColorWell        *_rdConsoleColor;
    IBOutlet NSColorWell        *_rdUrlColor;
    IBOutlet NSColorWell        *_rdBackgroundColor;
    IBOutlet NSColorWell        *_rdForegroundColor;
    IBOutlet NSColorWell        *_rdSelectionColor;

    IBOutlet NSButton           *_rdFontDefault;
    IBOutlet NSTextField        *_rdFontName;
    IBOutlet NSButton           *_rdFontChange;
    NSFont                      *_rdFont;
    
    IBOutlet NSButton           *_rdIndentDefault;
    IBOutlet NSTextField        *_rdIndent;
    IBOutlet NSStepper          *_rdIndentStepper;
    
    IBOutlet NSButton           *_rdLocalEchoDefault;
    IBOutlet NSButton           *_rdLocalEcho;
    IBOutlet NSTextField        *_rdLocalEchoPrefix;
    IBOutlet NSButton           *_rdTimestamps;
    
    IBOutlet NSButton           *_rdCodepageDefault;
    IBOutlet NSPopUpButton      *_rdCodepage;
    
    IBOutlet NSButton           *_rdGrabpassDefault;
    IBOutlet NSTextField        *_rdGrabpass;
    IBOutlet NSButton           *_rdRhost;
    
    IBOutlet NSPopUpButton      *_rdLinefeedType;
    
    BOOL                         _rdGlobal;
}

- (IBAction) chooseFont:(id) sender;
- (IBAction) chooseCodepage:(id) sender;
- (IBAction) chooseLinefeed:(id) sender;

- (IBAction) toggleDefault:(id) sender;
- (IBAction) colorWasSet:(id)sender;

@end
