//
//  Action-PerlEval.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/13/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_PerlEval : BaseAction <NSTextViewDelegate> {

    IBOutlet NSView         *_rdInternalConfigurationView;
    IBOutlet NSTextView     *_rdActualText;
    IBOutlet NSPopUpButton  *_rdScriptLanguages;
    
    NSString                *_rdLanguage;
    NSString                *_rdString;

}

@end
