//
//  AddressBook.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "AddressBook.h"
#import "WorldCollection.h"
#import "RDAtlantisWorldPreferences.h"
#import "RDAtlantisMainController.h"
#import "WorldConfigurationEditor.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisApplication.h"
#import "NSDictionary+XMLPersistence.h"

#import <Lemuria/Lemuria.h>

AddressBook *s_addyBook = nil;

@interface AddressBookRecord : NSObject {

    RDAtlantisWorldPreferences      *_rdRealRecord;
    NSString    *_rdCharacter;

    NSMutableArray     *_rdSubitems;
    
}

- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *) character;
- (RDAtlantisWorldPreferences *) world;
- (NSString *) character;
- (BOOL) isCharacter;
- (NSString *) displayName;

- (void) setName:(NSString *) string;

- (NSString *) uuid;
- (NSArray *) subitems;
- (void) addCharacter:(NSString *) character;
- (void) removeCharacter:(NSString *) uuid;
- (AddressBookRecord *) characterWithName:(NSString *)name;

@end

@implementation AddressBookRecord

- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *) character
{
    self = [super init];
    if (self) {
        _rdRealRecord = [prefs retain];
        if (character) {
            _rdCharacter = [character copy];
        }
        else {
            _rdCharacter = nil;
        }
        
        if (!_rdCharacter) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            
            NSEnumerator *charEnum = [[prefs characters] objectEnumerator];
            NSString *charWalk;
            while (charWalk = [charEnum nextObject]) {
                AddressBookRecord *tempRecord = [[AddressBookRecord alloc] initWithWorld:prefs forCharacter:charWalk];
                [tempArray addObject:tempRecord];
            }
            
            _rdSubitems = tempArray;
        }
        else
            _rdSubitems = nil;
    }
    return self;
}

- (void) dealloc
{
    [_rdSubitems release];
    [_rdCharacter release];
    [_rdRealRecord release];
    [super dealloc];
}

- (RDAtlantisWorldPreferences *) world
{
    return _rdRealRecord;
}

- (NSString *) character
{
    return _rdCharacter;
}

- (void) setCharacter:(NSString *) newChar
{
    [newChar retain];
    [_rdCharacter release];
    _rdCharacter = newChar;
}

- (BOOL) isCharacter
{
    return (_rdCharacter != nil);
}

- (NSString *) uuid
{
    return [[self world] uuidForCharacter:[self character]];
}

- (NSString *) displayName
{
    if ([self isCharacter])
        return [self character];
    else
        return [[self world] preferenceForKey:@"atlantis.world.name" withCharacter:nil];
}

- (void) setName:(NSString *) name
{
    if (![name isEqualToString:[self displayName]]) {
        if ([self isCharacter]) {
            NSString *oldName = _rdCharacter;
            _rdCharacter = [name retain];
            [[self world] renameCharacter:oldName to:name];
            [oldName release];
        }
        else {
            [[self world] setPreference:name forKey:@"atlantis.world.name" withCharacter:nil];
        }
    }
}

- (NSArray *) subitems
{
    return _rdSubitems;
}

- (AddressBookRecord *) characterWithName:(NSString *) name
{
    AddressBookRecord *result = nil;
    AddressBookRecord *walk;
    
    NSEnumerator *subEnum = [[self subitems] objectEnumerator];
    
    while (!result && (walk = [subEnum nextObject])) {
        if ([[walk character] isEqualToString:name]) {
            result = walk;
        }
    }
    
    return result;
}

- (NSComparisonResult) compare:(id) other
{
    NSString *myString = [self displayName];
    NSString *otherString = [other displayName];
    
    if (!myString)
        return NSOrderedDescending;

    if (!otherString)
        return NSOrderedAscending;
    
    if (([myString characterAtIndex:0] == '<') && ([otherString characterAtIndex:0] != '<')) {
        return NSOrderedDescending;
    }
    else if (([otherString characterAtIndex:0] == '<')  && ([myString characterAtIndex:0] != '<')) {
        return NSOrderedAscending;
    }
    else
        return [myString compare:otherString];
}

