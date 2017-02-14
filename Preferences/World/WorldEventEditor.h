//
//  WorldEventEditor.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EventEditor.h"
#import "EventCollection.h"
#import "WorldConfigurationTab.h"

@interface WorldEventEditor : WorldConfigurationTab {

    EventCollection             *_rdEvents;
    EventEditor                 *_rdEventEditor;

}


@end
