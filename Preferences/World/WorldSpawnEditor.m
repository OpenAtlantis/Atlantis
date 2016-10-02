//
//  WorldSpawnEditor.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldSpawnEditor.h"
#import "RDStringPattern.h"
#import "RDSpawnConfigRecord.h"

@interface WorldSpawnRecord : NSObject {

    BOOL             _rdIsFolder;
    NSString        *_rdName;

    BOOL             _rdActivity;
    unsigned         _rdWeight;
    unsigned         _rdLines;
    BOOL             _rdStatusBar;
    
    NSString        *_rdPrefix;
    
    NSMutableArray  *_rdPatterns;
    NSMutableArray  *_rdExceptions;
    
    NSMutableArray  *_rdSubspawns;

}

- (NSString *) name;
- (void) setName:(NSString *)name;

- (BOOL) activity;
- (void) setActivity:(BOOL) activity;

- (unsigned) weight;
- (void) setWeight:(unsigned) weight;

- (unsigned) lines;
- (void) setLines:(unsigned) lines;

- (BOOL) statusBar;
- (void) setStatusBar:(BOOL) statusBar;

- (NSString *) prefix;
- (void) setPrefix:(NSString *) prefix;

- (NSArray *) subSpawns;
- (void) addSpawn:(WorldSpawnRecord *) record;
- (void) removeSpawn:(WorldSpawnRecord *) record;
- (void) removeAllSpawns;
- (WorldSpawnRecord *) spawnByName:(NSString *)name;
- (void) sortSpawns;

- (NSArray *) patterns;
- (void) setPatterns:(NSArray *)patterns;

- (NSArray *) exceptions;
- (void) setExceptions:(NSArray *)exceptions;

- (NSComparisonResult) compare:(WorldSpawnRecord *)record;

@end

@implementation WorldSpawnRecord