- (void) sortSub
{
    if (!_rdCharacter) {
        [_rdSubitems sortUsingSelector:@selector(compare:)];
    }
}

- (void) addCharacter:(NSString *) character
{
    if (_rdCharacter)
        return;
        
    AddressBookRecord *tempRecord = [[AddressBookRecord alloc] initWithWorld:[self world] forCharacter:character];
    [_rdSubitems addObject:tempRecord];
    [self sortSub];
}

- (void) removeCharacter:(NSString *) uuid
{
    if (_rdCharacter)
        return;
        
    NSEnumerator *subEnum = [_rdSubitems objectEnumerator];
    AddressBookRecord *walk;
    
    while (walk = [subEnum nextObject]) {
        if ([[walk uuid] isEqualToString:uuid])
            [_rdSubitems removeObject:walk];
    }
}

@end

@interface AddressBook (Private)
- (void) worldChanged:(NSNotification *)notification;
- (void) characterChanged:(NSNotification *)notification;
- (void) commitWorld:(NSNotification *) notification;
- (void) connectWorldFromRecord:(AddressBookRecord *)record;
- (AddressBookRecord *) currentSelection;
- (void) loadExpands;
- (void) saveExpands;
- (void) connectionStatesChanged:(NSNotification *) notification;
- (void)setResizingMask:(unsigned)resizingMask;
@end



@implementation AddressBook

- (id) init
{
    self = [super init];
    if (self) {
        [NSBundle loadNibNamed:@"AddressBook" owner:self];
        _rdWorldPreferenceViews = [[NSMutableDictionary alloc] init];
    
        _rdWorldRecords = [[NSMutableArray alloc] init];

        NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForImageResource:@"greenlight"];
        _rdGreenLightImage = [[NSImage alloc] initByReferencingFile:imagePath];
        
        imagePath = [[NSBundle bundleForClass:[self class]] pathForImageResource:@"whitelight"];
        _rdWhiteLightImage = [[NSImage alloc] initByReferencingFile:imagePath];

//        if ([RDAtlantisApplication isTiger])
            [[[[_rdWorldList tableColumns] objectAtIndex:0] dataCell] setLineBreakMode:NSLineBreakByTruncatingTail];

        NSTableColumn *imageCol = [[NSTableColumn alloc] initWithIdentifier:@"worldConnected"];
        [imageCol setWidth:16.0f];
        [imageCol setDataCell:[[NSImageCell alloc] init]];
//        if ([RDAtlantisApplication isTiger])
            [(id)imageCol setResizingMask:0];
//        else
//            [imageCol setResizable:NO];
        [_rdWorldList addTableColumn:imageCol];
        int newColIndex = [[_rdWorldList tableColumns] indexOfObject:imageCol];
        if (newColIndex != NSNotFound)
            [_rdWorldList moveColumn:newColIndex toColumn:0];

        [_rdWorldList setDelegate:self];
        [_rdWorldList setDataSource:self];
        [[_rdWorldList window] setDelegate:self];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(worldChanged:) name:@"RDAtlantisWorldDidUpdateNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(characterChanged:) name:@"RDAtlantisCharacterRenamedNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commitWorld:) name:NSWindowDidResignMainNotification object:[_rdWorldList window]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStatesChanged:) name:@"RDAtlantisConnectionDidConnectNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStatesChanged:) name:@"RDAtlantisConnectionDidDisconnectNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowLostFocus:) name:NSWindowDidResignKeyNotification object:[self window]];
            
        s_addyBook = self;
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    s_addyBook = nil;
    [_rdGreenLightImage release];
    [_rdWhiteLightImage release];
    [_rdWorldPreferenceViews release];
    [_rdWorldRecords release];
    [_rdWorlds release];
    [super dealloc];
}


