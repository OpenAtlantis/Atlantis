//
//  Condition-ComputerIdle.h
//  Atlantis
//
//  Created by Rachel Blackman on 4/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseCondition.h"

@interface Condition_ComputerIdle : BaseCondition <NSTextFieldDelegate> {

    NSTimeInterval              _rdInterval;

    IBOutlet NSView *           _rdInternalConfigurationView;
    IBOutlet NSTextField *      _rdActualText;

}

@end