- (id) init
{
    self = [super init];
    if (self) {
        _rdPatterns = [[NSMutableArray alloc] init];
        _rdExceptions = [[NSMutableArray alloc] init];
        _rdName = nil;
        _rdWeight = 1;
        _rdLines = 0;
        _rdActivity = YES;
        _rdPrefix = nil;
        _rdStatusBar = YES;
        _rdSubspawns = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [_rdPrefix release];
    [_rdSubspawns release];
    [_rdPatterns release];
    [_rdExceptions release];
    [_rdName release];
    [super dealloc];
}

- (NSString *) name
{
    return _rdName;
}

- (void) setName:(NSString *)name
{
    [_rdName release];
    _rdName = [name retain];
}

- (BOOL) activity
{
    return _rdActivity;
}

- (void) setActivity:(BOOL) activity
{
    _rdActivity = activity;
}

- (unsigned) weight
{
    return _rdWeight;
}

- (void) setWeight:(unsigned) weight
{
    _rdWeight = weight;
}

- (unsigned) lines
{
    return _rdLines;
}

- (void) setLines:(unsigned) lines
{
    _rdLines = lines;
}

- (BOOL) statusBar
{
    return _rdStatusBar;
}

- (void) setStatusBar:(BOOL) statusBar
{
    _rdStatusBar = statusBar;
}

- (NSString *) prefix
{
    return _rdPrefix;
}

- (void) setPrefix:(NSString *) prefix
{
    [_rdPrefix release];
    _rdPrefix = [prefix retain];
}

- (NSArray *) patterns
{
    return _rdPatterns;
}

- (void) setPatterns:(NSArray *) patterns
{
    [_rdPatterns release];
    _rdPatterns = [patterns mutableCopy];
}

- (NSArray *) exceptions
{
    return _rdExceptions;
}

- (void) setExceptions:(NSArray *) exceptions
{
    [_rdExceptions release];
    _rdExceptions = [exceptions mutableCopy];
}

- (NSArray *) subSpawns
{
    return _rdSubspawns;
}

- (void) addSpawn:(WorldSpawnRecord *) record
{
    if (![_rdSubspawns containsObject:record])
        [_rdSubspawns addObject:record];
        
    [_rdSubspawns sortUsingSelector:@selector(compare:)];
}

- (void) removeSpawn:(WorldSpawnRecord *) record
{
    if ([_rdSubspawns containsObject:record])
        [_rdSubspawns removeObject:record];

}

- (void) removeAllSpawns
{
    [_rdSubspawns removeAllObjects];
}

- (WorldSpawnRecord *) spawnByName:(NSString *)spawn
{
    NSEnumerator *spawnEnum = [_rdSubspawns objectEnumerator];
    WorldSpawnRecord *result = nil;
    WorldSpawnRecord *walk;
    
    while (!result && (walk = [spawnEnum nextObject])) {
        if ([[walk name] isEqualToString:spawn])
            result = walk;
    }
    
    return result;
}

- (void) sortSpawns
{
    [_rdSubspawns sortUsingSelector:@selector(compare:)];
    
    NSEnumerator *spawnEnum = [_rdSubspawns objectEnumerator];
    WorldSpawnRecord *walk;
    
    while (walk = [spawnEnum nextObject]) {
        [walk sortSpawns];
    }
}

- (NSComparisonResult) compare:(WorldSpawnRecord *)other
{
    if ([self weight] == [other weight]) {
        NSString *selfName = [self name];
        NSString *otherName = [other name];
        
        if ([selfName length] && [otherName length]) {
            if (([selfName characterAtIndex:0] == '<') && ([otherName characterAtIndex:0] != '<')) {
                return NSOrderedDescending;
            }
            else if (([selfName characterAtIndex:0] != '<') && ([otherName characterAtIndex:0] == '<')) {
                return NSOrderedAscending;
            }
        }
            
        return [[self name] compare:[other name]];
    }
    else if ([self weight] < [other weight]) {
        return NSOrderedDescending;
    }
    else
        return NSOrderedAscending;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSMutableArray *array = nil;

    if ([aTableView tag] == 1) {
        array = _rdPatterns;
    }
    else if ([aTableView tag] == 2) {
        array = _rdExceptions;
    }
    
    if (array)
        return [array count];
        
    return 0;    
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    NSMutableArray *array = nil;

    if ([aTableView tag] == 1) {
        array = _rdPatterns;
    }
    else if ([aTableView tag] == 2) {
        array = _rdExceptions;
    }

    if (!array)
        return nil;
        
    if ((rowIndex < 0) || (rowIndex >= [array count]))
        return nil;

    RDStringPattern *pattern = [array objectAtIndex:rowIndex];
    
    if ([[aTableColumn identifier] isEqualToString:@"matchType"]) {
        return [NSNumber numberWithInt:[pattern type]];
    }
    else if ([[aTableColumn identifier] isEqualToString:@"matchPattern"]) {
        return [pattern pattern];
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    NSMutableArray *array = nil;

    if ([aTableView tag] == 1) {
        array = _rdPatterns;
    }
    else if ([aTableView tag] == 2) {
        array = _rdExceptions;
    }

    if (!array)
        return;
        
    if ((rowIndex < 0) || (rowIndex >= [array count]))
        return;

    RDStringPattern *pattern = [array objectAtIndex:rowIndex];
    RDStringPattern *newPattern;
    
    if ([[aTableColumn identifier] isEqualToString:@"matchType"]) {
        newPattern = [RDStringPattern patternWithString:[pattern pattern] type:[anObject intValue]];
    }
    else if ([[aTableColumn identifier] isEqualToString:@"matchPattern"]) {
        newPattern = [RDStringPattern patternWithString:anObject type:[pattern type]];
    }

    [array replaceObjectAtIndex:rowIndex withObject:newPattern];
}

@end

@interface WorldSpawnEditor (Private)
- (void) sortSpawns;
- (NSDictionary *) buildSpawnDictionary;
@end

@implementation WorldSpawnEditor

+ (BOOL) globalTab
{
    return YES;
}

- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *) character
{
    self = [super initWithWorld:prefs forCharacter:character];
    if (self) {
        [NSBundle loadNibNamed:@"WorldConf_Spawns" owner:self];
        
        _rdRootSpawn = [[WorldSpawnRecord alloc] init];
        
        [_rdPatternList setDelegate:self];
        [_rdExceptionList setDelegate:self];
        [_rdSpawnList setDelegate:self];
        [_rdSpawnList setDataSource:self];
        [_rdPriority setDelegate:self];
        [_rdLineField setDelegate:self];
        [_rdPrefixField setDelegate:self];
        
        NSTableColumn *typeColumn = [_rdPatternList tableColumnWithIdentifier:@"matchType"];
        if (typeColumn) {
            [[typeColumn dataCell] addItemWithTitle:@"begins with"];
            [[typeColumn dataCell] addItemWithTitle:@"is"];
            [[typeColumn dataCell] addItemWithTitle:@"contains"];
            [[typeColumn dataCell] addItemWithTitle:@"matches regexp"];
        }
        
        typeColumn = [_rdExceptionList tableColumnWithIdentifier:@"matchType"];
        if (typeColumn) {
            [[typeColumn dataCell] addItemWithTitle:@"begins with"];
            [[typeColumn dataCell] addItemWithTitle:@"is"];
            [[typeColumn dataCell] addItemWithTitle:@"contains"];
            [[typeColumn dataCell] addItemWithTitle:@"matches regexp"];
        }        
        
        [self worldWasUpdated:nil];
    }
    return self;
}

- (void) dealloc
{
    [_rdRootSpawn release];
    [super dealloc];
}

- (NSString *) configTabName
{
    return @"Spawns";
}

- (NSView *) configTabView
{
    return _rdConfigView;
}

- (WorldSpawnRecord *) addRecordsToPath:(NSString *) path
{
    NSMutableArray *pathComponents = [[[path componentsSeparatedByString:@":"] mutableCopy] autorelease];
    [pathComponents removeLastObject];
    
    NSEnumerator *pathEnum = [pathComponents objectEnumerator];
    
    NSString *pathWalk;
    
    WorldSpawnRecord *result = nil;
    
    while (pathWalk = [pathEnum nextObject]) {
        NSArray *tempSpawns;
        
        if (result) {
            tempSpawns = [result subSpawns];
        }
        else {
            tempSpawns = [_rdRootSpawn subSpawns];
        }
        
        NSEnumerator *spawnEnum = [tempSpawns objectEnumerator];
        WorldSpawnRecord *spawnWalk;
        BOOL done = NO;
        
        while (!done && (spawnWalk = [spawnEnum nextObject])) {
            if ([[spawnWalk name] isEqualToString:pathWalk])
                done = YES;
        }
        
        if (!spawnWalk) {
            spawnWalk = [[WorldSpawnRecord alloc] init];
            [spawnWalk setName:pathWalk];
            if (result) {
                [result addSpawn:spawnWalk];
            }
            else {
                [_rdRootSpawn addSpawn:spawnWalk];
            }
            [spawnWalk release];
        }
        
        result = spawnWalk;
    }
    
    return result;
}

- (WorldSpawnRecord *) recordForPath:(NSString *) path
{
    if ([path isEqualToString:@""])
        return nil;
        
    NSEnumerator *pathEnum = [[path componentsSeparatedByString:@":"] objectEnumerator];
    
    NSString *pathWalk;
    WorldSpawnRecord *result = nil;
    BOOL doneOuter = NO;
    
    while (!doneOuter && (pathWalk = [pathEnum nextObject])) {
        NSArray *tempSpawns;
        
        if (result) {
            tempSpawns = [result subSpawns];
        }
        else {
            tempSpawns = [_rdRootSpawn subSpawns];
        }
        
        NSEnumerator *spawnEnum = [tempSpawns objectEnumerator];
        WorldSpawnRecord *spawnWalk;
        BOOL done = NO;
        
        while (!done && (spawnWalk = [spawnEnum nextObject])) {
            if ([[spawnWalk name] isEqualToString:pathWalk])
                done = YES;
        }
        
        if (spawnWalk)
            result = spawnWalk;
        else {
            result = nil;
            doneOuter = YES;
        }
    }
    
    return result;
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
        NSString *result = [[self preferences] basePathForCharacter:[self character]];    
        if (result)
            [_rdRootSpawn setName:result];
    }        
}