- (AddressBookRecord *) recordForWorld:(RDAtlantisWorldPreferences *)world
{
    AddressBookRecord *result = nil;
    
    NSEnumerator *worldEnum = [_rdWorldRecords objectEnumerator];
    AddressBookRecord *walk;
    
    while (!result && (walk = [worldEnum nextObject])) {
        if ([walk world] == world) {
            result = walk;
        }
    }
    
    return result;
}

- (void) addEditorForWorldRecord:(AddressBookRecord *)record
{
    WorldConfigurationEditor *editor;
    
    editor = [[WorldConfigurationEditor alloc] initWithWorld:[record world] forCharacter:[record character]];
    [_rdWorldPreferenceViews setObject:editor forKey:[record uuid]];
    
    NSTabViewItem *item;
    int index;
    
    index = [_rdConfigContent indexOfTabViewItemWithIdentifier:[record uuid]];
    if (index >= 0) {
        item = [_rdConfigContent tabViewItemAtIndex:index];
        [item setView:[editor configView]];
    }
    else {
        item = [[NSTabViewItem alloc] initWithIdentifier:[record uuid]];
        [item setView:[editor configView]];
        [_rdConfigContent addTabViewItem:item];
    }
}

- (void) resynchAll
{
    NSEnumerator *addyEnum = [_rdWorldRecords objectEnumerator];
    AddressBookRecord *walk;
    
    while (walk = [addyEnum nextObject]) {
        NSString *uuid = [walk uuid];
        WorldConfigurationEditor *editor;

        editor = [_rdWorldPreferenceViews objectForKey:uuid];
        if (!editor) {
            [self addEditorForWorldRecord:walk];
        }
        
        NSEnumerator *charEnum = [[walk subitems] objectEnumerator];
        AddressBookRecord *charWalk;
        
        while (charWalk = [charEnum nextObject]) {
            editor = [_rdWorldPreferenceViews objectForKey:[charWalk uuid]];
            if (!editor) {
                [self addEditorForWorldRecord:charWalk];
            }
        }
    }
}

- (void) reloadKeepingSelection
{
    AddressBookRecord *current = [self currentSelection];
    [self saveExpands];
    [_rdWorldList reloadData];
    if (current) {
        int row = [_rdWorldList rowForItem:current];
        if (row != -1)
            [_rdWorldList selectRow:row byExtendingSelection:NO];
    }
}

- (void) connectionStatesChanged:(NSNotification *) notification
{
    RDAtlantisWorldInstance *worldInstance = [notification object];
    RDAtlantisWorldPreferences *worldPreferences = [worldInstance preferences];
    AddressBookRecord *record = [self recordForWorld:worldPreferences];
    if (record) {
        [_rdWorldList reloadItem:record reloadChildren:YES];
    }
}

- (void) worldChanged:(NSNotification *) notification
{
    [_rdWorldRecords sortUsingSelector:@selector(compare:)];
    [self reloadKeepingSelection];
}

- (void) characterChanged:(NSNotification *) notification
{
    NSString *oldCharacter = [[notification userInfo] objectForKey:@"RDAtlantisCharacterOld"];
    NSString *newCharacter = [[notification userInfo] objectForKey:@"RDAtlantisCharacterNew"];

    AddressBookRecord *record = [self recordForWorld:[notification object]];
    if (record) {
        AddressBookRecord *realChar = [record characterWithName:oldCharacter];
        if (realChar)
            [realChar setCharacter:newCharacter];
        [record sortSub];
    }
    [self reloadKeepingSelection];
}

