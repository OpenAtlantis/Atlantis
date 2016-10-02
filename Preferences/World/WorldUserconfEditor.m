//
//  WorldUserconfEditor.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/19/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldUserconfEditor.h"


@implementation WorldUserconfEditor

+ (BOOL) globalTab
{
    return YES;
}

- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *) character
{
    self = [super initWithWorld:prefs forCharacter:character];
    if (self) {
        _rdUserConf = [[NSDictionary dictionary] mutableCopy];
        _rdUserConfKeys = [[NSArray array] mutableCopy];
        [NSBundle loadNibNamed:@"WorldConf_UserConf" owner:self];
        [_rdUserConfTable setDelegate:self];
        [_rdUserConfTable setDataSource:self];
        [self worldWasUpdated:nil];
    }
    return self;
}

- (void) dealloc
{
    [_rdUserConfKeys release];
    [_rdUserConf release];
    [super dealloc];
}

- (NSString *) configTabName
{
    return @"User Variables";
}

- (NSView *) configTabView
{
    return _rdConfigView;
}

- (void) finalCommit
{
    NSDictionary *userConf = [NSDictionary dictionaryWithDictionary:_rdUserConf];
    [[self preferences] setPreference:userConf forKey:@"atlantis.userconf" withCharacter:[self character]];
}

- (void) worldWasUpdated:(NSNotification *)notification
{
    if ([self shouldUpdateForNotification:notification]) {
        NSDictionary *newUserConf = [[self preferences] preferenceForKey:@"atlantis.userconf" withCharacter:[self character] fallback:NO];
        
        if (newUserConf) {
            [[_rdConfigView window] makeFirstResponder:[_rdConfigView window]];
            [_rdUserConf release];
            _rdUserConf = [[NSDictionary dictionaryWithDictionary:newUserConf] mutableCopy];
            [_rdUserConfKeys removeAllObjects];
            [_rdUserConfKeys addObjectsFromArray:[_rdUserConf keysSortedByValueUsingSelector:@selector(compare:)]];
            [_rdUserConfTable reloadData];
        }        
    }
}

#pragma mark Table Datasource

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_rdUserConfKeys count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    NSString *curKey = [_rdUserConfKeys objectAtIndex:rowIndex];
    NSString *curValue = [_rdUserConf objectForKey:curKey];
    
    if ([[aTableColumn identifier] isEqualToString:@"userconfKey"]) {
        return curKey;
    }
    else if ([[aTableColumn identifier] isEqualToString:@"userconfValue"]) {
        return curValue;
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    NSString *curKey = [_rdUserConfKeys objectAtIndex:rowIndex];
    NSString *curValue = [_rdUserConf objectForKey:curKey];

    if ([[aTableColumn identifier] isEqualToString:@"userconfKey"]) {
        if (![anObject isEqualToString:curKey]) {
            if (![_rdUserConf objectForKey:anObject]) {
                [_rdUserConf setObject:curValue forKey:anObject];
                [_rdUserConf removeObjectForKey:curKey];
                [_rdUserConfKeys replaceObjectAtIndex:rowIndex withObject:anObject];
                [_rdUserConfTable reloadData];
            }
        }
    }
    else if ([[aTableColumn identifier] isEqualToString:@"userconfValue"]) {
        if (anObject)
            [_rdUserConf setObject:anObject forKey:curKey];
        else
            [_rdUserConf setObject:@"" forKey:curKey];
        [_rdUserConfTable reloadData];
    }
}

#pragma mark Commands

- (void) addButton:(id) sender
{
    [[_rdConfigView window] makeFirstResponder:[_rdConfigView window]];

    int counter = 1;
    NSString *test;
    
    test = [_rdUserConf objectForKey:@"<name>"];
    while (test) {
        counter++;
        test = [_rdUserConf objectForKey:[NSString stringWithFormat:@"<name%d>", counter]];
    }
    
    if (counter == 1) {
        [_rdUserConf setObject:@"<value>" forKey:@"<name>"];
        [_rdUserConfKeys addObject:@"<name>"];
    }
    else {
        NSString *tempString = [NSString stringWithFormat:@"<name%d>", counter];
        [_rdUserConf setObject:@"<value>" forKey:tempString];
        [_rdUserConfKeys addObject:tempString];
    }

    [_rdUserConfTable reloadData];
    
    int selectedRow = [_rdUserConfKeys count] - 1;
    [_rdUserConfTable selectRow:selectedRow byExtendingSelection:NO];
    [_rdUserConfTable editColumn:0 row:selectedRow withEvent:nil select:YES];
}

- (void) deleteButton:(id) sender
{
    [[_rdConfigView window] makeFirstResponder:[_rdConfigView window]];
    int rowIndex = [_rdUserConfTable selectedRow];
    
    if (rowIndex != -1) {
        NSString *curKey = [_rdUserConfKeys objectAtIndex:rowIndex];

        [_rdUserConf removeObjectForKey:curKey];
        [_rdUserConfKeys removeObjectAtIndex:rowIndex];
        [_rdUserConfTable reloadData];
    }
}
@end
