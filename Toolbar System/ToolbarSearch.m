//
//  ToolbarSearch.m
//  Atlantis
//
//  Created by Rachel Blackman on 5/26/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ToolbarSearch.h"
#import "AtlantisState.h"
#import "RDAtlantisSpawn.h"
#import <Lemuria/Lemuria.h>
#import "RDTextField.h"
#import "ToolbarSearchController.h"

@implementation ToolbarSearch

- (id) init
{
    self = [super init];
    if (self) {
        _rdToolbarItem = nil;
        _rdToolbarItemDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [_rdToolbarItemDict release];
    [_rdToolbarItem release];
    [super dealloc];
}

- (BOOL) validForState:(AtlantisState *) state
{
    if ([state spawn]) {
        NSWindow *window = [NSApp keyWindow];
        NSToolbar *toolbar = [window toolbar];
        if (toolbar) {
            return ([toolbar displayMode] != NSToolbarDisplayModeLabelOnly);
        }
    }
        
    return NO;
}

- (void) activateWithState:(AtlantisState *) state
{
    // Our view delegate handles this stuff, whee
}

- (NSToolbarItem *) toolbarItemForState:(AtlantisState *)state
{
    NSToolbarItem *item = nil;
    BOOL needsInit = NO;
    
    if (!state) {
        if (!_rdToolbarItem) {
            _rdToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:[self toolbarItemIdentifier]];
            needsInit = YES;
        }
        item = _rdToolbarItem;
    }
    else {
        NSString *windowUID = [state extraDataForKey:@"application.windowUID"];
        if (windowUID) {
            item = [_rdToolbarItemDict objectForKey:windowUID];
            if (!item) {
                item = [[NSToolbarItem alloc] initWithItemIdentifier:[self toolbarItemIdentifier]];
                needsInit = YES;
                [_rdToolbarItemDict setObject:item forKey:windowUID];
//                [item autorelease];
            }
        }
    }

    if (needsInit) {        
        ToolbarSearchController *controller = [[ToolbarSearchController alloc] init];
    
        [item setLabel:@"Search"];
        [item setPaletteLabel:@"Search Current Spawn"];
        [item setView:[controller contentView]];
        
        [item setMinSize:[[controller contentView] frame].size];
        [item setMaxSize:[[controller contentView] frame].size];
    }
    
    return item;
}

- (NSString *) toolbarItemIdentifier
{
    return @"spawnSearch";
}



@end
