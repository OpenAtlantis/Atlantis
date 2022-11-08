//
//  WorldUserconfEditor.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/19/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WorldConfigurationTab.h"

@interface WorldUserconfEditor : WorldConfigurationTab <NSTableViewDelegate, NSTableViewDataSource> {

    NSMutableDictionary             *_rdUserConf;
    NSMutableArray                  *_rdUserConfKeys;
    
    IBOutlet NSView                 *_rdConfigView;
    IBOutlet NSTableView            *_rdUserConfTable;
    
}

- (IBAction) addButton:(id) sender;
- (IBAction) deleteButton:(id) sender;

@end
