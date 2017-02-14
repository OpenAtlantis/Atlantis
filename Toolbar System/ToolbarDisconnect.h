//
//  ToolbarDisconnect.h
//  Atlantis
//
//  Created by Rachel Blackman on 5/26/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolbarOption.h"

@interface ToolbarDisconnect : NSObject <ToolbarOption> {

    NSToolbarItem           *_rdToolbarItem;
    NSMutableDictionary     *_rdToolbarItemDict;

}

@end
