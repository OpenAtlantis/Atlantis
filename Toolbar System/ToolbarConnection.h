//
//  ToolbarConnection.h
//  Atlantis
//
//  Created by Rachel Blackman on 5/23/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolbarOption.h"

@interface ToolbarConnection : NSObject <ToolbarOption> {

    NSToolbarItem           *_rdToolbarItem;
    NSMutableDictionary     *_rdToolbarItemDict;

}

@end
