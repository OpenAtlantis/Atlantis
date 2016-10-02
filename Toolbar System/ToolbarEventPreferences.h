//
//  ToolbarEventPreferences.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AtlantisPreferencePane.h"

@class ToolbarCollection;
@class EventEditor;

@interface ToolbarEventPreferences : NSObject <AtlantisPreferencePane> {

    EventEditor                  *_rdEventEditor;
    
    ToolbarCollection            *_rdToolbarCollection;

}

- (id) initForEvents:(ToolbarCollection *) collection;

@end
