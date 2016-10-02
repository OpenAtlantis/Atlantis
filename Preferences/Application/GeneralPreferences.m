//
//  GeneralPreferences.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "GeneralPreferences.h"
#import "RDAtlantisApplication.h"
#import "RDAtlantisMainController.h"

static NSImage *s_rdGeneralImage = nil;

@implementation GeneralPreferences

- (id) init
{
    self = [super init];
    _rdCheckOnStartup = nil;
    _rdConfigView = nil;
    return self;
}

- (NSString *) preferencePaneName
{
    return @"General";
}

- (void) startupCheckChanged:(id) sender
{
    BOOL result = NO;
    
    if ([_rdCheckOnStartup state] == NSOffState) {
        result = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:@"atlantis.update.skipcheck"];
}

- (void) beepTypeChanged:(id) sender
{
    int beepType = [_rdBeepBehavior indexOfSelectedItem];
    
    [[NSUserDefaults standardUserDefaults] setInteger:beepType forKey:@"atlantis.beeptype"];
}

- (void) clearInputChanged:(id) sender
{
    BOOL result = NO;
    
    if ([_rdClearInput state] == NSOffState) {
        result = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:@"atlantis.text.retainOnCommit"];
}

- (void) slashiesChanged:(id) sender
{
    BOOL result = NO;
    
    if ([_rdNoSlashies state] == NSOnState) {
        result = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:@"atlantis.input.noSlashies"];
}

- (void) silentConvertChanged:(id) sender
{
    BOOL result = NO;
    
    if ([_rdSilentConvert state] == NSOnState) {
        result = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:@"atlantis.input.silentConvert"];
}


- (void) fugueEnabledChanged:(id) sender
{
    BOOL result = YES;
    
    if ([_rdFugueEnabled state] == NSOffState) {
        result = NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:@"atlantis.grab.fugueedit"];
}

- (void) autoshrinkUrlChanged:(id) sender
{
    BOOL result = YES;
    
    if ([_rdAutoShrink state] == NSOffState) {
        result = NO;
    }
    
    [_rdAutoShrinkLen setEnabled:result];
    
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:@"atlantis.input.urlAutoshrink"];
    if (result) {
        int urlLen = [_rdAutoShrinkLen intValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:urlLen] forKey:@"atlantis.input.urlMaxLen"];        
    }
}

- (void) controlTextDidEndEditing:(NSNotification *) aNotification
{
    if ([aNotification object] == _rdAutoShrinkLen) {
        int urlLen = [_rdAutoShrinkLen intValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:urlLen] forKey:@"atlantis.input.urlMaxLen"];
    }
}

- (void) easyShortcutChanged:(id) sender
{
    BOOL result = YES;
    
    if ([_rdEasyShortcut state] == NSOffState) {
        result = NO;
    }
    
    [(RDAtlantisApplication *)NSApp shortcutSpawns:result];
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:@"atlantis.shortcut.spawns"];
}

- (void) dockBadgeChanged:(id) sender
{
    BOOL result = YES;
    
    if ([sender state] == NSOffState) {
        result = NO;
    }

    NSString *key;
    
    if (sender == _rdDockBadgeActive)
        key = @"atlantis.badge.inactive";
    else if (sender == _rdDockBadgeHidden)
        key = @"atlantis.badge.hidden";
        
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:key];
    
    [[RDAtlantisMainController controller] refreshBadge];
}

- (void) addressBookOpenChanged:(id) sender
{
    BOOL result = YES;
    
    if ([sender state] == NSOffState) {
        result = NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:@"atlantis.startup.openBook"];
}

- (void) doubleConnectChanged:(id) sender
{
    BOOL result = YES;
    
    if ([sender state] == NSOffState) {
        result = NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:@"atlantis.worldMenu.doubleConnect"];
}

