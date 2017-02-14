//
//  WindowingPreferences.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WindowingPreferences.h"
#import <Lemuria/Lemuria.h>
#import <Lemuria/RDNestedOutlineView.h>
#import <Lemuria/RDNestedTabBarView.h>
#import <Lemuria/RDNestedSourceView.h>

#import "RDAtlantisMainController.h"

static NSImage *s_rdWindowImage = nil;

@implementation WindowingPreferences

- (id) init
{
    self = [super init];
    _rdDragEnabled = nil;
    return self;
}

- (NSString *) preferencePaneName
{
    return @"Windowing";
}

- (void) dragEnabledChanged:(id) sender
{
    BOOL result = NO;
    
    if ([_rdDragEnabled state] == NSOffState) {
        result = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:@"lemuria.dragging.disabled"];
}

- (void) groupingDefault:(id) sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"default" forKey:@"lemuria.window.behavior"];
}

- (void) groupingSingle:(id) sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"contained" forKey:@"lemuria.window.behavior"];
}

- (void) groupingScatter:(id) sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"scattered" forKey:@"lemuria.window.behavior"];
}

- (void) styleSmallIcons:(id) sender
{
    BOOL enabled = ([sender state] == NSOnState);
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"lemuria.display.smallicons"];
    [[RDNestedViewManager manager] syncDisplayClass];
}

- (void) styleSource:(id) sender
{
    [_rdOutlineStyle setState:NSOffState];
    [_rdTabbedStyle setState:NSOffState];
    [_rdSourceStyle setState:NSOnState];
    [_rdSmallIcons setEnabled:YES];
    [[RDNestedViewManager manager] setDisplayClass:[RDNestedSourceView class]];
    [[NSUserDefaults standardUserDefaults] setObject:@"source" forKey:@"lemuria.display.style"];
}


- (void) styleOutline:(id) sender
{
    [_rdOutlineStyle setState:NSOnState];
    [_rdTabbedStyle setState:NSOffState];
    [_rdSourceStyle setState:NSOffState];
    [_rdSmallIcons setEnabled:NO];
    [[RDNestedViewManager manager] setDisplayClass:[RDNestedOutlineView class]];
    [[NSUserDefaults standardUserDefaults] setObject:@"outline" forKey:@"lemuria.display.style"];
}

- (void) styleTabbed:(id) sender
{
    [_rdOutlineStyle setState:NSOffState];
    [_rdTabbedStyle setState:NSOnState];
    [_rdSourceStyle setState:NSOffState];
    [_rdSmallIcons setEnabled:NO];
    [[RDNestedViewManager manager] setDisplayClass:[RDNestedTabBarView class]];
    [[NSUserDefaults standardUserDefaults] setObject:@"tabbed" forKey:@"lemuria.display.style"];
}

- (void) spawnStatusBottom:(id) sender
{
    BOOL bottomStatus = ([_rdBottomSpawn state] == NSOnState);
    [[NSUserDefaults standardUserDefaults] setBool:bottomStatus forKey:@"atlantis.statusbar.bottom"];
    [[RDAtlantisMainController controller] setStatusBarBottom:bottomStatus]; 
}

- (void) spawnStatusKill:(id) sender
{
    BOOL killSpawns = ([_rdKillSpawn state] == NSOnState);
    [[NSUserDefaults standardUserDefaults] setBool:killSpawns forKey:@"atlantis.statusbar.kill"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RDAtlantisStatusBarDidChangeNotification" object:self];
}


- (NSView *) preferencePaneView
{
    if (!_rdConfigView) {
        [NSBundle loadNibNamed:@"WindowPrefs" owner:self];
        [_rdDragEnabled setTarget:self];
        [_rdDragEnabled setAction:@selector(dragEnabledChanged:)];
        
        [_rdDefaultGrouping setTarget:self];
        [_rdDefaultGrouping setAction:@selector(groupingDefault:)];
        [_rdOneGrouping setTarget:self];
        [_rdOneGrouping setAction:@selector(groupingSingle:)];
        [_rdScatterGrouping setTarget:self];
        [_rdScatterGrouping setAction:@selector(groupingScatter:)];
        
        [_rdOutlineStyle setTarget:self];
        [_rdOutlineStyle setAction:@selector(styleOutline:)];
        [_rdTabbedStyle setTarget:self];
        [_rdTabbedStyle setAction:@selector(styleTabbed:)];
        [_rdSourceStyle setTarget:self];
        [_rdSourceStyle setAction:@selector(styleSource:)];
        
        [_rdSmallIcons setTarget:self];
        [_rdSmallIcons setAction:@selector(styleSmallIcons:)];
        
        [_rdBottomSpawn setTarget:self];
        [_rdBottomSpawn setAction:@selector(spawnStatusBottom:)];

        [_rdKillSpawn setTarget:self];
        [_rdKillSpawn setAction:@selector(spawnStatusKill:)];
    }

    BOOL dragDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"lemuria.dragging.disabled"];

    if (dragDisabled)
        [_rdDragEnabled setState:NSOffState];
    else
        [_rdDragEnabled setState:NSOnState];
        
    NSString *windowLogic = [[NSUserDefaults standardUserDefaults] objectForKey:@"lemuria.window.behavior"];

    if ([windowLogic isEqualToString:@"contained"]) {
        [_rdOneGrouping setState:NSOnState];
        [_rdDefaultGrouping setState:NSOffState];
        [_rdScatterGrouping setState:NSOffState];
    }
    else if ([windowLogic isEqualToString:@"scattered"]) {
        [_rdOneGrouping setState:NSOffState];
        [_rdDefaultGrouping setState:NSOffState];
        [_rdScatterGrouping setState:NSOnState];
    }
    else {
        [_rdOneGrouping setState:NSOffState];
        [_rdDefaultGrouping setState:NSOnState];
        [_rdScatterGrouping setState:NSOffState];    
    }

    NSString *displayStyle = [[NSUserDefaults standardUserDefaults] objectForKey:@"lemuria.display.style"];

    if ([displayStyle isEqualToString:@"tabbed"]) {
        [_rdSmallIcons setEnabled:NO];
        [_rdOutlineStyle setState:NSOffState];
        [_rdTabbedStyle setState:NSOnState];
        [_rdSourceStyle setState:NSOffState];
    }
    else if ([displayStyle isEqualToString:@"outline"]) {
        [_rdSmallIcons setEnabled:NO];
        [_rdOutlineStyle setState:NSOnState];
        [_rdTabbedStyle setState:NSOffState];
        [_rdSourceStyle setState:NSOffState];
    }
    else {
        [_rdSmallIcons setEnabled:YES];
        [_rdOutlineStyle setState:NSOffState];
        [_rdTabbedStyle setState:NSOffState];
        [_rdSourceStyle setState:NSOnState];    
    }

    [_rdSmallIcons setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"lemuria.display.smallicons"] ? NSOnState : NSOffState];
    [_rdBottomSpawn setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.statusbar.bottom"] ? NSOnState : NSOffState];
    [_rdKillSpawn setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.statusbar.kill"] ? NSOnState : NSOffState];

    [[_rdConfigView window] performSelector:@selector(makeFirstResponder:) withObject:_rdDragEnabled afterDelay:0.2];

    return _rdConfigView;
}

- (NSImage *) preferencePaneImage
{
    if (!s_rdWindowImage)
        s_rdWindowImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"window"]];
    
    return s_rdWindowImage;
}

- (void) preferencePaneCommit
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
