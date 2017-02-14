//
//  WorldInfoEditor.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldInfoEditor.h"


@implementation WorldInfoEditor


- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *) character
{
    self = [super initWithWorld:prefs forCharacter:character];
    if (self) {
        [NSBundle loadNibNamed:@"WorldConf_Info" owner:self];
        [_rdWebsite setDelegate:self];
        [_rdDescription setDelegate:self];
        
        [self worldWasUpdated:nil];
    }
    return self;
}

- (NSString *) configTabName
{
    return @"Info";
}

- (NSView *) configTabView
{
    return _rdConfigView;
}

- (void) finalCommit
{
    if (![self character]) {
        NSString *websiteString = [_rdWebsite stringValue];
        NSString *descriptionString = [[_rdDescription textStorage] string];
        
        if (websiteString && [websiteString length]) {
            [[self preferences] setPreference:websiteString forKey:@"atlantis.world.website" withCharacter:[self character]];
        }
        else {
            [[self preferences] removePreferenceForKey:@"atlantis.world.website" withCharacter:[self character]];
        }

        if (descriptionString && [descriptionString length]) {
            [[self preferences] setPreference:descriptionString forKey:@"atlantis.world.description" withCharacter:[self character]];
        }
        else {
            [[self preferences] removePreferenceForKey:@"atlantis.world.description" withCharacter:[self character]];
        }
        
    }

    if (![self character] || ([_rdIconOverride state] == NSOnState)) {
        NSImage *worldIcon = [_rdIconWell image];
        if (worldIcon) {
            [[self preferences] setPreference:worldIcon forKey:@"atlantis.info.icon" withCharacter:[self character]];
        }
        else {
            [[self preferences] removePreferenceForKey:@"atlantis.info.icon" withCharacter:[self character]];
        }
    }
}

- (void) iconOverrideToggle:(id) sender
{
    BOOL edit = [sender state] == NSOnState;
    
    [_rdIconWell setEditable:edit];
    if (!edit) {
        [[self preferences] removePreferenceForKey:@"atlantis.info.icon" withCharacter:[self character]];
        NSImage *l_image = [[self preferences] preferenceForKey:@"atlantis.info.icon" withCharacter:nil];
        [_rdIconWell setImage:l_image];
    }
    
    [[self preferences] setPreference:[NSNumber numberWithBool:edit] forKey:@"atlantis.info.iconOverride" withCharacter:[self character]];
}

- (void) worldWasUpdated:(NSNotification *)notification
{
    NSString *result = [[self preferences] preferenceForKey:@"atlantis.world.website" withCharacter:[self character]];
    if (result) {
        [_rdWebsite setStringValue:result];
    }
    else {
        [_rdWebsite setStringValue:@""];
    }
    
    result = [[self preferences] preferenceForKey:@"atlantis.world.description" withCharacter:[self character]];
    NSMutableString *mutString = [[_rdDescription textStorage] mutableString];
    if (result) {
        [mutString setString:result];
    }
    else {
        [mutString setString:@""];
    }    
    
    NSImage *icon = [[self preferences] preferenceForKey:@"atlantis.info.icon" withCharacter:[self character]];
    if (icon) {
        [_rdIconWell setImage:icon];
    }
    else {
        [_rdIconWell setImage:nil];
    }
    
    BOOL editIcon = [[[self preferences] preferenceForKey:@"atlantis.info.iconOverride" withCharacter:[self character]] boolValue];
    [_rdIconOverride setState:editIcon ? NSOnState : NSOffState];
    if (!editIcon && ![self character])
        editIcon = YES;
    
    [_rdWebsite setEditable:(![self character])];
    [_rdDescription setEditable:(![self character])];
    [_rdIconWell setEditable:editIcon];
    
    [_rdIconOverride setHidden:![self character]];
    [_rdIconOverride setTarget:self];
    [_rdIconOverride setAction:@selector(iconOverrideToggle:)];
}

- (void) launchWebsite:(id) sender
{
    NSString *urlString = [_rdWebsite stringValue];
    if (urlString) {
        NSURL *url = [NSURL URLWithString:urlString];
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}


@end
