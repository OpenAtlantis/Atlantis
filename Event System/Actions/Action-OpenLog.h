//
//  Action-OpenLog.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/18/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_OpenLog : BaseAction {

    NSDictionary        *_rdOptions;
    NSString            *_rdLogType;
    NSString            *_rdPath;
    NSString            *_rdSpawnPath;
    BOOL                 _rdScrollback;
    BOOL                 _rdTimestamps;
    
    IBOutlet NSView         *_rdInternalConfigurationView;
    IBOutlet NSButton       *_rdOptionsButton;
    IBOutlet NSButton       *_rdSpawnEnabled;
    IBOutlet NSButton       *_rdTimestampsEnabled;
    IBOutlet NSPopUpButton  *_rdLogTypes;
    IBOutlet NSTextField    *_rdFilename;
    IBOutlet NSTextField    *_rdSpawnTextfield;
    IBOutlet NSButton       *_rdLogScrollback;

}

- (IBAction) logTypeChanged:(id) sender;
- (IBAction) spawnEnabledChanged: (id) sender;
- (IBAction) timestampsChanged: (id) sender;
- (IBAction) scrollbackEnabledChanged: (id) sender;
- (IBAction) optionsButton:(id) sender;

@end
