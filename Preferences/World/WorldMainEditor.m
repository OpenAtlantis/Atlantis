//
//  WorldMainEditor.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldMainEditor.h"


@implementation WorldMainEditor

- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *) character
{
    self = [super initWithWorld:prefs forCharacter:character];
    if (self) {
        [NSBundle loadNibNamed:@"WorldConf_Main" owner:self];
        [_rdHostName setDelegate:self];
        [_rdHostPort setDelegate:self];
        [_rdCharacterInternal setDelegate:self];
        [_rdCharacterName setDelegate:self];
        [_rdCharacterPass setDelegate:self];
        [_rdWorldName setDelegate:self];

        NSNumber *keepaliveDisabled = [prefs preferenceForKey:@"atlantis.network.blockNop" withCharacter:[self character] fallback:NO];
        if (keepaliveDisabled) {
            if ([keepaliveDisabled boolValue]) {
                [prefs setPreference:[NSNumber numberWithInt:3] forKey:@"atlantis.network.keepalive" withCharacter:[self character]];
                [prefs removePreferenceForKey:@"atlantis.network.blockNop" withCharacter:[self character]];
            }
        }
        
        [self worldWasUpdated:nil];
    }
    return self;
}

- (NSString *) configTabName
{
    return @"Main";
}

- (NSView *) configTabView
{
    return _rdConfigView;
}

- (void) controlTextDidEndEditing:(NSNotification *)notification
{
    NSString *result;

    if ([notification object] == _rdWorldName) {
        result = [_rdWorldName stringValue];
        
        if (result && [result length]) {
            [[self preferences] setPreference:[NSString stringWithString:result] forKey:@"atlantis.world.name" withCharacter:[self character]];
        }
        else {
            // DO NOT DELETE THE WORLD NAME FOR REAL WORLDS!
            if ([self character])
                [[self preferences] removePreferenceForKey:@"atlantis.world.name" withCharacter:[self character]];
            else
                [_rdWorldName setStringValue:[[self preferences] preferenceForKey:@"atlantis.world.name" withCharacter:nil]];
        }
    }
/*    else if ([notification object] == _rdDisplayAs) {
        result = [_rdDisplayAs stringValue];
        
        if (result && [result length]) {
            [[self preferences] setPreference:[NSString stringWithString:result] forKey:@"atlantis.world.displayName" withCharacter:[self character]];
        }            
        else {
            [[self preferences] removePreferenceForKey:@"atlantis.world.displayAs" withCharacter:[self character]];
        }
    } */
    else if ([notification object] == _rdCharacterInternal) {
        result = [_rdCharacterInternal stringValue];
        
        if (result && [result length] && [self character] && ![result isEqualToString:[self character]]) {
            [[self preferences] renameCharacter:[self character] to:result];
        }
    }
    else if ([notification object] == _rdHostName) {
        result = [_rdHostName stringValue];
        
        if (result && [result length]) {
            [[self preferences] setPreference:[NSString stringWithString:result] forKey:@"atlantis.world.host" withCharacter:[self character]];
        }        
        else {
            [[self preferences] removePreferenceForKey:@"atlantis.world.host" withCharacter:[self character]];
        }
    }
    else if ([notification object] == _rdHostPort) {
        int numResult = [_rdHostPort intValue];
        
        if (numResult > 0) {
            [[self preferences] setPreference:[NSNumber numberWithInt:numResult] forKey:@"atlantis.world.port" withCharacter:[self character]];
            [_rdHostSSL setEnabled:YES];
            [_rdKeepaliveLogic setEnabled:YES];
        }            
        else {
            [[self preferences] removePreferenceForKey:@"atlantis.world.port" withCharacter:[self character]];
            [[self preferences] removePreferenceForKey:@"atlantis.world.ssl" withCharacter:[self character]];
            [_rdHostSSL setEnabled:NO];
            [_rdKeepaliveLogic setEnabled:NO];
        }
    }
    else if ([notification object] == _rdCharacterName) {
        result = [_rdCharacterName stringValue];
        
        if (result && [result length]) {
            [[self preferences] setPreference:[NSString stringWithString:result] forKey:@"atlantis.world.character" withCharacter:[self character]];
        }            
        else {
            [[self preferences] removePreferenceForKey:@"atlantis.world.character" withCharacter:[self character]];
        }
    }
    else if ([notification object] == _rdCharacterPass) {
        result = [_rdCharacterPass stringValue];
        
        if (result && [result length]) {
            [[self preferences] setPreference:[NSString stringWithString:result] forKey:@"atlantis.world.password" withCharacter:[self character]];
        }            
        else {
            [[self preferences] removePreferenceForKey:@"atlantis.world.password" withCharacter:[self character]];
        }
    }
}

