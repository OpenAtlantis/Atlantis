//
//  ToolbarUserEvent.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolbarOption.h"
#import "BaseEvent.h"

@interface ToolbarUserEvent : BaseEvent <ToolbarOption> {

    NSImage                     *_rdToolbarIcon;
    NSString                    *_rdUUID;
    
    NSToolbarItem               *_rdToolbarItem;
    NSMutableDictionary         *_rdToolbarItemDict;
    BOOL                         _rdDirty;

}

@end
