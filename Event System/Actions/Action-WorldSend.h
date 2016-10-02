//
//  Action-WorldSend.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_WorldSend : BaseAction {

    NSString                *_rdString;
    
    IBOutlet NSView         *_rdInternalConfigurationView;
    IBOutlet NSTextField    *_rdActualText;

}

- (id) initWithString:(NSString *) string;

@end
