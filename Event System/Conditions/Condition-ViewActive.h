//
//  Condition-ViewActive.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseCondition.h"

@interface Condition_ViewActive : BaseCondition {

    BOOL                         _rdWantsActive;

    IBOutlet NSView             *_rdInternalConfigurationView;
    IBOutlet NSPopUpButton      *_rdActivityChooser;

}

- (id) initWantsActive:(BOOL) active;

@end