- (void) refreshWorldCollection
{
    NSEnumerator *worldEnum = [[_rdWorlds worlds] objectEnumerator];
    RDAtlantisWorldPreferences *prefs;
    NSTabViewItem *item;
    
    while (prefs = [worldEnum nextObject]) {
        if (![self recordForWorld:prefs]) {
            WorldConfigurationEditor *editor = [[WorldConfigurationEditor alloc] initWithWorld:prefs forCharacter:nil];
            
            [_rdWorldPreferenceViews setObject:editor forKey:[prefs uuid]];
            item = [[NSTabViewItem alloc] initWithIdentifier:[prefs uuid]];
            [item setView:[editor configView]];
            [_rdConfigContent addTabViewItem:item];
            [editor release];
            
            NSEnumerator *charEnumerator = [[prefs characters] objectEnumerator];
            NSString *charWalk;
            while (charWalk = [charEnumerator nextObject]) {
                NSString *tempUUID = [prefs uuidForCharacter:charWalk];
                editor = [[WorldConfigurationEditor alloc] initWithWorld:prefs forCharacter:charWalk];
                
                [_rdWorldPreferenceViews setObject:editor forKey:tempUUID];
                item = [[NSTabViewItem alloc] initWithIdentifier:tempUUID];
                [item setView:[editor configView]];
                [_rdConfigContent addTabViewItem:item];
                [editor release];
            }
            
            AddressBookRecord *record = [[AddressBookRecord alloc] initWithWorld:prefs forCharacter:nil];
            [_rdWorldRecords addObject:record];
            [record release];
        }
    }
    [_rdWorldRecords sortUsingSelector:@selector(compare:)];
    [_rdWorldList reloadData];
}

- (void) setWorldCollection:(WorldCollection *)collection
{
    [_rdWorlds release];
    _rdWorlds = [collection retain];
    [_rdWorldRecords removeAllObjects];
    
    [_rdWorldPreferenceViews removeAllObjects];
    NSEnumerator *tabEnum = [[_rdConfigContent tabViewItems] objectEnumerator];
    NSTabViewItem *item;
    while (item = [tabEnum nextObject]) {
        [_rdConfigContent removeTabViewItem:item];
    }
    
    NSEnumerator *worldEnum = [[collection worlds] objectEnumerator];
    RDAtlantisWorldPreferences *prefs;
    
    while (prefs = [worldEnum nextObject]) {
        WorldConfigurationEditor *editor = [[WorldConfigurationEditor alloc] initWithWorld:prefs forCharacter:nil];
        
        [_rdWorldPreferenceViews setObject:editor forKey:[prefs uuid]];
        item = [[NSTabViewItem alloc] initWithIdentifier:[prefs uuid]];
        [item setView:[editor configView]];
        [_rdConfigContent addTabViewItem:item];
        [editor release];

        NSEnumerator *charEnumerator = [[prefs characters] objectEnumerator];
        NSString *charWalk;
        while (charWalk = [charEnumerator nextObject]) {
            NSString *tempUUID = [prefs uuidForCharacter:charWalk];
            editor = [[WorldConfigurationEditor alloc] initWithWorld:prefs forCharacter:charWalk];

            [_rdWorldPreferenceViews setObject:editor forKey:tempUUID];
            item = [[NSTabViewItem alloc] initWithIdentifier:tempUUID];
            [item setView:[editor configView]];
            [_rdConfigContent addTabViewItem:item];
            [editor release];
        }
        
        AddressBookRecord *record = [[AddressBookRecord alloc] initWithWorld:prefs forCharacter:nil];
        [_rdWorldRecords addObject:record];
        [record release];
    }
    [_rdWorldRecords sortUsingSelector:@selector(compare:)];
    [_rdWorldList reloadData];
    [self loadExpands];
}

- (void) display
{
    [[self window] makeKeyAndOrderFront:self];
}

#pragma mark Remember Stuff

- (void) saveExpands
{
    if (_rdExpanding)
        return;
        
    int loop;
    
    for (loop = 0; loop < [_rdWorldList numberOfRows]; loop++) {
        if ([_rdWorldList levelForRow:loop] == 0) {
            id value = [_rdWorldList itemAtRow:loop];
            [[NSUserDefaults standardUserDefaults] setBool:[_rdWorldList isItemExpanded:value] forKey:[NSString stringWithFormat:@"addressbook.expands:%@", [value uuid]]];
        }
    }
}

