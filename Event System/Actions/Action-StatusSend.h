//
//  Action-StatusSend.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/25/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_StatusSend : BaseAction <NSTextFieldDelegate> {

    NSString                    *_rdString;
    NSString                    *_rdTarget;
    
    IBOutlet NSView             *_rdInternalConfigurationView;
    IBOutlet NSTextField        *_rdActualText;
    IBOutlet NSTextField        *_rdActualTargetSpawn;

}

@end
