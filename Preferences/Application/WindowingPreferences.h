//
//  WindowingPreferences.h
//  Atlantis
//
//  Created by Rachel Blackman on 4/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AtlantisPreferencePane.h"

@interface WindowingPreferences : NSObject <AtlantisPreferencePane> {

    IBOutlet NSView                     *_rdConfigView;

    IBOutlet NSButton                   *_rdDragEnabled;

    IBOutlet NSButton                   *_rdBottomSpawn;
    IBOutlet NSButton                   *_rdKillSpawn;

    
    IBOutlet NSButtonCell               *_rdDefaultGrouping;
    IBOutlet NSButtonCell               *_rdOneGrouping;
    IBOutlet NSButtonCell               *_rdScatterGrouping;
    
    IBOutlet NSButton                   *_rdOutlineStyle;
    IBOutlet NSButton                   *_rdTabbedStyle;
    IBOutlet NSButton                   *_rdSourceStyle;

    IBOutlet NSButton                   *_rdSmallIcons;
}



@end