- (void) worldWasUpdated:(NSNotification *)notification
{
    if ([self shouldUpdateForNotification:notification]) {
        NSDictionary *spawns = [[self preferences] preferenceForKey:@"atlantis.spawns" withCharacter:[self character] fallback:NO];
        if (spawns) {
            [_rdRootSpawn removeAllSpawns];
            
            NSNumber *mainWeight = [[self preferences] preferenceForKey:@"atlantis.mainview.weight" withCharacter:[self character] fallback:NO];
            NSNumber *mainActivity = [[self preferences] preferenceForKey:@"atlantis.mainview.activity" withCharacter:[self character] fallback:NO];
            NSNumber *mainLines = [[self preferences] preferenceForKey:@"atlantis.mainview.lines" withCharacter:[self character] fallback:NO];
            NSNumber *mainStatus = [[self preferences] preferenceForKey:@"atlantis.mainview.statusBar" withCharacter:[self character] fallback:NO];
            
            if (mainWeight)
                [_rdRootSpawn setWeight:[mainWeight intValue]];
            if (mainActivity)
                [_rdRootSpawn setActivity:[mainActivity boolValue]];
            if (mainLines)
                [_rdRootSpawn setLines:[mainLines intValue]];
            if (mainStatus) 
                [_rdRootSpawn setStatusBar:[mainStatus boolValue]];
                
            [_rdRootSpawn setName:[[self preferences] basePathForCharacter:[self character]]];
        
            NSEnumerator *spawnEnum = [spawns objectEnumerator];
            RDSpawnConfigRecord *spawn;
            
            while (spawn = [spawnEnum nextObject]) {
                NSString *spawnPath = [spawn path];
                NSString *name = [[spawnPath componentsSeparatedByString:@":"] lastObject];
                unsigned priority = [spawn weight];
                BOOL activity = [spawn defaultActive];
                unsigned lines = [spawn maxLines];
                
                NSArray *patterns = [spawn patterns];
                NSArray *exceptions = [spawn exceptions];
                
                WorldSpawnRecord *record;
                
                record = [self recordForPath:spawnPath];
                if (record) {
                    [record setName:name];
                    [record setWeight:priority];
                    [record setActivity:activity];
                    [record setPatterns:patterns];
                    [record setExceptions:exceptions];
                    [record setLines:lines];
                    [record setPrefix:[spawn prefix]];
                }
                else {
                    WorldSpawnRecord *parent = nil;
                    
                    NSRange testRange = [spawnPath rangeOfString:@":" options:NSBackwardsSearch];
                    NSString *tempPath;
                    if (testRange.length) {
                        tempPath = [spawnPath substringWithRange:NSMakeRange(0,testRange.location)];
                        parent = [self recordForPath:tempPath];
                        if (!parent) 
                            parent = [self addRecordsToPath:spawnPath];
                    }
                    
                    record = [[WorldSpawnRecord alloc] init];
                    [record setName:name];
                    [record setWeight:priority];
                    [record setLines:lines];
                    [record setActivity:activity];
                    [record setPatterns:patterns];
                    [record setExceptions:exceptions];
                    [record setPrefix:[spawn prefix]];
                    
                    if (parent) {
                        [parent addSpawn:record];
                    }
                    else {
                        [_rdRootSpawn addSpawn:record];
                    }
                    [record release];
                }
            }
            [_rdSpawnList reloadData];
            [self outlineViewSelectionDidChange:nil];        
        }
        else {
            [_rdRootSpawn setName:[[self preferences] basePathForCharacter:[self character]]];
            [_rdSpawnList reloadData];
            [self outlineViewSelectionDidChange:nil];        
        }
    }
}