- (void) loadExpands
{
    _rdExpanding = YES;

    int loop;
    for (loop = 0; loop < [_rdWorldList numberOfRows]; loop++) {
        if ([_rdWorldList levelForRow:loop] == 0) {
            id value = [_rdWorldList itemAtRow:loop];
            BOOL expand = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"addressbook.expands:%@", [value uuid]]];
            if (expand) {
                [_rdWorldList expandItem:value];
            }
        }
    }    
    
    _rdExpanding = NO;
}


#pragma mark Stupid Font Goo

- (void) changeFont:(id) sender
{
    NSView *realContentView;
    
    realContentView = [[[[_rdConfigContent selectedTabViewItem] view] selectedTabViewItem] view];
    
    if ([realContentView respondsToSelector:@selector(changeFont:)])
        [realContentView changeFont:sender];
}

#pragma mark Windowing Goo

- (void)windowWillClose:(NSNotification *)aNotification
{
    [[aNotification object] makeFirstResponder:[aNotification object]];

    NSEnumerator *worlds = [_rdWorldRecords objectEnumerator];
    AddressBookRecord *walk;
    
    while (walk = [worlds nextObject]) {
        WorldConfigurationEditor *editor;
        
        editor = [_rdWorldPreferenceViews objectForKey:[walk uuid]];
        if (editor)
            [editor commitAll];
    }

    [self saveExpands];
    [[RDAtlantisMainController controller] saveDirtyWorlds];
}

- (void)windowLostFocus:(NSNotification *)aNotification
{
    [[aNotification object] makeFirstResponder:[aNotification object]];

    NSEnumerator *worlds = [_rdWorldRecords objectEnumerator];
    AddressBookRecord *walk;
    
    while (walk = [worlds nextObject]) {
        WorldConfigurationEditor *editor;
        
        editor = [_rdWorldPreferenceViews objectForKey:[walk uuid]];
        if (editor)
            [editor commitAll];
    }

    [self saveExpands];
    [[RDAtlantisMainController controller] saveDirtyWorlds];
}

- (void)commitWorld:(NSNotification *)aNotification
{
    AddressBookRecord *current = [self currentSelection];

    if (current) {
        WorldConfigurationEditor *editor;
        
        editor = [_rdWorldPreferenceViews objectForKey:[current uuid]];
        if (editor)
            [editor commitAll];        
    }
}

#pragma mark Outline View Datasource

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    AddressBookRecord *record = (AddressBookRecord *)item;
    
    if (!record)
        return [_rdWorldRecords count];
    
    if ([record subitems]) {
        return [[record subitems] count];
    }
    
    return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    AddressBookRecord *record = (AddressBookRecord *)item;
    
    if (record) {
        if (![record isCharacter] && [[record subitems] count])
            return YES;
    }
    
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
    AddressBookRecord *record = (AddressBookRecord *)item;
    
    NSArray *tempArray;
    
    if (record) {
        tempArray = [record subitems];
    }
    else
        tempArray = _rdWorldRecords;
        
    if ((index < 0) || (index >= [tempArray count]))
        return nil;
    
    return [tempArray objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if ([[tableColumn identifier] isEqualToString:@"worldName"]) {
        return [(AddressBookRecord *)item displayName];
    }
    else if ([[tableColumn identifier] isEqualToString:@"worldConnected"]) {
        AddressBookRecord *record = (AddressBookRecord *)item;
        NSString *basePath = [[record world] basePathForCharacter:[record character]];
        
        RDAtlantisWorldInstance *instance = [[RDAtlantisMainController controller] connectedWorld:basePath];
        
        if (instance && [instance isConnected]) {
            return _rdGreenLightImage;
        }
        else {
            return _rdWhiteLightImage;
        }
    }
    
    return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if ([[tableColumn identifier] isEqualToString:@"worldName"]) {    
        AddressBookRecord *record = (AddressBookRecord *)item;
    
        if (record && (object && [object length])) {    
            [record setName:object];
        }
    }
}


