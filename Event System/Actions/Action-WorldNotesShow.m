//
//  Action-WorldNotesShow.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/3/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "Action-WorldNotesShow.h"
#import "RDAtlantisWorldInstance.h"
#import "AtlantisState.h"

@implementation Action_WorldNotesShow

+ (NSString *) actionName
{
    // TODO: Localize
    return @"World: Show Notepad";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Show or focus the world notepad.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    return [NSNumber numberWithBool:YES];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    RDAtlantisWorldInstance *world = [state world];
    if (world) {
        [world notesDisplay];
    }
    else {
        NSBeep();
    }
    
    return NO;
}

@end
