//
//  AtlantisPreferenceController.h
//  Atlantis
//
//  Created by Rachel Blackman on 4/3/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AtlantisPreferencePane.h"

@interface AtlantisPreferenceController : NSWindowController {

    NSWindow                *_rdPrefsWindow;
    NSMutableDictionary     *_rdPreferencePanes;
    NSMutableArray          *_rdPreferenceOrder;
    NSMutableDictionary     *_rdToolbarItems;
    
    id <AtlantisPreferencePane> _rdLastPane;

}

- (void) addPane:(id <AtlantisPreferencePane>)pane;
- (void) showPreferences;



@end
