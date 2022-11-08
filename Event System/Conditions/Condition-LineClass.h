//
//  Condition-LineClass.h
//  Atlantis
//
//  Created by Rachel Blackman on 6/20/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseCondition.h"

@interface Condition_LineClass : BaseCondition <NSTextFieldDelegate> {

    IBOutlet NSView         *_rdInternalConfigurationView;
    IBOutlet NSTextField    *_rdLineClassField;
    
    NSString                *_rdLineClass;

}

@end
