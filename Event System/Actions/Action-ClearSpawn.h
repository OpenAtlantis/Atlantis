//
//  Action-ClearSpawn.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_ClearSpawn : BaseAction <NSTextFieldDelegate> {

    NSString                    *_rdTarget;
    
    IBOutlet NSView             *_rdInternalConfigurationView;
    IBOutlet NSTextField        *_rdActualTargetSpawn;

}

@end
