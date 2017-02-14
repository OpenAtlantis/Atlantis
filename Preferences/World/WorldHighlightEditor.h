//
//  WorldHighlightEditor.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/11/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WorldConfigurationTab.h"

@interface WorldHighlightEditor : WorldConfigurationTab {

    IBOutlet NSView                     *_rdConfigView;

    IBOutlet NSTableView                *_rdHighlightsTable;
    IBOutlet NSTableColumn              *_rdHighlightTypeColumn;

    IBOutlet NSButton                   *_rdAddHighlightButton;
    IBOutlet NSButton                   *_rdRemoveHighlightButton;

    IBOutlet NSPopUpButton              *_rdHighlightTypeButton;
    IBOutlet NSTextField                *_rdHighlightPattern;
    IBOutlet NSButton                   *_rdHighlightUseFgButton;
    IBOutlet NSButton                   *_rdHighlightUseBgButton;
    IBOutlet NSColorWell                *_rdForegroundColorWell;
    IBOutlet NSColorWell                *_rdBackgroundColorWell;
    
    NSMutableArray                      *_rdHighlights;
    
    BOOL                                 _rdSelfUpdate;
    
}

- (IBAction) addHighlight:(id) sender;
- (IBAction) removeHighlight:(id) sender;
- (IBAction) toggleForeground:(id) sender;
- (IBAction) toggleBackground:(id) sender;
- (IBAction) changePatternType:(id) sender;
- (IBAction) changeColor:(id) sender;

@end
