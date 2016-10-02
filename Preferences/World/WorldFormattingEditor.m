//
//  WorldFormattingEditor.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/11/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldFormattingEditor.h"
#import "RDAtlantisMainController.h"
#import "RDView.h"

@interface WorldFormattingEditor (Private)
- (NSFont *) font;
- (void) setFont:(NSFont *) font;
- (void) frameChanged:(NSNotification *) notification;
@end

@implementation WorldFormattingEditor

+ (BOOL) globalTab
{
    return YES;
}

- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *) character
{
    self = [super initWithWorld:prefs forCharacter:character];
    if (self) {
        [NSBundle loadNibNamed:@"WorldConf_Formatting" owner:self];

        _rdGlobal = NO;
    
        if ([self preferences] == [[RDAtlantisMainController controller] globalWorld])
            _rdGlobal = YES;

        _rdFont = nil;
        
        const NSStringEncoding *encoding;
        
        [_rdCodepage removeAllItems];
        [_rdCodepage addItemWithTitle:@"Default (Attempt autodetect)"];
        [[_rdCodepage lastItem] setTag:0];
        
        for (encoding = [NSString availableStringEncodings]; *encoding != 0; encoding++) {
            [_rdCodepage addItemWithTitle:[NSString localizedNameOfStringEncoding:*encoding]];
            [[_rdCodepage lastItem] setTag:*encoding];
        }        
        
        [_rdAnsiColor00 setTarget:self];
        [_rdAnsiColor00 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor01 setTarget:self];
        [_rdAnsiColor01 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor02 setTarget:self];
        [_rdAnsiColor02 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor03 setTarget:self];
        [_rdAnsiColor03 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor04 setTarget:self];
        [_rdAnsiColor04 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor05 setTarget:self];
        [_rdAnsiColor05 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor06 setTarget:self];
        [_rdAnsiColor06 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor07 setTarget:self];
        [_rdAnsiColor07 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor08 setTarget:self];
        [_rdAnsiColor08 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor09 setTarget:self];
        [_rdAnsiColor09 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor10 setTarget:self];
        [_rdAnsiColor10 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor11 setTarget:self];
        [_rdAnsiColor11 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor12 setTarget:self];
        [_rdAnsiColor12 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor13 setTarget:self];
        [_rdAnsiColor13 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor14 setTarget:self];
        [_rdAnsiColor14 setAction:@selector(colorWasSet:)];
        [_rdAnsiColor15 setTarget:self];
        [_rdAnsiColor15 setAction:@selector(colorWasSet:)];
        
        [(RDView *)_rdConfigView setDelegate:self];
        [self worldWasUpdated:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_rdFont release];
    [super dealloc];
}

- (NSString *) configTabName
{
    return @"Formatting";
}

- (NSView *) configTabView
{
    return _rdConfigView;
}

- (void) colorWasSet:(id)sender
{
    if ([_rdAnsiDefaults state] == NSOffState) {
        NSArray *colors = [[self preferences] preferenceForKey:@"atlantis.colors.ansi" withCharacter:[self character]];
        NSMutableArray *newColors = [colors mutableCopy];
        
        int index = -1;
        
        if (sender == _rdAnsiColor00)
            index = 0;
        else if (sender == _rdAnsiColor01)
            index = 1;
        else if (sender == _rdAnsiColor02)
            index = 2;
        else if (sender == _rdAnsiColor03)
            index = 3;
        else if (sender == _rdAnsiColor04)
            index = 4;
        else if (sender == _rdAnsiColor05)
            index = 5;
        else if (sender == _rdAnsiColor06)
            index = 6;
        else if (sender == _rdAnsiColor07)
            index = 7;
        else if (sender == _rdAnsiColor08)
            index = 8;
        else if (sender == _rdAnsiColor09)
            index = 9;
        else if (sender == _rdAnsiColor10)
            index = 10;
        else if (sender == _rdAnsiColor11)
            index = 11;
        else if (sender == _rdAnsiColor12)
            index = 12;
        else if (sender == _rdAnsiColor13)
            index = 13;
        else if (sender == _rdAnsiColor14)
            index = 14;
        else if (sender == _rdAnsiColor15)
            index = 15;
            
        if (index != -1) {
            [newColors replaceObjectAtIndex:index withObject:[sender color]];
            [[self preferences] setPreference:newColors forKey:@"atlantis.colors.ansi" withCharacter:[self character]];
        }
        [newColors release];
    }
}

- (void) finalCommit
{
    [[self preferences] beginBulk];
    
    if (_rdGlobal || ([_rdAnsiDefaults state] == NSOffState)) {
        NSMutableArray *colors;
        
        colors = [[NSMutableArray alloc] init];
        
        [colors addObject:[_rdAnsiColor00 color]];
        [colors addObject:[_rdAnsiColor01 color]];
        [colors addObject:[_rdAnsiColor02 color]];
        [colors addObject:[_rdAnsiColor03 color]];
        [colors addObject:[_rdAnsiColor04 color]];
        [colors addObject:[_rdAnsiColor05 color]];
        [colors addObject:[_rdAnsiColor06 color]];
        [colors addObject:[_rdAnsiColor07 color]];
        [colors addObject:[_rdAnsiColor08 color]];
        [colors addObject:[_rdAnsiColor09 color]];
        [colors addObject:[_rdAnsiColor10 color]];
        [colors addObject:[_rdAnsiColor11 color]];
        [colors addObject:[_rdAnsiColor12 color]];
        [colors addObject:[_rdAnsiColor13 color]];
        [colors addObject:[_rdAnsiColor14 color]];
        [colors addObject:[_rdAnsiColor15 color]];
        
        [[self preferences] setPreference:colors forKey:@"atlantis.colors.ansi" withCharacter:[self character]];
        [[self preferences] setPreference:[_rdUrlColor color] forKey:@"atlantis.colors.url" withCharacter:[self character]];
        [[self preferences] setPreference:[_rdConsoleColor color] forKey:@"atlantis.colors.system" withCharacter:[self character]];
        [[self preferences] setPreference:[_rdBackgroundColor color] forKey:@"atlantis.colors.background" withCharacter:[self character]];
        [[self preferences] setPreference:[_rdForegroundColor color] forKey:@"atlantis.colors.default" withCharacter:[self character]];
        [[self preferences] setPreference:[_rdSelectionColor color] forKey:@"atlantis.colors.selection" withCharacter:[self character]];
        
        NSNumber *bolding = [NSNumber numberWithBool:([_rdAnsiBolding state] == NSOnState)];
        [[self preferences] setPreference:bolding forKey:@"atlantis.formatting.boldIntense" withCharacter:[self character]];
        
        [colors release];
    }
    else {
        [[self preferences] removePreferenceForKey:@"atlantis.formatting.boldIntense" withCharacter:[self character]];
        [[self preferences] removePreferenceForKey:@"atlantis.colors.ansi" withCharacter:[self character]];
        [[self preferences] removePreferenceForKey:@"atlantis.colors.url" withCharacter:[self character]];
        [[self preferences] removePreferenceForKey:@"atlantis.colors.system" withCharacter:[self character]];
        [[self preferences] removePreferenceForKey:@"atlantis.colors.background" withCharacter:[self character]];
        [[self preferences] removePreferenceForKey:@"atlantis.colors.default" withCharacter:[self character]];
        [[self preferences] removePreferenceForKey:@"atlantis.colors.selection" withCharacter:[self character]];
    }
    
    int indent = [_rdIndent intValue];
    if ([_rdIndentDefault state] == NSOffState) {
        [[self preferences] setPreference:[NSNumber numberWithInt:indent] forKey:@"atlantis.formatting.indent" withCharacter:[self character]];
    }
    else {
        [[self preferences] removePreferenceForKey:@"atlantis.formatting.indent" withCharacter:[self character]];
    }
    
    if ([_rdLocalEchoDefault state] == NSOffState) {
        BOOL echo = NO;
        if ([_rdLocalEcho state] == NSOnState)
            echo = YES;
            
        BOOL timestamps = NO;
        if ([_rdTimestamps state] == NSOnState)
            timestamps = YES;
            
        NSString *prefix = [_rdLocalEchoPrefix stringValue];
        if (!prefix)
            prefix = @"> ";
            
        [[self preferences] setPreference:[NSNumber numberWithBool:echo] forKey:@"atlantis.text.localEcho" withCharacter:[self character]];
        [[self preferences] setPreference:prefix forKey:@"atlantis.text.localEchoPrefix" withCharacter:[self character]];
        [[self preferences] setPreference:[NSNumber numberWithBool:timestamps] forKey:@"atlantis.formatting.timestamps" withCharacter:[self character]];
    }
    else {
        [[self preferences] removePreferenceForKey:@"atlantis.text.localEcho" withCharacter:[self character]];
        [[self preferences] removePreferenceForKey:@"atlantis.text.localEchoPrefix" withCharacter:[self character]];
        [[self preferences] removePreferenceForKey:@"atlantis.formatting.timestamps" withCharacter:[self character]];
    }
    
    if (_rdFont)
        [[self preferences] setPreference:_rdFont forKey:@"atlantis.formatting.font" withCharacter:[self character]];
    else
        [[self preferences] removePreferenceForKey:@"atlantis.formatting.font" withCharacter:[self character]];
    
    if ([_rdCodepageDefault state] == NSOnState) {
        [[self preferences] removePreferenceForKey:@"atlantis.encoding" withCharacter:[self character]];
    }
    else {
        unsigned int codepage = [[_rdCodepage selectedItem] tag];
        [[self preferences] setPreference:[NSNumber numberWithUnsignedInt:codepage] forKey:@"atlantis.encoding" withCharacter:[self character]];
    }
    
    if ([_rdGrabpassDefault state] == NSOnState) {
        [[self preferences] removePreferenceForKey:@"atlantis.grab.password" withCharacter:[self character]];
    }
    else {
        [[self preferences] setPreference:[_rdGrabpass stringValue] forKey:@"atlantis.grab.password" withCharacter:[self character]];
    }
    
    if ([_rdRhost isEnabled] && ![_rdRhost isHidden]) {
        [[self preferences] setPreference:[NSNumber numberWithBool:([_rdRhost state] == NSOnState)] forKey:@"atlantis.world.rhost" withCharacter:[self character]];
    }
    
    [[self preferences] endBulk];
}

- (void) colorDefaults:(BOOL) defaults
{
    [_rdAnsiDefaults setState:(defaults ? NSOnState : NSOffState)];
    
    [_rdAnsiColor00 setEnabled:!defaults];
    [_rdAnsiColor01 setEnabled:!defaults];
    [_rdAnsiColor02 setEnabled:!defaults];
    [_rdAnsiColor03 setEnabled:!defaults];
    [_rdAnsiColor04 setEnabled:!defaults];
    [_rdAnsiColor05 setEnabled:!defaults];
    [_rdAnsiColor06 setEnabled:!defaults];
    [_rdAnsiColor07 setEnabled:!defaults];
    [_rdAnsiColor08 setEnabled:!defaults];
    [_rdAnsiColor09 setEnabled:!defaults];
    [_rdAnsiColor10 setEnabled:!defaults];
    [_rdAnsiColor11 setEnabled:!defaults];
    [_rdAnsiColor12 setEnabled:!defaults];
    [_rdAnsiColor13 setEnabled:!defaults];
    [_rdAnsiColor14 setEnabled:!defaults];
    [_rdAnsiColor15 setEnabled:!defaults];
    
    [_rdAnsiBolding setEnabled:!defaults];
    
    [_rdUrlColor setEnabled:!defaults];
    [_rdConsoleColor setEnabled:!defaults];
    [_rdBackgroundColor setEnabled:!defaults];
    [_rdForegroundColor setEnabled:!defaults];
    [_rdSelectionColor setEnabled:!defaults];
}

- (void) changeFont:(id) sender
{
    NSFontManager *fontManager = sender;
    NSFont *newFont;
    NSFont *oldFont;

    oldFont = [self font];
    newFont = [fontManager convertFont:oldFont];
    [self setFont:newFont];
}


- (IBAction) chooseFont: (id) sender
{
    NSFontManager *fontMan = [NSFontManager sharedFontManager];
    NSFont *oldFont;

    oldFont = _rdFont;
    if (!oldFont) {
        oldFont = [[self preferences] preferenceForKey:@"atlantis.formatting.font" withCharacter:[self character]];
        if (!oldFont)
            oldFont = [NSFont fontWithName:@"Courier" size:10.0f];
    }
        
    [fontMan setSelectedFont:oldFont isMultiple:NO];
    [fontMan orderFrontFontPanel:self];    
}

- (IBAction) chooseCodepage: (id) sender
{
    if ([_rdCodepageDefault state] == NSOnState) {
        [[self preferences] removePreferenceForKey:@"atlantis.encoding" withCharacter:[self character]];
    }
    else {
        unsigned int codepage = [[_rdCodepage selectedItem] tag];
        [[self preferences] setPreference:[NSNumber numberWithUnsignedInt:codepage] forKey:@"atlantis.encoding" withCharacter:[self character]];
    }
}

- (NSFont *) font
{
    NSFont *oldFont = _rdFont;
    if (!oldFont) {
        oldFont = [[self preferences] preferenceForKey:@"atlantis.formatting.font" withCharacter:[self character]];
        if (!oldFont)
            oldFont = [NSFont fontWithName:@"Courier" size:10.0f];
    }
    return oldFont;
}

- (void) setFont:(NSFont *) font
{
    [_rdFont release];
    _rdFont = [font retain];
    [self toggleDefault:_rdFontDefault]; // Force font stuff to refresh
}

- (void) toggleDefault:(id) sender
{
    BOOL enabled = ([sender state] == NSOnState);

    if (sender == _rdFontDefault) {        
        if (enabled) {
            [_rdFont release];
            _rdFont = nil;
            [[self preferences] removePreferenceForKey:@"atlantis.formatting.font" withCharacter:[self character]];
            
            NSFont *tempFont = [[self preferences] preferenceForKey:@"atlantis.formatting.font" withCharacter:[self character]];
            if (!tempFont) {
                tempFont = [NSFont fontWithName:@"Courier" size:10.0f];
            }
            
            [_rdFontChange setEnabled:NO];
            NSString *fontDescription = [NSString stringWithFormat:@"%@ - %.0fpt",
                [tempFont displayName], [tempFont pointSize]];
                
            [[_rdFontName cell] setPlaceholderString:fontDescription];
            [_rdFontName setStringValue:@""];                
        }
        else {
            [_rdFontChange setEnabled:YES];
            NSFont *tempFont = _rdFont;
            if (!tempFont) {
                tempFont = [[self preferences] preferenceForKey:@"atlantis.formatting.font" withCharacter:[self character]];
                if (!tempFont)
                    tempFont = [NSFont fontWithName:@"Courier" size:10.0f];
            }
            
            NSString *fontDescription = [NSString stringWithFormat:@"%@ - %.0fpt",
                [tempFont displayName], [tempFont pointSize]];
                
            [_rdFontName setStringValue:fontDescription];
            _rdFont = [tempFont retain];
        }
    }
    
    else if (sender == _rdIndentDefault) {

        if (enabled) {
            [[self preferences] removePreferenceForKey:@"atlantis.formatting.indent" withCharacter:[self character]];
            [_rdIndentStepper setEnabled:NO];
        }
        else {
            [_rdIndentStepper setEnabled:YES];
        }
        
        int indent = 0;
        NSNumber *numTemp = [[self preferences] preferenceForKey:@"atlantis.formatting.indent" withCharacter:[self character]];
        if (numTemp)
            indent = [numTemp intValue];
        
        if (enabled) {
            [[_rdIndent cell] setPlaceholderString:[NSString stringWithFormat:@"%d", indent]];
            [_rdIndent setStringValue:@""];
        }
        else {
            [_rdIndent setIntValue:indent];    
            [_rdIndentStepper setIntValue:indent];
        }
            
    }    

    else if (sender == _rdLocalEchoDefault) {

        if (enabled) {
            [[self preferences] removePreferenceForKey:@"atlantis.text.localEcho" withCharacter:[self character]];
            [[self preferences] removePreferenceForKey:@"atlantis.text.localEchoPrefix" withCharacter:[self character]];
            [[self preferences] removePreferenceForKey:@"atlantis.formatting.timestamps" withCharacter:[self character]];
            [_rdLocalEcho setEnabled:NO];
            [_rdTimestamps setEnabled:NO];
            [_rdLocalEchoPrefix setEnabled:NO];
        }
        else {
            [_rdLocalEcho setEnabled:YES];
            [_rdTimestamps setEnabled:YES];
            [_rdLocalEchoPrefix setEnabled:YES];
        }
        
        NSNumber *tempNumber = [[self preferences] preferenceForKey:@"atlantis.text.localEcho" withCharacter:[self character]];
        BOOL localEcho = [tempNumber boolValue];
        
        if (localEcho) {
            [_rdLocalEcho setState:NSOnState];
        }
        else {
            [_rdLocalEcho setState:NSOffState];
        }

        tempNumber = [[self preferences] preferenceForKey:@"atlantis.formatting.timestamps" withCharacter:[self character]];
        BOOL timestamps = [tempNumber boolValue];
        
        if (timestamps) {
            [_rdTimestamps setState:NSOnState];
        }
        else {
            [_rdTimestamps setState:NSOffState];
        }

    }    

    
    else if (sender == _rdAnsiDefaults) {
        [self colorDefaults:enabled];
        
        if (enabled) {
            [[self preferences] removePreferenceForKey:@"atlantis.formatting.boldIntense" withCharacter:[self character]];
            [[self preferences] removePreferenceForKey:@"atlantis.colors.ansi" withCharacter:[self character]];
            [[self preferences] removePreferenceForKey:@"atlantis.colors.url" withCharacter:[self character]];
            [[self preferences] removePreferenceForKey:@"atlantis.colors.system" withCharacter:[self character]];
            [[self preferences] removePreferenceForKey:@"atlantis.colors.background" withCharacter:[self character]];
            [[self preferences] removePreferenceForKey:@"atlantis.colors.selection" withCharacter:[self character]];
        }
        
        NSArray *colors = [[self preferences] preferenceForKey:@"atlantis.colors.ansi" withCharacter:[self character]];
        if (colors) {
            [_rdAnsiColor00 setColor:[colors objectAtIndex:0]];
            [_rdAnsiColor01 setColor:[colors objectAtIndex:1]];
            [_rdAnsiColor02 setColor:[colors objectAtIndex:2]];
            [_rdAnsiColor03 setColor:[colors objectAtIndex:3]];
            [_rdAnsiColor04 setColor:[colors objectAtIndex:4]];
            [_rdAnsiColor05 setColor:[colors objectAtIndex:5]];
            [_rdAnsiColor06 setColor:[colors objectAtIndex:6]];
            [_rdAnsiColor07 setColor:[colors objectAtIndex:7]];
            [_rdAnsiColor08 setColor:[colors objectAtIndex:8]];
            [_rdAnsiColor09 setColor:[colors objectAtIndex:9]];
            [_rdAnsiColor10 setColor:[colors objectAtIndex:10]];
            [_rdAnsiColor11 setColor:[colors objectAtIndex:11]];
            [_rdAnsiColor12 setColor:[colors objectAtIndex:12]];
            [_rdAnsiColor13 setColor:[colors objectAtIndex:13]];
            [_rdAnsiColor14 setColor:[colors objectAtIndex:14]];
            [_rdAnsiColor15 setColor:[colors objectAtIndex:15]];
        }
        
        NSColor *tempColor = [[self preferences] preferenceForKey:@"atlantis.colors.url" withCharacter:[self character]];
        if (!tempColor) {
            tempColor = [NSColor cyanColor];
        }
        [_rdUrlColor setColor:tempColor];

        tempColor = [[self preferences] preferenceForKey:@"atlantis.colors.system" withCharacter:[self character]];
        if (!tempColor) {
            tempColor = [NSColor yellowColor];
        }
        [_rdConsoleColor setColor:tempColor];
        
        tempColor = [[self preferences] preferenceForKey:@"atlantis.colors.selection" withCharacter:[self character]];
        if (!tempColor) {
            tempColor = [NSColor cyanColor];
        }
        [_rdSelectionColor setColor:tempColor];
    }
    
    else if (sender == _rdCodepageDefault) {
        if (enabled) {
            [_rdCodepage setEnabled:NO];
            [[self preferences] removePreferenceForKey:@"atlantis.encoding" withCharacter:[self character]];
        }
        else {
            [_rdCodepage setEnabled:YES];
            int encoding = [[_rdCodepage selectedItem] tag];
            [[self preferences] setPreference:[NSNumber numberWithUnsignedInt:encoding] forKey:@"atlantis.encoding" withCharacter:[self character]];
        }
    }
    
    else if (sender == _rdGrabpassDefault) {
        if (enabled) {
            [_rdGrabpass setEnabled:NO];
            [[self preferences] removePreferenceForKey:@"atlantis.grab.password" withCharacter:[self character]];
        }
        else {
            [_rdGrabpass setEnabled:YES];
            [[self preferences] setPreference:[_rdGrabpass stringValue] forKey:@"atlantis.grab.password" withCharacter:[self character]];
        }
    }
}


- (void) worldWasUpdated:(NSNotification *)notification
{
    [_rdFontDefault setEnabled:!_rdGlobal];
    [_rdIndentDefault setEnabled:!_rdGlobal];
    [_rdAnsiDefaults setEnabled:!_rdGlobal];
    [_rdLocalEchoDefault setEnabled:!_rdGlobal];
    [_rdCodepageDefault setEnabled:!_rdGlobal];
    [_rdGrabpassDefault setEnabled:!_rdGlobal];

    if (_rdGlobal || [self character]) {
        [_rdRhost setEnabled:NO];
        [_rdRhost setHidden:YES];
    }
    else {
        [_rdRhost setEnabled:YES];
        [_rdRhost setHidden:NO];    
    }

    NSArray *colors = [[self preferences] preferenceForKey:@"atlantis.colors.ansi" withCharacter:[self character] fallback:NO];

    if (!colors) {
        colors = [[self preferences] preferenceForKey:@"atlantis.colors.ansi" withCharacter:[self character] fallback:YES];

        if (!_rdGlobal) {
            [self colorDefaults:YES];
        }
        else {
            [self colorDefaults:NO];
            if (!colors || ![colors count]) {
                NSMutableArray * ansiColorArray = [[NSMutableArray alloc] initWithCapacity:16];
                
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.000 blue:0.000 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.800 green:0.000 blue:0.000 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.800 blue:0.000 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.800 green:0.800 blue:0.000 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.000 blue:0.800 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.800 green:0.000 blue:0.800 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.800 blue:0.800 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.800 green:0.800 blue:0.800 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.500 green:0.500 blue:0.500 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:1.000 green:0.000 blue:0.000 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:1.000 blue:0.000 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:1.000 green:1.000 blue:0.000 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.000 blue:1.000 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:1.000 green:0.000 blue:1.000 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:1.000 blue:1.000 alpha:1.0]];
                [ansiColorArray addObject:[NSColor colorWithCalibratedRed:1.000 green:1.000 blue:1.000 alpha:1.0]];
                
                [[self preferences] setPreference:ansiColorArray forKey:@"atlantis.colors.ansi" withCharacter:nil];
                [ansiColorArray release];
            }
        }
    }
    else {
        [self colorDefaults:NO];
    }

    NSNumber *encodingValue = [[self preferences] preferenceForKey:@"atlantis.encoding" withCharacter:[self character] fallback:NO];
    int encoding = 0;
    if (!encodingValue) {
        if (!_rdGlobal) {
            encodingValue = [[self preferences] preferenceForKey:@"atlantis.encoding" withCharacter:[self character] fallback:YES];
            [_rdCodepageDefault setState:NSOnState];
            [_rdCodepage setEnabled:NO];
        }
    }
    else {
        [_rdCodepage setEnabled:YES];
        [_rdCodepageDefault setState:NSOffState];
    }
    if (encodingValue)
        encoding = [encodingValue intValue];
        
    [_rdCodepage selectItemAtIndex:[_rdCodepage indexOfItemWithTag:encoding]];
        
    if (colors) {
        [_rdAnsiColor00 setColor:[colors objectAtIndex:0]];
        [_rdAnsiColor01 setColor:[colors objectAtIndex:1]];
        [_rdAnsiColor02 setColor:[colors objectAtIndex:2]];
        [_rdAnsiColor03 setColor:[colors objectAtIndex:3]];
        [_rdAnsiColor04 setColor:[colors objectAtIndex:4]];
        [_rdAnsiColor05 setColor:[colors objectAtIndex:5]];
        [_rdAnsiColor06 setColor:[colors objectAtIndex:6]];
        [_rdAnsiColor07 setColor:[colors objectAtIndex:7]];
        [_rdAnsiColor08 setColor:[colors objectAtIndex:8]];
        [_rdAnsiColor09 setColor:[colors objectAtIndex:9]];
        [_rdAnsiColor10 setColor:[colors objectAtIndex:10]];
        [_rdAnsiColor11 setColor:[colors objectAtIndex:11]];
        [_rdAnsiColor12 setColor:[colors objectAtIndex:12]];
        [_rdAnsiColor13 setColor:[colors objectAtIndex:13]];
        [_rdAnsiColor14 setColor:[colors objectAtIndex:14]];
        [_rdAnsiColor15 setColor:[colors objectAtIndex:15]];
    }
    
    NSColor *temp = [[self preferences] preferenceForKey:@"atlantis.colors.url" withCharacter:[self character] fallback:NO];    
    if (!temp) {
        temp = [[self preferences] preferenceForKey:@"atlantis.colors.url" withCharacter:[self character] fallback:YES];
        if (!temp)
            temp = [NSColor cyanColor];
    }
    [_rdUrlColor setColor:temp];
    
    temp = [[self preferences] preferenceForKey:@"atlantis.colors.system" withCharacter:[self character] fallback:NO];
    if (!temp) {
        temp = [[self preferences] preferenceForKey:@"atlantis.colors.system" withCharacter:[self character] fallback:YES];
        if (!temp)
            temp = [NSColor yellowColor];
    }
    [_rdConsoleColor setColor:temp];

    temp = [[self preferences] preferenceForKey:@"atlantis.colors.selection" withCharacter:[self character] fallback:NO];
    if (!temp) {
        temp = [[self preferences] preferenceForKey:@"atlantis.colors.selection" withCharacter:[self character] fallback:YES];
        if (!temp)
            temp = [NSColor cyanColor];
    }
    [_rdSelectionColor setColor:temp];


    temp = [[self preferences] preferenceForKey:@"atlantis.colors.background" withCharacter:[self character] fallback:NO];
    if (!temp) {
        temp = [[self preferences] preferenceForKey:@"atlantis.colors.background" withCharacter:[self character] fallback:YES];
        if (!temp)
            temp = [NSColor blackColor];
    }
    [_rdBackgroundColor setColor:temp];

    temp = [[self preferences] preferenceForKey:@"atlantis.colors.default" withCharacter:[self character] fallback:NO];
    if (!temp) {
        temp = [[self preferences] preferenceForKey:@"atlantis.colors.default" withCharacter:[self character] fallback:YES];
        if (!temp)
            temp = [colors objectAtIndex:7];
    }
    [_rdForegroundColor setColor:temp];

    
    NSNumber *boldNumber = [[self preferences] preferenceForKey:@"atlantis.formatting.boldIntense" withCharacter:[self character] fallback:NO];
    if (!boldNumber) {
        boldNumber = [[self preferences] preferenceForKey:@"atlantis.formatting.boldIntense" withCharacter:[self character] fallback:YES];
    }
    if (boldNumber && [boldNumber boolValue]) {
        [_rdAnsiBolding setState:NSOnState];
    }
    else {
        [_rdAnsiBolding setState:NSOffState];    
    }
    
    NSFont *tempFont = [[self preferences] preferenceForKey:@"atlantis.formatting.font" withCharacter:[self character] fallback:NO];
    NSString *fontDescription;
    if (!tempFont) {
        tempFont = [[self preferences] preferenceForKey:@"atlantis.formatting.font" withCharacter:[self character] fallback:YES];
        if (!tempFont) {
            tempFont = [NSFont fontWithName:@"Courier" size:10.0f];
        }
        
        [_rdFont release];
        _rdFont = nil;
        if (_rdGlobal) {
            _rdFont = [tempFont retain];
        }
        
        fontDescription = [NSString stringWithFormat:@"%@ - %.0fpt",
            [tempFont displayName], [tempFont pointSize]];        

        [[_rdFontName cell] setPlaceholderString:fontDescription];
    }
    else {
        [_rdFont release];
        _rdFont = [tempFont retain];
    }
    if (_rdFont) {
        fontDescription = [NSString stringWithFormat:@"%@ - %.0fpt",
            [_rdFont displayName], [_rdFont pointSize]];        

        [_rdFontName setStringValue:fontDescription];
        [_rdFontDefault setState:NSOffState];
        [_rdFontChange setEnabled:YES];
    }
    else {
        [_rdFontDefault setState:NSOnState];
        [_rdFontChange setEnabled:NO];
    }

    NSNumber *localEcho = [[self preferences] preferenceForKey:@"atlantis.text.localEcho" withCharacter:[self character] fallback:NO];
    NSNumber *timeStamp = [[self preferences] preferenceForKey:@"atlantis.formatting.timestamps" withCharacter:[self character] fallback:NO];
    if (!localEcho && !timeStamp) {
        localEcho = [[self preferences] preferenceForKey:@"atlantis.text.localEcho" withCharacter:[self character] fallback:YES];
        if (!localEcho) 
            localEcho = [NSNumber numberWithBool:NO];
            
        timeStamp = [[self preferences] preferenceForKey:@"atlantis.formatting.timestamps" withCharacter:[self character] fallback:YES];
        if (!timeStamp)
            timeStamp = [NSNumber numberWithBool:NO];

        NSString *prefix = [[self preferences] preferenceForKey:@"atlantis.text.localEchoPrefix" withCharacter:[self character] fallback:YES];
        if (!prefix)
            prefix = @"> ";

        [_rdLocalEchoPrefix setStringValue:prefix];
            
        // TODO -- check timestamp setting
        
        if ([localEcho boolValue])
            [_rdLocalEcho setState:NSOnState];
        else
            [_rdLocalEcho setState:NSOffState];
        
        if ([timeStamp boolValue])
            [_rdTimestamps setState:NSOnState];
        else
            [_rdTimestamps setState:NSOffState];
        
        if (!_rdGlobal) {
            [_rdLocalEchoDefault setState:NSOnState];
            [_rdLocalEcho setEnabled:NO];
            [_rdTimestamps setEnabled:NO];
            [_rdLocalEchoPrefix setEnabled:NO];
        }
        else {
            [_rdLocalEchoDefault setState:NSOffState];
            [_rdLocalEcho setEnabled:YES];
            [_rdTimestamps setEnabled:YES];
            [_rdLocalEchoPrefix setEnabled:YES];
        }
    }
    else {
        localEcho = [[self preferences] preferenceForKey:@"atlantis.text.localEcho" withCharacter:[self character] fallback:YES];
        if (!localEcho) 
            localEcho = [NSNumber numberWithBool:NO];
            
        timeStamp = [[self preferences] preferenceForKey:@"atlantis.formatting.timestamps" withCharacter:[self character] fallback:YES];
        if (!timeStamp)
            timeStamp = [NSNumber numberWithBool:NO];

        NSString *prefix = [[self preferences] preferenceForKey:@"atlantis.text.localEchoPrefix" withCharacter:[self character] fallback:YES];
        if (!prefix)
            prefix = @"> ";
            
        [_rdLocalEchoDefault setState:NSOffState];
        [_rdLocalEcho setEnabled:YES];
        if ([localEcho boolValue])
            [_rdLocalEcho setState:NSOnState];
        else
            [_rdLocalEcho setState:NSOffState];

        [_rdTimestamps setEnabled:YES];
        if ([timeStamp boolValue])
            [_rdTimestamps setState:NSOnState];
        else
            [_rdTimestamps setState:NSOffState];
        
        [_rdLocalEchoPrefix setStringValue:prefix];
    }
    
    NSNumber *indent = [[self preferences] preferenceForKey:@"atlantis.formatting.indent" withCharacter:[self character] fallback:NO];
    if (!indent) {
        indent = [[self preferences] preferenceForKey:@"atlantis.formatting.indent" withCharacter:[self character] fallback:YES];
        if (!indent)
            indent = [NSNumber numberWithInt:0];
            
        if (!_rdGlobal) {
            [[_rdIndent cell] setPlaceholderString:[indent description]];
            [_rdIndentDefault setState:NSOnState];
            [_rdIndent setStringValue:@""];
            [_rdIndentStepper setEnabled:NO];
        }
        else {
            [_rdIndentDefault setState:NSOffState];
            [_rdIndentStepper setEnabled:YES];
            [_rdIndent setIntValue:[indent intValue]];        
        }
    }
    else {
        [_rdIndentDefault setState:NSOffState];
        [_rdIndentStepper setEnabled:YES];
        [_rdIndentStepper setIntValue:[indent intValue]];
        [_rdIndent setIntValue:[indent intValue]];        
    }
    
    NSString *grabpass = [[self preferences] preferenceForKey:@"atlantis.grab.password" withCharacter:[self character] fallback:NO];
    if (!grabpass) {
        grabpass = [[self preferences] preferenceForKey:@"atlantis.grab.password" withCharacter:[self character] fallback:YES];
        if (!grabpass)
            grabpass = @"SimpleMUUser";
            
        if (!_rdGlobal) {
            [[_rdGrabpass cell] setPlaceholderString:grabpass];
            [_rdGrabpass setStringValue:@""];
            [_rdGrabpass setEnabled:NO];
            [_rdGrabpassDefault setState:NSOnState];
        }
        else {
            [_rdGrabpass setStringValue:grabpass];
            [_rdGrabpassDefault setState:NSOffState];
        }
    }
    else {
        [_rdGrabpass setStringValue:grabpass];
        [_rdGrabpassDefault setState:NSOffState];
    }
}


@end
