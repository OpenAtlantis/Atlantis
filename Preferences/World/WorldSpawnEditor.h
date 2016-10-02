//
//  WorldSpawnEditor.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WorldConfigurationTab.h"

@class WorldSpawnRecord;

@interface WorldSpawnEditor : WorldConfigurationTab {

    IBOutlet NSView             *_rdConfigView;
    
    IBOutlet NSOutlineView      *_rdSpawnList;

    IBOutlet NSButton           *_rdAddSpawn;
    IBOutlet NSButton           *_rdRemoveSpawn;

    IBOutlet NSTableView        *_rdPatternList;
    IBOutlet NSTableView        *_rdExceptionList;
    
    IBOutlet NSButton           *_rdAddPattern;
    IBOutlet NSButton           *_rdRemovePattern;
    
    IBOutlet NSButton           *_rdAddException;
    IBOutlet NSButton           *_rdRemoveException;
    
    IBOutlet NSTextField        *_rdPriority;
    IBOutlet NSStepper          *_rdPriorityStepper;
    IBOutlet NSButton           *_rdActivityButton;    
    IBOutlet NSButton           *_rdStatusbarButton;
    IBOutlet NSTextField        *_rdLineField;
    
    IBOutlet NSTextField        *_rdPrefixField;
    
    WorldSpawnRecord            *_rdRootSpawn;
}

- (IBAction) addSpawn:(id) sender;
- (IBAction) removeSpawn:(id) sender;

- (IBAction) priorityChanged:(id) sender;
- (IBAction) toggleActivity:(id) sender;
- (IBAction) toggleStatusBar:(id) sender;
- (IBAction) addPattern:(id) sender;
- (IBAction) removePattern:(id) sender;
- (IBAction) addException:(id) sender;
- (IBAction) removeException:(id) sender;

@end
