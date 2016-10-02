//
//  Condition-VariableMatch.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/19/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseCondition.h"

@class RDStringPattern;

@interface Condition_VariableMatch : BaseCondition {

    RDStringPattern             *_rdPattern;
    NSString                    *_rdVariableName;
    
    IBOutlet NSView             *_rdInternalConfigurationView;
    IBOutlet NSTextField        *_rdActualVariable;
    IBOutlet NSTextField        *_rdActualText;
    IBOutlet NSPopUpButton      *_rdPatternType;

}

- (IBAction) patternTypeChanged:(id) sender;

@end
