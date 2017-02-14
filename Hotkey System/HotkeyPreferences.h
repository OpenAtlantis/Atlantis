//
//  HotkeyPreferences.h
//  Atlantis
//
//  Created by Rachel Blackman on 4/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AtlantisPreferencePane.h"

@class EventEditor;
@class HotkeyCollection;


@interface HotkeyPreferences : NSObject <AtlantisPreferencePane> {

    EventEditor                 *_rdEventEditor;
    
    HotkeyCollection            *_rdHotkeyCollection;

}

- (id) initForCollection:(HotkeyCollection *) collection;

@end
