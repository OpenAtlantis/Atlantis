//
//  Action-TextSpawn.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/26/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_TextSpawn : BaseAction <NSTextFieldDelegate> {

    NSString                    *_rdSpawnPath;
    BOOL                         _rdCopyText;

    IBOutlet NSView             *_rdInternalConfigurationView;
    IBOutlet NSTextField        *_rdSpawnPathField;
    IBOutlet NSPopUpButton      *_rdCopyTextButton;

}

- (IBAction) copyMoveChanged:(id) sender;

@end
