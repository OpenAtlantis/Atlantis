//
//  Action-SpawnFocus.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_SpawnFocus : BaseAction <NSTextFieldDelegate> {

    NSString                    *_rdSpawnPath;
    
    IBOutlet NSView             *_rdInternalConfigurationView;
    IBOutlet NSTextField        *_rdActualText;

}

- (id) initWithPath:(NSString *) path;

@end
