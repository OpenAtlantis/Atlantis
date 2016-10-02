//
//  HotkeyCollection.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EventCollection.h"

@interface HotkeyCollection : EventCollection {

}

- (BOOL) executeForKey:(int)keyCode modifiers:(int)modifiers;

@end
