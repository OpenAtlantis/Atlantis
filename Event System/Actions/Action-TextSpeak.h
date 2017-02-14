//
//  Action-TextSpeak.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/29/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_TextSpeak : BaseAction {

    IBOutlet NSView         *_rdInternalConfigurationView;
    IBOutlet NSTextField    *_rdActualText;
    
    NSString                *_rdString;
    NSSpeechSynthesizer     *_rdSpeaker;

}

@end