- (void) finalCommit
{
    // This is gonna suuuuck
    NSDictionary *spawnDict = [self buildSpawnDictionary];

    [[self preferences] beginBulk];
    
    NSString *basePath = [[self preferences] basePathForCharacter:[self character]];
    NSString *rootPath = [_rdRootSpawn name];
    
    if (![basePath isEqualToString:rootPath])
        [[self preferences] setPreference:rootPath forKey:@"atlantis.world.displayName" withCharacter:[self character]];
    
    [[self preferences] setPreference:[NSNumber numberWithBool:[_rdRootSpawn activity]] forKey:@"atlantis.mainview.activity" withCharacter:[self character]];
    [[self preferences] setPreference:[NSNumber numberWithInt:[_rdRootSpawn weight]] forKey:@"atlantis.mainview.weight" withCharacter:[self character]];
    [[self preferences] setPreference:[NSNumber numberWithInt:[_rdRootSpawn lines]] forKey:@"atlantis.mainview.lines" withCharacter:[self character]];
    [[self preferences] setPreference:[NSNumber numberWithBool:[_rdRootSpawn statusBar]] forKey:@"atlantis.mainview.statusBar" withCharacter:[self character]];
    [[self preferences] setPreference:spawnDict forKey:@"atlantis.spawns" withCharacter:[self character]];    
    [[self preferences] endBulk];
    [super finalCommit];
}