#pragma mark Outline View Delegate

- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
    [self saveExpands];
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
    [self saveExpands];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id) new
{
    int selected = [_rdWorldList selectedRow];
    if (selected != -1) {
        AddressBookRecord *record = [_rdWorldList itemAtRow:selected];
        
        if (record) {
            WorldConfigurationEditor *editor;
            
            editor = [_rdWorldPreferenceViews objectForKey:[record uuid]];
            if (editor)
                [editor commitAll];
        }
    }
    return YES;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    int selected = [_rdWorldList selectedRow];
    if (selected == -1) {
        [_rdRemoveWorldButton setEnabled:NO];
        [_rdAddCharacterButton setEnabled:NO];
        [_rdRemoveCharacterButton setEnabled:NO];
        [_rdConnectButton setEnabled:NO];
        [_rdShortcutButton setEnabled:NO];
    }
    else {
        AddressBookRecord *record = [_rdWorldList itemAtRow:selected];
        
        if (record) {
            NSString *uuid = [record uuid];

            NSView *configView = [[_rdConfigContent selectedTabViewItem] view];
            int selectedTab = 0;
            if ([configView isKindOfClass:[NSTabView class]]) {
                NSTabView *tabTemp = (NSTabView *)configView;
                selectedTab = [tabTemp indexOfTabViewItem:[tabTemp selectedTabViewItem]];
            }

            
            [_rdConfigContent selectTabViewItemWithIdentifier:uuid];
            
            configView = [[_rdConfigContent selectedTabViewItem] view];
            if ([configView isKindOfClass:[NSTabView class]]) {
                [(NSTabView *)configView selectTabViewItemAtIndex:selectedTab];
            }
                        
            if ([record isCharacter]) {
                [_rdRemoveWorldButton setEnabled:NO];
                [_rdConnectButton setEnabled:YES];
                [_rdAddCharacterButton setEnabled:NO];
                [_rdRemoveCharacterButton setEnabled:YES];
                [_rdShortcutButton setEnabled:YES];
            }
            else {
                [_rdRemoveWorldButton setEnabled:YES];
                [_rdConnectButton setEnabled:YES];
                [_rdRemoveCharacterButton setEnabled:NO];            
                [_rdAddCharacterButton setEnabled:YES];
                [_rdShortcutButton setEnabled:YES];
            }
        }
    }
}

- (BOOL) outlineView:(NSOutlineView *)outlineView clickedItem:(id) item inColumn:(NSTableColumn *)tableColumn
{
    if ([[tableColumn identifier] isEqualTo:@"worldConnected"]) {
        AddressBookRecord *record = (AddressBookRecord *)item;
        NSString *basePath = [[record world] basePathForCharacter:[record character]];
        
        if (![[RDAtlantisMainController controller] connectedWorld:basePath]) {
            [self performSelector:@selector(connectWorldFromRecord:) withObject:record afterDelay:0.1f];
        }
    }

    return NO;
}


#pragma mark Actions

- (AddressBookRecord *) currentSelection
{
    int selected = [_rdWorldList selectedRow];
    if (selected != -1) {
        AddressBookRecord *record = [_rdWorldList itemAtRow:selected];
        return record;
    }
    
    return nil;
}

- (AddressBookRecord *) worldByName:(NSString *) name
{
    AddressBookRecord *result = nil;
    
    AddressBookRecord *walk;
    NSEnumerator *addrEnum = [_rdWorldRecords objectEnumerator];
    while (!result && (walk = [addrEnum nextObject])) {
        if ([[walk displayName] isEqualToString:name])
            result = walk;
    }
    
    return result;
}

- (void) askQuestion:(NSString *) question info:(NSString *) info action:(SEL)selector context:(void *) context
{
    NSAlert *alert =
        [NSAlert alertWithMessageText:question defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:info];

    NSArray *buttons = [alert buttons];
    NSButton *noButton = [buttons objectAtIndex:1];
    [noButton setKeyEquivalent:@"\e"];
    
    [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:selector contextInfo:context];
}

