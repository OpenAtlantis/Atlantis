//
//  WorldConfigurationEditor.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldConfigurationEditor.h"
#import "RDAtlantisMainController.h"
#import "WorldConfigurationTab.h"
#import <objc/runtime.h>

@implementation WorldConfigurationEditor

- (id) initWithGlobalWorld
{
    self = [super init];
    if (self) {
        _rdPrefs = [[RDAtlantisMainController controller] globalWorld];
        _rdCharacter = nil;
            
        _rdConfigTabView = [[NSTabView alloc] initWithFrame:NSMakeRect(0,0,300,400)];
        [_rdConfigTabView setTabViewType:NSTopTabsBezelBorder];
        [_rdConfigTabView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
        [_rdConfigTabView setAutoresizesSubviews:YES];
        [_rdConfigTabView setDelegate:self];
        
        _rdConfigPages = [[NSMutableArray alloc] init];
        
        NSArray *tabClasses = [[RDAtlantisMainController controller] configTabs];
        
        NSEnumerator *tabEnum = [tabClasses objectEnumerator];
        Class tabWalk;
        
        while (tabWalk = [tabEnum nextObject]) {
            int result = (int)objc_msgSend(tabWalk, @selector(globalTab));
            if (result) {        
                WorldConfigurationTab *tab = (WorldConfigurationTab *)class_createInstance(tabWalk,0);
                
                [tab initWithWorld:_rdPrefs forCharacter:nil];
                [_rdConfigPages addObject:tab];
                
                NSString *tabName = [tab configTabName];
                NSView *tabView = [tab configTabView];
                
                NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:tabName];
                [item setLabel:tabName];
                [item setView:tabView];
                [_rdConfigTabView addTabViewItem:item];
                [item release];
            }
        }
    }
    return self;
}

- (id) initWithWorld:(RDAtlantisWorldPreferences *)world forCharacter:(NSString *) character
{
    self = [super init];
    if (self) {
        _rdPrefs = [world retain];
        if (character)
            _rdCharacter = [character retain];
        else
            _rdCharacter = nil;
            
        _rdConfigPages = [[NSMutableArray alloc] init];

        _rdConfigTabView = [[NSTabView alloc] initWithFrame:NSMakeRect(0,0,300,400)];
        [_rdConfigTabView setTabViewType:NSTopTabsBezelBorder];
        [_rdConfigTabView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
        [_rdConfigTabView setAutoresizesSubviews:YES];
        [_rdConfigTabView setDelegate:self];
        
        NSArray *tabClasses = [[RDAtlantisMainController controller] configTabs];
        
        NSEnumerator *tabEnum = [tabClasses objectEnumerator];
        Class tabWalk;
        
        while (tabWalk = [tabEnum nextObject]) {
            WorldConfigurationTab *tab = (WorldConfigurationTab *)class_createInstance(tabWalk,0);
            
            [tab initWithWorld:world forCharacter:character];
            [tab retain];
            [_rdConfigPages addObject:tab];
            
            NSString *tabName = [tab configTabName];
            NSView *tabView = [tab configTabView];
            
            NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:tabName];
            [item setLabel:tabName];
            [item setView:tabView];
            [_rdConfigTabView addTabViewItem:item];
        }
    }
    return self;
}

- (void) dealloc
{
    [self commitAll];
    [_rdConfigPages release];
    [super dealloc];
}

- (void) commitAll
{
    NSEnumerator *tabEnum = [_rdConfigPages objectEnumerator];
    WorldConfigurationTab *tabWalk;

    [_rdPrefs beginSyncUpdate];
    while (tabWalk = [tabEnum nextObject]) {
        [tabWalk finalCommit];
    }
    [_rdPrefs endSyncUpdate];
}

- (NSView *) configView
{
    return _rdConfigTabView;
}

- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    WorldConfigurationTab *tab;
    int position = [_rdConfigTabView indexOfTabViewItem:[_rdConfigTabView selectedTabViewItem]];
    
    if ((position >= 0) && (position < [_rdConfigPages count])) {
        tab = [_rdConfigPages objectAtIndex:position];
        if (tab) {
            [tab finalCommit];
        }
    }
    
    return YES;
}

@end