- (void) buildSpawnDictionary:(NSMutableDictionary *)dict atPath:(NSMutableString *)path withSpawn:(WorldSpawnRecord *)spawn
{
    if (spawn != _rdRootSpawn) {
        RDSpawnConfigRecord *realSpawn;
    
        realSpawn = [[RDSpawnConfigRecord alloc] initWithPath:[NSString stringWithString:path] forPatterns:[spawn patterns] withExceptions:[spawn exceptions] weight:[spawn weight] defaultsActive:[spawn activity] activePatterns:nil maxLines:[spawn lines] prefix:[spawn prefix] statusBar:[spawn statusBar]];
        [dict setObject:realSpawn forKey:[NSString stringWithString:path]];
//        [realSpawn release];
    }
    
    if ([[spawn subSpawns] count]) {
        NSEnumerator *spawnEnum = [[spawn subSpawns] objectEnumerator];
        WorldSpawnRecord *spawnWalk;
        
        while (spawnWalk = [spawnEnum nextObject]) {
            NSMutableString *tempPath = [path mutableCopy];
        
            if (spawn != _rdRootSpawn)
                [tempPath appendString:@":"];
            [tempPath appendString:[spawnWalk name]];
            
            [self buildSpawnDictionary:dict atPath:tempPath withSpawn:spawnWalk];
            [tempPath release];
        }
    }
}

- (NSDictionary *) buildSpawnDictionary
{
    NSMutableDictionary *tempDict = [[[NSDictionary dictionary] mutableCopy] autorelease];

    [self buildSpawnDictionary:tempDict atPath:@"" withSpawn:_rdRootSpawn];
    return [NSDictionary dictionaryWithDictionary:tempDict];
}

#pragma mark Outline Data Source

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    WorldSpawnRecord *record = (WorldSpawnRecord *)item;
    
    if (record)
        return [[record subSpawns] count];
    else
        return 1;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    WorldSpawnRecord *record = (WorldSpawnRecord *)item;
    
    if (record && [[record subSpawns] count])
        return YES;
    
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
    WorldSpawnRecord *record = (WorldSpawnRecord *)item;
    
    if (record) {
        NSArray *array = [record subSpawns];
        
        if (array) {
            if ((index < 0) || (index >= [array count]))
                return nil;
            
            return [array objectAtIndex:index];        
        }
    }
    else {
        return _rdRootSpawn;
    }
    
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    WorldSpawnRecord *record = (WorldSpawnRecord *)item;
    
    return [record name];
}

