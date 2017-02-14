//
//  ToolbarAddressBook.m
//  Atlantis
//
//  Created by Rachel Blackman on 5/30/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ToolbarAddressBook.h"
#import "AtlantisState.h"
#import "RDAtlantisMainController.h"
#import "WorldCollection.h"

@implementation ToolbarAddressBook


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
    return YES;
}

- (void) activateWithState:(AtlantisState *) state
{
    NSMenuItem *item = [state extraDataForKey:@"RDToolbarItem"];
    
    if (item) {
        NSMenu *menu = [[[RDAtlantisMainController controller] worlds] worldMenu];
        
        [NSMenu popUpContextMenu:menu withEvent:[NSApp currentEvent] forView:[[NSApp keyWindow] contentView] withFont:[NSFont menuFontOfSize:12.0f]];
    }
}

- (NSToolbarItem *) toolbarItemForState:(AtlantisState *) state
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
        [item setLabel:@"Address Book"];
        [item setPaletteLabel:@"Address Book (Popup Menu)"];
        [item setImage:[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"AddressBook"]]];
    }
    
    return item;
}

- (NSString *) toolbarItemIdentifier
{
    return @"addressBook";
}


@end
