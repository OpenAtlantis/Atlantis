//
//  Condition-Negate.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/18/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lemuria/Lemuria.h>
#import "BaseCondition.h"

@interface Condition_Negate : BaseCondition {

    BaseCondition               *_rdChildCondition;

    IBOutlet NSView             *_rdInternalConfigurationView;
    IBOutlet NSPopUpButton      *_rdConditionPicker;
    IBOutlet RDChainedListView  *_rdDisplayView;

}

- (IBAction) conditionTypeChanged:(id)sender;


@end