- (void) reloadKeepingSelection
{
    int row;
    WorldSpawnRecord *spawn = nil;
    
    row = [_rdSpawnList selectedRow];
    if (row != -1) {
        spawn = [_rdSpawnList itemAtRow:row];
    }
    else
        spawn = _rdRootSpawn;
    
    [_rdSpawnList reloadData];
    if (spawn) {
        row = [_rdSpawnList rowForItem:spawn];
        if (row != -1) {
            [_rdSpawnList selectRow:row byExtendingSelection:NO];
        }
    }
    [self outlineViewSelectionDidChange:nil];
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    WorldSpawnRecord *record = (WorldSpawnRecord *)item;

    if (record) {
        if ([object length])
            [record setName:object];
        [self sortSpawns];
        [self reloadKeepingSelection];
    }
}

#pragma mark Outline Delegate

- (WorldSpawnRecord *) currentSelectedSpawn
{
    int selected = [_rdSpawnList selectedRow];
    
    if (selected != -1) {
        return [_rdSpawnList itemAtRow:selected];
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return YES;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    int selected = [_rdSpawnList selectedRow];
    
    if (selected != -1) {
        WorldSpawnRecord *record = [_rdSpawnList itemAtRow:selected];
        
        if (record && (record != _rdRootSpawn)) {
            [_rdRemoveSpawn setEnabled:YES];
        }
        else {
            [_rdRemoveSpawn setEnabled:NO];
        }
        
        if (record && (record != _rdRootSpawn)) {
            [_rdPatternList setDataSource:record];
            [_rdExceptionList setDataSource:record];
            [_rdAddPattern setEnabled:YES];
            [_rdAddException setEnabled:YES];
            [_rdRemovePattern setEnabled:YES];
            [_rdRemoveException setEnabled:YES];

            [_rdPatternList setEnabled:YES];
            [_rdExceptionList setEnabled:YES];
            [_rdPrefixField setEnabled:YES];
        }
        else {
            [_rdPatternList setDataSource:nil];
            [_rdExceptionList setDataSource:nil];
            [_rdAddPattern setEnabled:NO];
            [_rdAddException setEnabled:NO];
            [_rdRemovePattern setEnabled:NO];
            [_rdRemoveException setEnabled:NO];
            [_rdPrefixField setEnabled:NO];
        }
        [_rdAddSpawn setEnabled:YES];
        [_rdPriority setIntValue:[record weight]];
        [_rdPriority setEnabled:YES];
        [_rdPriorityStepper setIntValue:[record weight]];
        [_rdPriorityStepper setEnabled:YES];
        [_rdLineField setIntValue:[record lines]];
        [_rdLineField setEnabled:YES];
        if ([record prefix])
            [_rdPrefixField setStringValue:[record prefix]];
        else
            [_rdPrefixField setStringValue:@""];
        
        [_rdActivityButton setState:
            ([record activity] ? NSOnState : NSOffState)];
        [_rdActivityButton setEnabled:YES];
        [_rdStatusbarButton setState:
            ([record statusBar] ? NSOnState : NSOffState)];
        [_rdStatusbarButton setEnabled:YES];
        return;
    }
    else {
        [_rdRemoveSpawn setEnabled:NO];
        [_rdAddSpawn setEnabled:NO];
    } 
       
    [_rdPatternList setDataSource:nil];
    [_rdExceptionList setDataSource:nil];
    [_rdAddPattern setEnabled:NO];
    [_rdAddException setEnabled:NO];
    [_rdRemovePattern setEnabled:NO];
    [_rdRemoveException setEnabled:NO];
    [_rdPriority setEnabled:NO];
    [_rdPriority setStringValue:@""];
    [_rdPriorityStepper setEnabled:NO];
    [_rdLineField setStringValue:@""];
    [_rdLineField setEnabled:NO];
    [_rdPrefixField setStringValue:@""];
    [_rdPrefixField setEnabled:NO];
    [_rdActivityButton setEnabled:NO];
    [_rdActivityButton setState:NSOffState];
    [_rdStatusbarButton setEnabled:NO];
    [_rdStatusbarButton setState:NSOffState];
}

#pragma mark Table Delegate

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = [notification object];
    NSButton *button = nil;
    
    if ([tableView tag] == 1) {
        button = _rdRemovePattern;
    }
    else if ([tableView tag] == 2) {
        button = _rdRemoveException;
    }
    
    if ([tableView selectedRow] == -1)
        [button setEnabled:NO];
    else
        [button setEnabled:YES];
}

