//
//  Condition-ViewName.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/6/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseCondition.h"

@interface Condition_ViewName : BaseCondition <NSTextFieldDelegate> {
    NSString                    *_rdViewName;
    
    IBOutlet NSView             *_rdInternalConfigurationView;
    IBOutlet NSTextField        *_rdActualText;
}

@end
