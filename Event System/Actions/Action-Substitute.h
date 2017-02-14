//
//  Action-Substitute.h
//  Atlantis
//
//  Created by Rachel Blackman on 9/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_Substitute : BaseAction {

    int                      _rdRegister;
    NSString                *_rdReplaceWith;
    
    IBOutlet NSView         *_rdInternalConfigurationView;
    IBOutlet NSTextField    *_rdRegisterField;
    IBOutlet NSTextField    *_rdSubstitutionField;

}

@end