- (void)handleConnectResult:(NSAlert *)alert returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
    AddressBookRecord *current = (AddressBookRecord *) contextInfo;
    
    if (returnCode == NSAlertDefaultReturn) {
    
        NSString *basePath = [[current world] basePathForCharacter:[current character]];
        NSString *result;
        
        BOOL done = NO;
        int counter = 2;
        
        while (!done) {
            result = [NSString stringWithFormat:@"%@ (%d)", basePath, counter];
            if ([[RDAtlantisMainController controller] connectedWorld:result]) {
                counter++;
            }
            else {
                done = YES;
            }
        }
        
        RDAtlantisWorldInstance *instance;
        
        instance = [[RDAtlantisWorldInstance alloc] initWithWorld:[current world] forCharacter:[current character] withBasePath:result];
        [instance connectAndFocus];
    } 
}

- (void) connectWorldFromRecord:(AddressBookRecord *) current
{
    NSString *basePath = [[current world] basePathForCharacter:[current character]];
    NSString *uuid = [current uuid];
    
    WorldConfigurationEditor *editor = [_rdWorldPreferenceViews objectForKey:uuid];
    if (editor) {
        [editor commitAll];
    }

    if (basePath) {
        RDAtlantisWorldInstance *instance;
        
        instance = [[RDAtlantisMainController controller] connectedWorld:basePath];
        if (instance) {
            if ([instance isConnected]) {
                [self askQuestion:@"Connect Another Copy?" info:@"This world is already connected at least once.  Do you really want to create a second connection?" action:@selector(handleConnectResult:returnCode:contextInfo:) context:current];
            }
            else {
                [instance connectAndFocus];
            }
        }
        else {
            instance = [[RDAtlantisWorldInstance alloc] initWithWorld:[current world] forCharacter:[current character] withBasePath:basePath];
            [instance connectAndFocus];
        }
    }
}

- (IBAction) connectWorld:(id) sender
{
    AddressBookRecord *current = [self currentSelection];

    [self connectWorldFromRecord:current];
}

- (void) createShortcutFromRecord:(AddressBookRecord *) current
{
    NSString *uuid = [[current world] uuid];
    
    NSMutableDictionary *shortcutValues = [[NSMutableDictionary alloc] init];
    [shortcutValues setObject:uuid forKey:@"world"];
    
    if ([current character]) {
        NSString *charuuid = [[current world] uuidForCharacter:[current character]];
        [shortcutValues setObject:charuuid forKey:@"character"];
    }

    NSMutableDictionary *shortcutFile = [[NSMutableDictionary alloc] init];
    [shortcutFile setObject:shortcutValues forKey:@"shortcut"];
    
    NSString *filename;
    if ([current character])
        filename = [NSString stringWithFormat:@"~/Desktop/%@@%@.atlantis", [current character], [[current world] preferenceForKey:@"atlantis.world.name" withCharacter:nil fallback:NO]];
    else
        filename = [NSString stringWithFormat:@"~/Desktop/%@.atlantis", [[current world] preferenceForKey:@"atlantis.world.name" withCharacter:nil fallback:NO]];
    filename = [filename stringByExpandingTildeInPath];
    
    [shortcutFile writeToXMLFile:filename atomically:YES];
    [shortcutValues release];
    [shortcutFile release];    
    
}

- (IBAction) createShortcut:(id) sender
{
    AddressBookRecord *current = [self currentSelection];
    
    [self createShortcutFromRecord:current];
}


