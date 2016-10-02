//
//  WorldHighlightEditor.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/11/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldHighlightEditor.h"
#import "RDColorWellCell.h"
#import "HighlightEvent.h"

@implementation WorldHighlightEditor

+ (BOOL) globalTab
{
    return YES;
}

- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *) character
{
    self = [super initWithWorld:prefs forCharacter:character];
    if (self) {
        [NSBundle loadNibNamed:@"WorldConf_Highlights" owner:self];

        [[_rdHighlightTypeColumn dataCell] removeAllItems];
        [[_rdHighlightTypeColumn dataCell] addItemWithTitle:@"begins with"];
        [[_rdHighlightTypeColumn dataCell] addItemWithTitle:@"is"];
        [[_rdHighlightTypeColumn dataCell] addItemWithTitle:@"contains"];
        [[_rdHighlightTypeColumn dataCell] addItemWithTitle:@"matches regexp"];
        
        [_rdHighlightTypeButton removeAllItems];
        [_rdHighlightTypeButton addItemWithTitle:@"begins with"];
        [_rdHighlightTypeButton addItemWithTitle:@"is"];
        [_rdHighlightTypeButton addItemWithTitle:@"contains"];
        [_rdHighlightTypeButton addItemWithTitle:@"matches regexp"];

        NSArray *tempArray = [prefs preferenceForKey:@"atlantis.highlights" withCharacter:character fallback:NO];
        if (tempArray) {
            _rdHighlights = [tempArray mutableCopy];
        }
        else {
            _rdHighlights = [[NSMutableArray alloc] init];
        }
        
        _rdSelfUpdate = NO;
        
        [_rdHighlightsTable setDelegate:self];
        [_rdHighlightsTable setDataSource:self];
        
        [_rdHighlightPattern setDelegate:self];
        
    }
    return self;
}

- (void) dealloc
{   
    [_rdHighlights release];
    [super dealloc];
}

- (NSString *) configTabName
{
    return @"Highlights";
}

- (NSView *) configTabView
{
    return _rdConfigView;
}

- (void) finalCommit
{
    _rdSelfUpdate = YES;
    if (_rdHighlights && [_rdHighlights count])
        [[self preferences] setPreference:[NSArray arrayWithArray:_rdHighlights] forKey:@"atlantis.highlights" withCharacter:[self character]];
    else
        [[self preferences] removePreferenceForKey:@"atlantis.highlights" withCharacter:[self character]];
    _rdSelfUpdate = NO;
}

- (void) worldWasUpdated:(NSNotification *)notification
{
    if (!_rdSelfUpdate && [self shouldUpdateForNotification:notification]) {
        [_rdHighlights release];
        _rdHighlights = nil;
        
        NSArray *tempArray = [[self preferences] preferenceForKey:@"atlantis.highlights" withCharacter:[self character] fallback:NO];
        if (tempArray) {
            _rdHighlights = [tempArray mutableCopy];
        }    
        
        [_rdHighlightsTable reloadData];
    }
}

#pragma mark Table Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    int row = [_rdHighlightsTable selectedRow];
    
    if (row != -1) {
        HighlightEvent *event = [_rdHighlights objectAtIndex:row];
    
        [_rdRemoveHighlightButton setEnabled:YES];
    
        [_rdHighlightUseBgButton setEnabled:YES];
        [_rdHighlightUseFgButton setEnabled:YES];
        [_rdHighlightTypeButton setEnabled:YES];
        [_rdHighlightPattern setEnabled:YES];

        NSColor *fg = [event foreground];
        NSColor *bg = [event background];
        
        if (fg) {
            [_rdHighlightUseFgButton setState:NSOnState];
            [_rdForegroundColorWell setEnabled:YES];
            [_rdForegroundColorWell setColor:fg];
        }
        else {
            [_rdHighlightUseFgButton setState:NSOffState];
            [_rdForegroundColorWell setEnabled:NO];
        }

        if (bg) {
            [_rdHighlightUseBgButton setState:NSOnState];
            [_rdBackgroundColorWell setEnabled:YES];
            [_rdBackgroundColorWell setColor:bg];
        }
        else {
            [_rdHighlightUseBgButton setState:NSOffState];
            [_rdBackgroundColorWell setEnabled:NO];
        }
        
        [_rdHighlightTypeButton selectItemAtIndex:[[event pattern] type]];
        [_rdHighlightPattern setStringValue:[[event pattern] pattern]];
    }
    else {
        [_rdRemoveHighlightButton setEnabled:NO];
        
        [_rdHighlightUseBgButton setEnabled:NO];
        [_rdHighlightUseFgButton setEnabled:NO];
        [_rdHighlightTypeButton setEnabled:NO];
        [_rdHighlightPattern setEnabled:NO];
        
        [_rdHighlightPattern setStringValue:@""];
        [_rdHighlightTypeButton selectItemAtIndex:0];
        
        [_rdForegroundColorWell setEnabled:NO];
        [_rdBackgroundColorWell setEnabled:NO];
    }
}

#pragma mark Table Data Source

