//
//  HotkeyEvent.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EventDataProtocol.h"
#import "PTKeyCombo.h"
#import "PTHotKey.h"
#import "BaseEvent.h"

@interface HotkeyEvent : BaseEvent <NSCoding> {

    PTKeyCombo              *_rdKeyCombo;
    PTHotKey                *_rdKey;
    
    BOOL                     _rdGlobal;
    
}

- (id) initWithActions:(NSArray *) actions forKey:(PTKeyCombo *)key global:(BOOL) global;

- (BOOL) isGlobal;

- (PTKeyCombo *) keyCombo;
- (void) setKeyCombo:(PTKeyCombo *) key;

- (void) registerKeyBinding;
- (void) unregisterKeyBinding;

- (void) execute: (id) sender;



@end