- (IBAction) addWorld:(id) sender
{
    RDAtlantisWorldPreferences *newWorld;

    int counter = 1;
    NSString *worldName = @"<world01>";
    AddressBookRecord *world = [self worldByName:worldName];
    
    while (world) {
        counter++;
        worldName = [NSString stringWithFormat:@"<world%02d>", counter];
        world = [self worldByName:worldName];
     }
    
    newWorld = [[RDAtlantisWorldPreferences alloc] init];
    [newWorld setPreference:worldName forKey:@"atlantis.world.name" withCharacter:nil];
    [_rdWorlds addWorld:newWorld];
    
    AddressBookRecord *newRecord;
    
    newRecord = [[AddressBookRecord alloc] initWithWorld:newWorld forCharacter:nil];
    [self addEditorForWorldRecord:newRecord];
    [_rdWorldRecords addObject:newRecord];
    [_rdWorldRecords sortUsingSelector:@selector(compare:)];
    [self resynchAll];
    [self reloadKeepingSelection];
    
    int newWorldRow = [_rdWorldList rowForItem:newRecord];
    if (newWorldRow != -1) {
        [_rdWorldList selectRow:newWorldRow byExtendingSelection:NO];
    }
}

- (void)handleRemoveWorldResult:(NSAlert *)alert returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
    AddressBookRecord *current = (AddressBookRecord *) contextInfo;
    
    if (current && (returnCode == NSAlertDefaultReturn)) {   
        [current retain];
        [_rdWorlds removeWorld:[current world]];
        [_rdWorldRecords removeObject:current];
        [self reloadKeepingSelection];
        [current release];
        [self outlineViewSelectionDidChange:nil];
    }
}

- (IBAction) removeWorld:(id) sender
{
    AddressBookRecord *current = [self currentSelection];

    if (current && ![current isCharacter]) {
        [self askQuestion:@"Remove World?" info:@"Do you really want to remove this world and all its characters?" action:@selector(handleRemoveWorldResult:returnCode:contextInfo:) context:current];        
    }
}

- (IBAction) addCharacter:(id) sender
{
    AddressBookRecord *current = [self currentSelection];

    if (current && ![current isCharacter]) {
        int counter = 1;
        NSString *characterName;
        BOOL done = NO;
        while (!done) {
            characterName = [NSString stringWithFormat:@"<character%02d>", counter];
            if ([[current world] hasCharacter:characterName]) {
                counter++;
            }
            else
                done = YES;
        }
        [[current world] addCharacter:characterName];
        [current addCharacter:characterName];
        [self resynchAll];
        [self reloadKeepingSelection];
        [_rdWorldList expandItem:current];
        AddressBookRecord *newRecord = [current characterWithName:characterName];
        [self addEditorForWorldRecord:newRecord];
        
        if (newRecord) {
            int selected = [_rdWorldList rowForItem:newRecord];
            if (selected != -1) {
                [_rdWorldList selectRow:selected byExtendingSelection:NO];
            }
        }
        
        
    }
}

- (void)handleRemoveCharacterResult:(NSAlert *)alert returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
    AddressBookRecord *current = (AddressBookRecord *) contextInfo;
    
    if (returnCode == NSAlertDefaultReturn) {        
        NSString *character = [current character];
        AddressBookRecord *parent = [self recordForWorld:[current world]];
        [parent removeCharacter:[current uuid]];
        [[parent world] removeCharacter:character];
        [self reloadKeepingSelection];
        [self outlineViewSelectionDidChange:nil];
    }
}

- (IBAction) removeCharacter:(id) sender
{
    AddressBookRecord *current = [self currentSelection];

    if (current && [current isCharacter]) {
        [self askQuestion:@"Remove Character?" info:@"Do you really want to remove this character?" action:@selector(handleRemoveCharacterResult:returnCode:contextInfo:) context:current];        
    }
}

- (void) focusWorld:(RDAtlantisWorldPreferences *)world forCharacter:(NSString *)character
{
    [self resynchAll];

    AddressBookRecord *record = [self recordForWorld:world];
    
    if (character) {
        [_rdWorldList expandItem:record expandChildren:YES];
        record = [record characterWithName:character];
    }
    
    if (record) {
        int row = [_rdWorldList rowForItem:record];
        
        if (row != -1) {
            [_rdWorldList selectRow:row byExtendingSelection:NO];
        }
    }
    [self display];
}


@end