- (void) autoconnectTypeChanged:(id) sender
{
    [[self preferences] beginBulk];
    int numResult = [_rdAutoconnect state];
    if (numResult == NSOnState) {
        int selected = [_rdAutopicker indexOfItem:[_rdAutopicker selectedItem]];
        
        if (selected == 0) {
            [[self preferences] setPreference:[NSNumber numberWithBool:NO] forKey:@"atlantis.world.autoconnect" withCharacter:[self character]];        
            [[self preferences] setPreference:[NSNumber numberWithBool:YES] forKey:@"atlantis.world.autoopen" withCharacter:[self character]];        
        }
        else {
            [[self preferences] setPreference:[NSNumber numberWithBool:YES] forKey:@"atlantis.world.autoconnect" withCharacter:[self character]];        
        }
    }
    [[self preferences] endBulk];
}

- (void) hostSSLChanged:(id) sender
{
    if ([_rdHostSSL state] == NSOnState) {
        [[self preferences] setPreference:[NSNumber numberWithBool:YES] forKey:@"atlantis.world.ssl" withCharacter:[self character]];
    }
    else {
        [[self preferences] setPreference:[NSNumber numberWithBool:NO] forKey:@"atlantis.world.ssl" withCharacter:[self character]];    
    }
}

- (void) keepaliveChanged:(id) sender
{
    int keepaliveType = [_rdKeepaliveLogic indexOfSelectedItem];
    [[self preferences] setPreference:[NSNumber numberWithInt:keepaliveType] forKey:@"atlantis.network.keepalive" withCharacter:[self character]];
}

- (void) autoconnectChanged:(id) sender
{
    [[self preferences] beginBulk];
    int numResult = [_rdAutoconnect state];
    if (numResult == NSOnState) {
        [_rdAutopicker setEnabled:YES];
        int selected = [_rdAutopicker indexOfItem:[_rdAutopicker selectedItem]];
        
        if (selected == 0) {
            [[self preferences] setPreference:[NSNumber numberWithBool:NO] forKey:@"atlantis.world.autoconnect" withCharacter:[self character]];        
            [[self preferences] setPreference:[NSNumber numberWithBool:YES] forKey:@"atlantis.world.autoopen" withCharacter:[self character]];        
        }
        else {
            [[self preferences] setPreference:[NSNumber numberWithBool:YES] forKey:@"atlantis.world.autoconnect" withCharacter:[self character]];        
        }
    }
    else {
        [_rdAutopicker setEnabled:NO];
        [[self preferences] setPreference:[NSNumber numberWithBool:NO] forKey:@"atlantis.world.autoconnect" withCharacter:[self character]];    
        [[self preferences] setPreference:[NSNumber numberWithBool:NO] forKey:@"atlantis.world.autoopen" withCharacter:[self character]];    
    }
    [[self preferences] endBulk];
}