#pragma mark Actions

- (void) sortSpawns
{
    [_rdRootSpawn sortSpawns];
}

- (void) priorityChanged:(id) sender
{
    WorldSpawnRecord *current = [self currentSelectedSpawn];

    [current setWeight:[sender intValue]];
    
    [_rdPriority setIntValue:[sender intValue]];
    [_rdPriorityStepper setIntValue:[sender intValue]];
    [self sortSpawns];
    [self reloadKeepingSelection];
}

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    if ([notification object] == _rdLineField) {
        WorldSpawnRecord *current = [self currentSelectedSpawn];
        
        unsigned lines = [_rdLineField intValue];
        [current setLines:lines];
        [_rdLineField setIntValue:lines];
    }
    else if ([notification object] == _rdPrefixField) {
        WorldSpawnRecord *current = [self currentSelectedSpawn];
        
        NSString *tempString = [_rdPrefixField stringValue];
        if (![tempString isEqualToString:@""]) {
            [current setPrefix:tempString];
        }
        else {
            [current setPrefix:nil];
        }
    }
}

- (IBAction) addSpawn:(id) sender
{
    [[_rdSpawnList window] makeFirstResponder:[_rdSpawnList window]];

    WorldSpawnRecord *parent = [self currentSelectedSpawn];
    WorldSpawnRecord *newSpawn;
    
    newSpawn = [[WorldSpawnRecord alloc] init];
    
    int counter = 1;
    NSString *spawnName = @"<spawn01>";
    WorldSpawnRecord *subSpawn = [parent spawnByName:spawnName];
    
    while (subSpawn) {
        counter++;
        spawnName = [NSString stringWithFormat:@"<spawn%02d>", counter];
        subSpawn = [parent spawnByName:spawnName];
    }
    
    [newSpawn setName:spawnName];
    [newSpawn setWeight:0];
    [newSpawn setLines:[_rdRootSpawn lines]];
    
    if (parent)
        [parent addSpawn:newSpawn];
    else {
        [_rdRootSpawn addSpawn:newSpawn];
    }
    [_rdSpawnList reloadData];
    if (parent)
        [_rdSpawnList expandItem:parent];
    else
        [_rdSpawnList expandItem:_rdRootSpawn];
    
    int row = [_rdSpawnList rowForItem:newSpawn];
    if (row != -1) {
        [_rdSpawnList selectRow:row byExtendingSelection:NO];
        [_rdSpawnList editColumn:0 row:row withEvent:nil select:YES];
    }
    
//    [newSpawn release];
}

- (void) traverseAndRemove:(WorldSpawnRecord *) record within:(WorldSpawnRecord *)parent
{
    [parent removeSpawn:record];
    
    NSEnumerator *spawnEnum = [[parent subSpawns] objectEnumerator];
    WorldSpawnRecord *walk;
    while (walk = [spawnEnum nextObject]) {
        [self traverseAndRemove:record within:walk];
    }    
}


- (void) traverseAndRemove:(WorldSpawnRecord *) record
{
    [record retain];
    [self traverseAndRemove:record within:_rdRootSpawn];
    [record release];
}

- (void) askQuestion:(NSString *) question info:(NSString *) info action:(SEL)selector context:(void *) context
{
    NSAlert *alert =
        [NSAlert alertWithMessageText:question defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:info];
        
    NSArray *buttons = [alert buttons];
    NSButton *noButton = [buttons objectAtIndex:1];
    [noButton setKeyEquivalent:@"\e"];
        
    [alert beginSheetModalForWindow:[_rdSpawnList window] modalDelegate:self didEndSelector:selector contextInfo:context];
}

