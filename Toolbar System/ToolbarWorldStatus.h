//
//  ToolbarWorldStatus.h
//  Atlantis
//
//  Created by Rachel Blackman on 9/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolbarOption.h"

@interface ToolbarWorldStatus : NSObject <ToolbarOption> {

    NSToolbarItem   *               _rdToolbarItem;
    NSMutableDictionary *           _rdToolbarItemDict;
    NSMutableDictionary *           _rdToolbarControllerDict;
    
    NSTimer             *           _rdUpdateTimer;

}

- (void) updateAll;

@end
