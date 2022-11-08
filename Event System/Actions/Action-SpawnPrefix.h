//
//  Action-SpawnPrefix.h
//  Atlantis
//
//  Created by Rachel Blackman on 12/21/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_SpawnPrefix : BaseAction <NSTextFieldDelegate> {

    NSString                    *_rdSpawnPath;
    NSString                    *_rdSpawnPrefix;

    IBOutlet NSView             *_rdInternalConfigurationView;
    IBOutlet NSTextField        *_rdSpawnPathField;
    IBOutlet NSTextField        *_rdSpawnPrefixField;

}

@end