- (NSView *) preferencePaneView
{
    if (!_rdConfigView) {
        [NSBundle loadNibNamed:@"GeneralPrefs" owner:self];
        [_rdCheckOnStartup setTarget:self];
        [_rdCheckOnStartup setAction:@selector(startupCheckChanged:)];
        [_rdClearInput setTarget:self];
        [_rdClearInput setAction:@selector(clearInputChanged:)];
        [_rdFugueEnabled setTarget:self];
        [_rdFugueEnabled setAction:@selector(fugueEnabledChanged:)];
        [_rdEasyShortcut setTarget:self];
        [_rdEasyShortcut setAction:@selector(easyShortcutChanged:)];
        [_rdDockBadgeActive setTarget:self];
        [_rdDockBadgeActive setAction:@selector(dockBadgeChanged:)];
        [_rdDockBadgeHidden setTarget:self];
        [_rdDockBadgeHidden setAction:@selector(dockBadgeChanged:)];
        [_rdNoSlashies setTarget:self];
        [_rdNoSlashies setAction:@selector(slashiesChanged:)];
        [_rdSilentConvert setTarget:self];
        [_rdSilentConvert setAction:@selector(silentConvertChanged:)];
        [_rdBeepBehavior setTarget:self];
        [_rdBeepBehavior setAction:@selector(beepTypeChanged:)];
        [_rdOpenAddressBook setTarget:self];
        [_rdOpenAddressBook setAction:@selector(addressBookOpenChanged:)];
        [_rdAutoShrink setTarget:self];
        [_rdAutoShrink setAction:@selector(autoshrinkUrlChanged:)];
        [_rdAutoShrinkLen setDelegate:self];
        [_rdDoubleConnect setAction:@selector(doubleConnectChanged:)];
        [_rdDoubleConnect setTarget:self];
    }

    BOOL skipCheck = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.update.skipcheck"];

    if (skipCheck)
        [_rdCheckOnStartup setState:NSOffState];
    else
        [_rdCheckOnStartup setState:NSOnState];

    BOOL noSlashies = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.input.noSlashies"];
    if (noSlashies)
        [_rdNoSlashies setState:NSOnState];
    else
        [_rdNoSlashies setState:NSOffState];

    BOOL silentConvert = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.input.silentConvert"];
    if (silentConvert)
        [_rdSilentConvert setState:NSOnState];
    else
        [_rdSilentConvert setState:NSOffState];


    BOOL openBook = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.startup.openBook"];
    if (openBook)
        [_rdOpenAddressBook setState:NSOnState];
    else
        [_rdOpenAddressBook setState:NSOffState];

    BOOL fugueMe = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.grab.fugueedit"];
    if (fugueMe)
        [_rdFugueEnabled setState:NSOnState];
    else
        [_rdFugueEnabled setState:NSOffState];
        
    BOOL retainInput = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.text.retainOnCommit"];
    if (retainInput) 
        [_rdClearInput setState:NSOffState];
    else
        [_rdClearInput setState:NSOnState];
        
    BOOL easyShortcut = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.shortcut.spawns"];
    if (easyShortcut)
        [_rdEasyShortcut setState:NSOnState];
    else
        [_rdEasyShortcut setState:NSOffState];

    BOOL doubleConnect = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.worldMenu.doubleConnect"];
    if (doubleConnect)
        [_rdDoubleConnect setState:NSOnState];
    else
        [_rdDoubleConnect setState:NSOffState];


    BOOL dockBadge = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.badge.inactive"];
    if (dockBadge)
        [_rdDockBadgeActive setState:NSOnState];
    else
        [_rdDockBadgeActive setState:NSOffState];

    BOOL dockBadgeHide = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.badge.hidden"];
    if (dockBadgeHide)
        [_rdDockBadgeHidden setState:NSOnState];
    else
        [_rdDockBadgeHidden setState:NSOffState];

    NSNumber *autoshrinkLen = [[NSUserDefaults standardUserDefaults] objectForKey:@"atlantis.input.urlMaxLen"];
    int shrinkLen = 60;
    if (autoshrinkLen) {
        shrinkLen = [autoshrinkLen intValue];
    }
    [_rdAutoShrinkLen setIntValue:shrinkLen];
    
    BOOL autoshrink = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.input.urlAutoshrink"];
    if (autoshrink) {
        [_rdAutoShrinkLen setEnabled:YES];
        [_rdAutoShrink setState:NSOnState];
    }
    else {
        [_rdAutoShrinkLen setEnabled:NO];
        [_rdAutoShrink setState:NSOffState];    
    }

    [_rdBeepBehavior selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"atlantis.beeptype"]];

    [[_rdConfigView window] performSelector:@selector(makeFirstResponder:) withObject:_rdCheckOnStartup afterDelay:0.2];
        
    return _rdConfigView;
}

- (NSImage *) preferencePaneImage
{
    if (!s_rdGeneralImage)
        s_rdGeneralImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"General_Prefs"]];
    
    return s_rdGeneralImage;
}

- (void) preferencePaneCommit
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