- (void) finalCommit
{
    NSString *result;
    
    [[self preferences] beginBulk];
    
    result = [_rdWorldName stringValue];
    
    if (result && [result length]) {
        [[self preferences] setPreference:[NSString stringWithString:result] forKey:@"atlantis.world.name" withCharacter:[self character]];
    }            
    
    result = [_rdHostName stringValue];
    
    if (result && [result length]) {
        [[self preferences] setPreference:[NSString stringWithString:result] forKey:@"atlantis.world.host" withCharacter:[self character]];
    }        
    
    int numResult = [_rdHostPort intValue];
    
    if (numResult > 0) {
        [[self preferences] setPreference:[NSNumber numberWithInt:numResult] forKey:@"atlantis.world.port" withCharacter:[self character]];
    }            

    numResult = [_rdHostSSL state];
    if ([_rdHostSSL isEnabled]) {
        if (numResult == NSOnState) {
            [[self preferences] setPreference:[NSNumber numberWithBool:YES] forKey:@"atlantis.world.ssl" withCharacter:[self character]];
        }
        else {
            [[self preferences] setPreference:[NSNumber numberWithBool:NO] forKey:@"atlantis.world.ssl" withCharacter:[self character]];    
        }
    }
    else {
        [[self preferences] removePreferenceForKey:@"atlantis.world.ssl" withCharacter:[self character]];
    }

    int keepaliveType = [_rdKeepaliveLogic indexOfSelectedItem];
    [[self preferences] setPreference:[NSNumber numberWithInt:keepaliveType] forKey:@"atlantis.network.keepalive" withCharacter:[self character]];
        
    result = [_rdCharacterName stringValue];
    
    if (result && [result length]) {
        [[self preferences] setPreference:[NSString stringWithString:result] forKey:@"atlantis.world.character" withCharacter:[self character]];
    }
    
    result = [_rdCharacterPass stringValue];
    
    if (result && [result length]) {
        [[self preferences] setPreference:[NSString stringWithString:result] forKey:@"atlantis.world.password" withCharacter:[self character]];
    }            

    numResult = [_rdAutoconnect state];
    if (numResult == NSOnState) {
        int selected = [_rdAutopicker indexOfItem:[_rdAutopicker selectedItem]];
        
        if (selected == 0) {
            [[self preferences] setPreference:[NSNumber numberWithBool:NO] forKey:@"atlantis.world.autoconnect" withCharacter:[self character]];        
            [[self preferences] setPreference:[NSNumber numberWithBool:YES] forKey:@"atlantis.world.autoopen" withCharacter:[self character]];        
        }
        else {
            [[self preferences] setPreference:[NSNumber numberWithBool:YES] forKey:@"atlantis.world.autoconnect" withCharacter:[self character]];        
        }
    }
    else {
        [[self preferences] setPreference:[NSNumber numberWithBool:NO] forKey:@"atlantis.world.autoconnect" withCharacter:[self character]];    
        [[self preferences] setPreference:[NSNumber numberWithBool:NO] forKey:@"atlantis.world.autoopen" withCharacter:[self character]];   
    }
    
    if (![self character]) {
        int serverType = [_rdServerType indexOfItem:[_rdServerType selectedItem]];
        [[self preferences] setPreference:[NSNumber numberWithInt:serverType] forKey:@"atlantis.world.codebase" withCharacter:nil];
    }

    [[self preferences] endBulk];    
}

- (IBAction) serverTypeChanged:(id) sender
{
    if (![self character]) {
        int serverType = [_rdServerType indexOfItem:[_rdServerType selectedItem]];
        [[self preferences] setPreference:[NSNumber numberWithInt:serverType] forKey:@"atlantis.world.codebase" withCharacter:nil];
        
        if (serverType == 1) {
            NSNumber *rootLines = [[self preferences] preferenceForKey:@"atlantis.mainview.lines" withCharacter:[self character] fallback:YES];
            if (!rootLines) {
                [[self preferences] setPreference:[NSNumber numberWithInt:500] forKey:@"atlantis.mainview.lines" withCharacter:[self character]];
            }
        }
    }
}

- (void) characterWasUpdated:(NSNotification *)notification
{
    NSString *oldCharacter = [[notification userInfo] objectForKey:@"RDAtlantisCharacterOld"];

    BOOL update = NO;

    if ([self character] && [[self character] isEqualToString:oldCharacter]) {
        update = YES;
    }

    [super characterWasUpdated:notification];
    
    if (update) {
        [_rdCharacterInternal setStringValue:[self character]];
        [[_rdCharacterName cell] setPlaceholderString:[self character]];
    } 
}

