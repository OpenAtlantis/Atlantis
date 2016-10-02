//
//  ToolbarSearchController.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/28/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ToolbarSearchController.h"
#import <Lemuria/Lemuria.h>
#import "RDAtlantisSpawn.h"

NSMenu *g_searchMenu = nil;

@implementation ToolbarSearchController

- (id) init
{
    self = [super init];
    if (self) {
        if ([NSBundle loadNibNamed:@"ToolbarSearch" owner:self]) {
            if (!g_searchMenu) {
                g_searchMenu = [[NSMenu alloc] initWithTitle:@"Search Menu"];

                NSMenuItem *item1, *item2;
                // TODO: Localize
                item1 = [[NSMenuItem alloc] initWithTitle:@"Recents" action:@selector(limitOne:) keyEquivalent:@""];
                [item1 setTag:NSSearchFieldRecentsMenuItemTag];
                [g_searchMenu insertItem:item1 atIndex:0];
            
                [g_searchMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
            
                item2 = [[NSMenuItem alloc] initWithTitle:@"Clear" action:@selector(limitTwo:) keyEquivalent:@""];
                [item2 setTag:NSSearchFieldClearRecentsMenuItemTag];
                [g_searchMenu insertItem:item2 atIndex:2];
//                [item1 autorelease];
//                [item2 autorelease];
            }
            [[_rdSearchField cell] setSearchMenuTemplate:g_searchMenu];    
            
            [_rdSearchField setDelegate:self];
            [_rdSearchField setRequireEnterCommit:YES];
            [[[_rdSearchField cell] cancelButtonCell] setTarget:self];
            [[[_rdSearchField cell] cancelButtonCell] setAction:@selector(cancelButtonClicked:)];
        }    
    }
    return self;
}

- (NSView *) contentView
{
    return _rdSearchView;
}

- (void) cancelButtonClicked:(id) sender
{
    id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];

    if (curView && [(NSObject *)curView isKindOfClass:[RDAtlantisSpawn class]]) {
        RDAtlantisSpawn *spawn = (RDAtlantisSpawn *)curView;
        
        [spawn clearSearchString:self];
        [_rdSearchField setStringValue:@""];
    }        
}

- (void) controlTextDidCommitText:(NSNotification *) notification
{
    id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];

    if (curView && [(NSObject *)curView isKindOfClass:[RDAtlantisSpawn class]]) {
        RDAtlantisSpawn *spawn = (RDAtlantisSpawn *)curView;
        
        [spawn searchForString:_rdSearchField];
    }    
}

@end