- (void)handleRemoveResult:(NSAlert *)alert returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
    WorldSpawnRecord *current = (WorldSpawnRecord *)contextInfo;
    
    if (current && (returnCode == NSAlertDefaultReturn)) {    
        int row = [_rdSpawnList rowForItem:current];
        if (row != -1) {
            [_rdSpawnList deselectRow:row];
        }
        [self traverseAndRemove:current];
        [_rdSpawnList reloadData];
    }
    [current autorelease];
}

- (IBAction) removeSpawn:(id) sender
{
    [[_rdSpawnList window] makeFirstResponder:[_rdSpawnList window]];

    WorldSpawnRecord *current = [self currentSelectedSpawn];
    [current retain];

    [self askQuestion:@"Really Remove?" info:@"Removing this spawn or folder will remove it and all its children." action:@selector(handleRemoveResult:returnCode:contextInfo:) context:current];
}

- (IBAction) toggleActivity:(id) sender
{
    WorldSpawnRecord *current = [self currentSelectedSpawn];

    [current setActivity:([_rdActivityButton state] == NSOnState)];
}

- (IBAction) toggleStatusBar:(id) sender
{
    WorldSpawnRecord *current = [self currentSelectedSpawn];

    [current setStatusBar:([_rdStatusbarButton state] == NSOnState)];
}


- (IBAction) addPattern:(id) sender
{
    [[_rdSpawnList window] makeFirstResponder:[_rdSpawnList window]];

    WorldSpawnRecord *current = [self currentSelectedSpawn];
    RDStringPattern *pattern = [RDStringPattern patternWithString:@"" type:RDPatternBeginsWith];
    
    NSMutableArray *patterns = [[current patterns] mutableCopy];
    [patterns addObject:pattern];
    [current setPatterns:[NSArray arrayWithArray:patterns]];
    [_rdPatternList reloadData];
    int row = [patterns indexOfObject:pattern];
    if (row != NSNotFound) {
        [_rdPatternList selectRow:row byExtendingSelection:NO];
        [_rdPatternList editColumn:1 row:row withEvent:nil select:YES];
    }
    [patterns release];
}

- (IBAction) removePattern:(id) sender
{
    [[_rdSpawnList window] makeFirstResponder:[_rdSpawnList window]];

    WorldSpawnRecord *current = [self currentSelectedSpawn];

    NSMutableArray *patterns = [[current patterns] mutableCopy];
    int position = [_rdPatternList selectedRow];
    
    if (position < 0)
        return;
    if (position >= [patterns count])
        return;
        
    [patterns removeObjectAtIndex:position];
    [current setPatterns:[NSArray arrayWithArray:patterns]];
    [_rdPatternList reloadData];
    [patterns release];
}

- (IBAction) addException:(id) sender
{
    [[_rdSpawnList window] makeFirstResponder:[_rdSpawnList window]];

    WorldSpawnRecord *current = [self currentSelectedSpawn];
    RDStringPattern *pattern = [RDStringPattern patternWithString:@"" type:RDPatternBeginsWith];
    
    NSMutableArray *patterns = [[current exceptions] mutableCopy];
    [patterns addObject:pattern];
    [current setExceptions:[NSArray arrayWithArray:patterns]];
    [_rdExceptionList reloadData];
    int row = [patterns indexOfObject:pattern];
    if (row != NSNotFound) {
        [_rdExceptionList selectRow:row byExtendingSelection:NO];
        [_rdExceptionList editColumn:1 row:row withEvent:nil select:YES];
    }
    [patterns release];
}

- (IBAction) removeException:(id) sender
{
    [[_rdSpawnList window] makeFirstResponder:[_rdSpawnList window]];

    WorldSpawnRecord *current = [self currentSelectedSpawn];
    
    NSMutableArray *patterns = [[current exceptions] mutableCopy];
    int position = [_rdExceptionList selectedRow];
    
    if (position < 0)
        return;
    if (position >= [patterns count])
        return;
        
    [patterns removeObjectAtIndex:position];
    [current setExceptions:[NSArray arrayWithArray:patterns]];
    [_rdExceptionList reloadData];
    [patterns release];
}



@end
