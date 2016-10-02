//
//  HotkeyCollection.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "HotkeyCollection.h"
#import "HotkeyEvent.h"
#import "PTKeyCombo.h"

@implementation HotkeyCollection

- (BOOL) executeForKey:(int)keyCode modifiers:(int)modifiers
{
    NSEnumerator *keyEnum = [[self events] objectEnumerator];
    
    HotkeyEvent *keyWalk;
    BOOL done = NO;
    
    while (!done && (keyWalk = [keyEnum nextObject])) {
        PTKeyCombo *keyCombo = [keyWalk keyCombo];
        if ([keyWalk isEnabled] && ([keyCombo keyCode] == keyCode) && ([keyCombo modifiers] == modifiers)) {
            [keyWalk execute:self];
            done = YES;
        }
    }
    
    return done;
}

@end
