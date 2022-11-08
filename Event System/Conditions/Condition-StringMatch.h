//
//  Condition-StringMatch.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/6/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseCondition.h"
#import "RDStringPattern.h"

@interface Condition_StringMatch : BaseCondition <NSTextFieldDelegate> {

    RDStringPattern             *_rdPattern;
    
    IBOutlet NSView             *_rdInternalConfigurationView;
    IBOutlet NSTextField        *_rdActualText;
    IBOutlet NSPopUpButton      *_rdPatternType;

}

-(id) initWithPattern:(RDStringPattern *) pattern;

- (IBAction) patternTypeChanged:(id) sender;

@end
