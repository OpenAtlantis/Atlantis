//
//  Condition-Timer.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/18/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseCondition.h"

@interface Condition_Timer : BaseCondition <NSTextFieldDelegate> {

    NSTimeInterval              _rdInterval;

    IBOutlet NSView *           _rdInternalConfigurationView;
    IBOutlet NSTextField *      _rdActualText;

}

@end