- (void) worldWasUpdated:(NSNotification *)notification
{
    NSString *result = @"";
    
    NSDate *tempDate = [[self preferences] preferenceForKey:@"atlantis.stats.lastConnect" withCharacter:[self character] fallback:NO];

    if (tempDate) {
        result = [tempDate description];
    }

    [_rdLastConnected setStringValue:result];
    
    NSNumber *totalConnections = [[self preferences] preferenceForKey:@"atlantis.stats.totalConnections" withCharacter:[self character] fallback:NO];
    if (totalConnections) {
        result = [totalConnections description];
    }
    else {
        result = @"0";
    }
    
    [_rdTotalConnections setStringValue:result];
    
    NSNumber *numResult;
    NSNumber *numResult2;
    

    numResult = [[self preferences] preferenceForKey:@"atlantis.world.autoconnect" withCharacter:[self character] fallback:NO];
    numResult2 = [[self preferences] preferenceForKey:@"atlantis.world.autoopen" withCharacter:[self character] fallback:NO];
    if (numResult && [numResult boolValue]) {
        [_rdAutopicker setEnabled:YES];
        [_rdAutopicker selectItemAtIndex:1];
        [_rdAutoconnect setState:NSOnState];
    }
    else if (numResult2 && [numResult2 boolValue]) {
        [_rdAutopicker setEnabled:YES];
        [_rdAutopicker selectItemAtIndex:0];
        [_rdAutoconnect setState:NSOnState];
    }
    else {
        [_rdAutoconnect setState:NSOffState];
        [_rdAutopicker setEnabled:NO];
    }
    
    numResult = [[self preferences] preferenceForKey:@"atlantis.network.keepalive" withCharacter:nil fallback:NO];
    if (numResult) {
        [_rdKeepaliveLogic selectItemAtIndex:[numResult intValue]];
    }
    else {
        [_rdKeepaliveLogic selectItemAtIndex:0];
    }


    result = [[self preferences] preferenceForKey:@"atlantis.world.name" withCharacter:nil fallback:NO];
    if (result)
        [[_rdWorldName cell] setPlaceholderString:result];
    else
        [[_rdWorldName cell] setPlaceholderString:@""];

    result = [[self preferences] preferenceForKey:@"atlantis.world.name" withCharacter:[self character] fallback:NO];
    if (result)
        [_rdWorldName setStringValue:result];
    else
        [_rdWorldName setStringValue:@""];
    
    result = [[self preferences] preferenceForKey:@"atlantis.world.host" withCharacter:nil fallback:NO];
    if (result)
        [[_rdHostName cell] setPlaceholderString:result];
    else
        [[_rdHostName cell] setPlaceholderString:@""];
        
        
    result = [[self preferences] preferenceForKey:@"atlantis.world.host" withCharacter:[self character] fallback:NO];
    if (result)
        [_rdHostName setStringValue:result];
    else
        [_rdHostName setStringValue:@""];
    
    numResult = [[self preferences] preferenceForKey:@"atlantis.world.port" withCharacter:nil fallback:NO];
    if (numResult)
        [[_rdHostPort cell] setPlaceholderString:[numResult description]];
    else
        [[_rdHostPort cell] setPlaceholderString:@""];

    numResult = [[self preferences] preferenceForKey:@"atlantis.world.port" withCharacter:[self character] fallback:NO];
    if (numResult) {
        [_rdHostPort setStringValue:[numResult description]];
        [_rdHostSSL setEnabled:YES];

        numResult = [[self preferences] preferenceForKey:@"atlantis.world.ssl" withCharacter:[self character] fallback:YES];
        if (numResult && [numResult boolValue]) {
            [_rdHostSSL setState:NSOnState];
        }
        else {
            [_rdHostSSL setState:NSOffState];
        }
    }
    else {
        [_rdHostPort setStringValue:@""];
        [_rdHostSSL setEnabled:NO];

        numResult = [[self preferences] preferenceForKey:@"atlantis.world.ssl" withCharacter:nil fallback:NO];
        if (numResult && [numResult boolValue]) {
            [_rdHostSSL setState:NSOnState];
        }
        else {
            [_rdHostSSL setState:NSOffState];
        }
        
    }
    
    [[_rdCharacterName cell] setPlaceholderString:[self character]];

    result = [[self preferences] preferenceForKey:@"atlantis.world.character" withCharacter:[self character] fallback:NO];
    if (result && (![self character] || ![result isEqualToString:[self character]]))
        [_rdCharacterName setStringValue:result];
    else
        [_rdCharacterName setStringValue:@""];

    result = [[self preferences] preferenceForKey:@"atlantis.world.password" withCharacter:[self character] fallback:NO];
    if (result)
        [_rdCharacterPass setStringValue:result];    
    else
        [_rdCharacterPass setStringValue:@""];
    
    numResult = [[self preferences] preferenceForKey:@"atlantis.world.codebase" withCharacter:nil fallback:NO];
    if (numResult) {
        [_rdServerType selectItemAtIndex:[numResult intValue]];
    }

    if ([self character]) {
        [_rdServerType setEnabled:NO];
        [_rdCharacterInternal setStringValue:[self character]];
        [_rdCharacterInternal setEnabled:YES];
        [_rdKeepaliveLogic setEnabled:NO];
    }
    else {
        [_rdServerType setEnabled:YES];
        [_rdCharacterInternal setEnabled:NO];
        [_rdKeepaliveLogic setEnabled:YES];
    }
        
}


@end
