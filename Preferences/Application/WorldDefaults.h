//
//  WorldDefaults.h
//  Atlantis
//
//  Created by Rachel Blackman on 4/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AtlantisPreferencePane.h"
#import "WorldConfigurationEditor.h"

@interface WorldDefaults : NSObject <AtlantisPreferencePane> {

    WorldConfigurationEditor        *_rdEditor;

}

@end
