//
//  AtlantisPreferenceController.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/3/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "AtlantisPreferenceController.h"
#import "RDAtlantisApplication.h"

@interface AtlantisPreferenceController (Private)
- (void) selectPaneForIdentifier:(NSString *) identifier display:(BOOL) display;
@end

@implementation AtlantisPreferenceController

- (id) init
{
    self = [super init];
    if (self) {
        _rdPrefsWindow = nil;
        _rdPreferencePanes = [[NSMutableDictionary alloc] init];
        _rdPreferenceOrder = [[NSMutableArray alloc] init];
        _rdToolbarItems = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [_rdPrefsWindow release];
    [_rdPreferencePanes release];
    [_rdPreferenceOrder release];
    [_rdToolbarItems release];
    [super dealloc];
}

- (void) addPane:(id <AtlantisPreferencePane>)pane
{
    [_rdPreferencePanes setObject:pane forKey:[pane preferencePaneName]];
    [_rdPreferenceOrder addObject:[pane preferencePaneName]];
}

- (void) showPreferences
{
    if (_rdPrefsWindow) {
        [_rdPrefsWindow makeKeyAndOrderFront:self];
    }
    else {
        unsigned int styleMask = NSClosableWindowMask | NSResizableWindowMask;
        
/*        if ([RDAtlantisApplication isTiger])
            styleMask = styleMask | (1 << 12); // Tiger's unified look flag. */
    
        _rdPrefsWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 350, 200)
                                                     styleMask:styleMask
                                                       backing:NSBackingStoreBuffered
                                                         defer:NO];
        
        [_rdPrefsWindow setReleasedWhenClosed:NO];
        [_rdPrefsWindow setTitle:@"Atlantis Preferences"]; // initial default title
        
        [_rdPrefsWindow setShowsResizeIndicator:NO];
        
        NSEnumerator *prefEnum = [_rdPreferenceOrder objectEnumerator];
        NSString *walk;
        
        while (walk = [prefEnum nextObject]) {
            id <AtlantisPreferencePane> pane = [_rdPreferencePanes objectForKey:walk];
            
            if (pane) {
                NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:walk];
                [item setPaletteLabel:walk];
                [item setLabel:walk];
                [item setToolTip:nil];
                [item setImage:[pane preferencePaneImage]];
                [item setTarget:self];
                [item setAction:@selector(toolbarItemClicked:)];
                [item setEnabled:YES];
                [_rdToolbarItems setObject:item forKey:walk];
            }
        }
        
        NSToolbar *prefsBar = [[NSToolbar alloc] initWithIdentifier:@"AtlantisPrefsToolbar"];
        [prefsBar setDelegate:self];
        [prefsBar setAllowsUserCustomization:NO];
        [prefsBar setAutosavesConfiguration:NO];
        [prefsBar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
        [prefsBar setSizeMode:NSToolbarSizeModeDefault];
        [_rdPrefsWindow setToolbar:prefsBar];
        [_rdPrefsWindow setDelegate:self];
        [self setWindow:_rdPrefsWindow];
        
        [_rdPrefsWindow center];
        [_rdPrefsWindow setFrameAutosaveName:@"preferencesWindow"];

        [self selectPaneForIdentifier:[_rdPreferenceOrder objectAtIndex:0] display:NO];
        
        _rdLastPane = nil;
        
        [_rdPrefsWindow makeKeyAndOrderFront:self];
    }
}

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar *) toolbar
{
    return _rdPreferenceOrder;
}

- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *) toolbar
{
    return _rdPreferenceOrder;
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
    return YES;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    return [_rdToolbarItems objectForKey:itemIdentifier];
}

- (void) selectPaneForIdentifier:(NSString *) identifier display:(BOOL) display
{
    id <AtlantisPreferencePane> pane;
    
    pane = [_rdPreferencePanes objectForKey:identifier];

    if (_rdLastPane) {
        [_rdLastPane preferencePaneCommit];
    }

    if (pane) {
        NSView *view = [pane preferencePaneView];
        NSRect newFrame = [_rdPrefsWindow frame];
        NSRect contentFrame = [[_rdPrefsWindow contentView] frame];
        NSRect viewFrame = [view frame];
        newFrame.size.height = viewFrame.size.height + (newFrame.size.height - contentFrame.size.height);
        newFrame.size.width = viewFrame.size.width;
        newFrame.origin.y += contentFrame.size.height - viewFrame.size.height;
        
        if (display) {
            NSView *tempView = [[NSView alloc] initWithFrame:[[_rdPrefsWindow contentView] frame]];
            [_rdPrefsWindow setContentView:tempView];
            [tempView release]; 
        }
        
        [_rdPrefsWindow setFrame:newFrame display:display animate:display];
        [_rdPrefsWindow setContentView:view];
        [_rdPrefsWindow setTitle:identifier];
        _rdLastPane = pane;
    }
}

- (void)toolbarItemClicked:(NSToolbarItem*)item
{
    [self selectPaneForIdentifier:[item itemIdentifier] display:YES];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    NSEnumerator *paneEnum = [_rdPreferencePanes objectEnumerator];
    id <AtlantisPreferencePane> walk;
    
    while (walk = [paneEnum nextObject]) {
        [walk preferencePaneCommit];
    }
}

- (void) changeFont:(id) sender
{
    NSView *realContentView;
    
    realContentView = [_rdPrefsWindow contentView];
    if ([realContentView isKindOfClass:[NSTabView class]])
        realContentView = [[(NSTabView *)realContentView selectedTabViewItem] view];
    
    if ([realContentView respondsToSelector:@selector(changeFont:)]) {
        [realContentView changeFont:sender];
    }
}


@end
