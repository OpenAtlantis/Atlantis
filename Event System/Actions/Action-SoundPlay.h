//
//  Action-SoundPlay.h
//  Atlantis
//
//  Created by Rachel Blackman on 4/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_SoundPlay : BaseAction {

    NSMovie                     *_rdSound;
    NSString                    *_rdSoundFilename;
    
    IBOutlet NSView             *_rdInternalConfigurationView;
    IBOutlet NSTextField        *_rdSoundFilenameField;

    BOOL                         _rdPanelIsOpen;

}

- (IBAction) browseForFile:(id) sender;

@end