- (int) numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_rdHighlights count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    HighlightEvent *tempevent = [_rdHighlights objectAtIndex:rowIndex];
    
    if (tempevent) {
        if ([[aTableColumn identifier] isEqualToString:@"highlightFg"]) {
            return [tempevent foreground];
        }
        else if ([[aTableColumn identifier] isEqualToString:@"highlightBg"]) {
            return [tempevent background];
        }
        else if ([[aTableColumn identifier] isEqualToString:@"highlightType"]) {
            return [NSNumber numberWithInt:[[tempevent pattern] type]];
        }
        else if ([[aTableColumn identifier] isEqualToString:@"highlightPattern"]) {
            return [[tempevent pattern] pattern];
        }
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    HighlightEvent *tempevent = [_rdHighlights objectAtIndex:rowIndex];
    
    RDStringPattern *newPattern = nil;
    
    if (tempevent) {
        if ([[aTableColumn identifier] isEqualToString:@"highlightType"]) {
            newPattern = [RDStringPattern patternWithString:[[tempevent pattern] pattern] type:[anObject intValue]];
        }
        else if ([[aTableColumn identifier] isEqualToString:@"highlightPattern"]) {
            newPattern = [RDStringPattern patternWithString:anObject type:[[tempevent pattern] type]];
        }
        
        if (newPattern) {
            [tempevent setPattern:newPattern];
            [self tableViewSelectionDidChange:nil];
        }            
    }
}

#pragma mark Actions

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    int row = [_rdHighlightsTable selectedRow];
    
    if (row != -1) {
        HighlightEvent *event = [_rdHighlights objectAtIndex:row];

        RDStringPattern *newPattern = 
            [RDStringPattern patternWithString:[_rdHighlightPattern stringValue] type:[[event pattern] type]];
        [event setPattern:newPattern];
        [_rdHighlightsTable reloadData];
        [self finalCommit];
    }
}


- (IBAction) addHighlight:(id) sender
{
    HighlightEvent *event = [[HighlightEvent alloc] init];
    
    if (!_rdHighlights) {
        _rdHighlights = [[NSMutableArray alloc] init];
    }
    
    [_rdHighlights addObject:event];
    [_rdHighlightsTable reloadData];
    int row = [_rdHighlights indexOfObject:event];
    if (row != NSNotFound) {
        [_rdHighlightsTable selectRow:row byExtendingSelection:NO];
    }
}

- (IBAction) removeHighlight:(id) sender
{
    [[_rdHighlightsTable window] makeFirstResponder:[_rdHighlightsTable window]];
    int row = [_rdHighlightsTable selectedRow];
    
    if (row != -1) {
        HighlightEvent *event = [_rdHighlights objectAtIndex:row];

        [_rdHighlights removeObject:event];
        [_rdHighlightsTable reloadData];
        [self finalCommit];
    }
}

- (IBAction) toggleForeground:(id) sender
{
    int row = [_rdHighlightsTable selectedRow];
    
    if (row != -1) {
        HighlightEvent *event = [_rdHighlights objectAtIndex:row];

        if ([_rdHighlightUseFgButton state] == NSOnState) {
            NSColor *tempFg = [_rdForegroundColorWell color];
    
            [_rdForegroundColorWell setEnabled:YES];
            [event setForeground:tempFg];
        }
        else {
            [event setForeground:nil];
            [_rdForegroundColorWell setEnabled:NO];
        }
        
        [_rdHighlightsTable reloadData];
        [self finalCommit];
    }
}

- (IBAction) toggleBackground:(id) sender
{
    int row = [_rdHighlightsTable selectedRow];
    
    if (row != -1) {
        HighlightEvent *event = [_rdHighlights objectAtIndex:row];

        if ([_rdHighlightUseBgButton state] == NSOnState) {
            NSColor *tempBg = [_rdBackgroundColorWell color];
    
            [_rdBackgroundColorWell setEnabled:YES];
            [event setBackground:tempBg];
        }
        else {
            [event setBackground:nil];
            [_rdBackgroundColorWell setEnabled:NO];
        }

        [_rdHighlightsTable reloadData];
        [self finalCommit];
    }

}

- (IBAction) changePatternType:(id) sender
{
    int row = [_rdHighlightsTable selectedRow];
    
    if (row != -1) {
        HighlightEvent *event = [_rdHighlights objectAtIndex:row];

        int position = [_rdHighlightTypeButton indexOfItem:[_rdHighlightTypeButton selectedItem]];
        
        RDStringPattern *newPattern = 
            [RDStringPattern patternWithString:[[event pattern] pattern] type:position];
        [event setPattern:newPattern];
        [_rdHighlightsTable reloadData];
        [self finalCommit];
    }
}

- (IBAction) changeColor:(id) sender
{
    int row = [_rdHighlightsTable selectedRow];
    
    if (row != -1) {
        HighlightEvent *event = [_rdHighlights objectAtIndex:row];
        
        if (sender == _rdForegroundColorWell) {
            NSColor *fg = [_rdForegroundColorWell color];
            [event setForeground:fg];
        }
        else if (sender == _rdBackgroundColorWell) {
            NSColor *bg = [_rdBackgroundColorWell color];
            [event setBackground:bg];    
        }
        
        [_rdHighlightsTable reloadData];
        [self finalCommit];
    }
}

@end
