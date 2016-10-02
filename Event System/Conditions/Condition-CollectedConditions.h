//
//  Condition-CollectedConditions.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/6/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lemuria/Lemuria.h>
#import "BaseCondition.h"


@interface Condition_CollectedConditions : BaseCondition {

    NSMutableArray                  *_rdConditions;
    BOOL                             _rdConditionsAnded;

    IBOutlet NSView                 *_rdInternalConfigurationView;
    IBOutlet RDChainedListView      *_rdConditionsChain;
    IBOutlet NSPopUpButton          *_rdConditionsAndedPicker;

    IBOutlet NSSegmentedControl     *_rdAddConditionButton;
    IBOutlet NSSegmentedControl     *_rdRemoveConditionButton;
}

- (id) initWithConditions:(NSArray *) conditions anded:(BOOL) anded;

- (IBAction) conditionAndedChanged:(id) sender;
- (IBAction) removeSubCondition:(id) sender;

@end
