//
//  Action-SetTempVar.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/15/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_SetTempVar : BaseAction <NSTextFieldDelegate> {

    IBOutlet NSTextField            *_rdVariableNameField;
    IBOutlet NSTextField            *_rdVariableValueField;
    
    IBOutlet NSPopUpButton          *_rdVariableTypeField;
    
    IBOutlet NSView                 *_rdInternalConfigurationView;

    NSString                        *_rdVariableName;
    NSString                        *_rdVariableValue;
    NSNumber                        *_rdVariableType;

}


@end
