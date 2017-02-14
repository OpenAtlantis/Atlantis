//
//  WorldAliasEditor.h
//  Atlantis
//
//  Created by Rachel Blackman on 4/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WorldConfigurationTab.h"

@class EventCollection;
@class EventEditor;

@interface WorldAliasEditor : WorldConfigurationTab {

    EventCollection             *_rdAliases;
    EventEditor                 *_rdEventEditor;

}

@end
