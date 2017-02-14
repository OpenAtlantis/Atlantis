//
//  ToolbarAddressBook.h
//  Atlantis
//
//  Created by Rachel Blackman on 5/30/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolbarOption.h"

@interface ToolbarAddressBook : NSObject <ToolbarOption> {

    NSToolbarItem               *_rdToolbarItem;
    NSMutableDictionary         *_rdToolbarItemDict;

}

@end
