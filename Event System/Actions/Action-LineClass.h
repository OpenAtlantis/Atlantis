//
//  Action-LineClass.h
//  Atlantis
//
//  Created by Rachel Blackman on 4/11/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_LineClass : BaseAction {

    IBOutlet NSView         *_rdInternalConfigurationView;
    IBOutlet NSTextField    *_rdActualText;
    
    NSString                *_rdString;

}

@end
