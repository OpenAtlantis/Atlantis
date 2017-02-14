//
//  ToolbarSearch.h
//  Atlantis
//
//  Created by Rachel Blackman on 5/26/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolbarOption.h"
#import "RDTextField.h"

@interface ToolbarSearch : NSObject <ToolbarOption> {

    NSToolbarItem   *               _rdToolbarItem;
    NSMutableDictionary *           _rdToolbarItemDict;

}

@end
