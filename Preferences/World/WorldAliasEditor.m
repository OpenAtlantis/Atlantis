//
//  WorldAliasEditor.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldAliasEditor.h"
#import "EventEditor.h"
#import "EventCollection.h"
#import "AliasEvent.h"
#import "ActionPicker.h"
#import "BaseAction.h"
#import "ActionClasses.h"
#import "RDAtlantisMainController.h"

@implementation WorldAliasEditor

+ (BOOL) globalTab
{
    return YES;
}

- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *)character
{
    self = [super initWithWorld:prefs forCharacter:character];
    if (self) {
        _rdEventEditor = [[EventEditor alloc] init];
        [_rdEventEditor setDelegate:self];
        _rdAliases = nil;
        EventCollection *events = [prefs preferenceForKey:@"atlantis.aliases" withCharacter:character fallback:NO];
        if (events) 
            _rdAliases = [events retain];
        else
            _rdAliases = [[EventCollection alloc] init];
        
        [_rdEventEditor setDataRepresentation:_rdAliases];
        [_rdEventEditor setNameColumnTitle:@"Alias"];
        [_rdEventEditor setForEventType:[[AliasEvent alloc] init]];
    }
    return self;
}

- (void) dealloc
{
    [_rdAliases release];
    [_rdEventEditor release];
    [super dealloc];
}

- (NSString *) configTabName
{
    return @"Aliases";
}

- (NSView *) configTabView
{
    return [_rdEventEditor editorView];
}

- (void) worldWasUpdated:(NSNotification *)notification
{
    if ([self shouldUpdateForNotification:notification]) {
        EventCollection *collection = [[self preferences] preferenceForKey:@"atlantis.aliases" withCharacter:[self character] fallback:NO];
        if (collection && (collection != _rdAliases)) {
            [_rdEventEditor setDataRepresentation:_rdAliases];
            [_rdAliases release];
            _rdAliases = [collection retain];
        }
    }
}

#pragma mark Event Editor Delegate

- (void) newActionPicked:(BaseAction *)action context:(void *) context
{
    id <EventDataProtocol> event = (id <EventDataProtocol>)context;
    
    if (event) {
        [event eventAddAction:action];
    }
    [_rdEventEditor updateDataRepresentation];
    [_rdEventEditor tableViewSelectionDidChange:nil];
    [self noteUpdate];
}

- (NSArray *) conditions
{
    return [NSArray array];
}

- (NSArray *) actions
{
    return [[[RDAtlantisMainController controller] eventActions] actionsForType:AtlantisTypeAlias];
}


- (void) addEventAction:(id <EventDataProtocol>)event
{
    ActionPicker *picker = [ActionPicker sharedPanel];

    NSArray *actions = [[[RDAtlantisMainController controller] eventActions] actionsForType:AtlantisTypeAlias];
    
    [picker runSheetModalForWindow:[[_rdEventEditor editorView] window] actions:actions target:self contect:event];
}

- (void) addEventCondition:(id <EventDataProtocol>)event
{

}

- (void) addEvent
{
    [[[_rdEventEditor editorView] window] makeFirstResponder:[[_rdEventEditor editorView] window]];

    AliasEvent *newEvent = [[AliasEvent alloc] init];
 
    [_rdAliases addEvent:newEvent];
    [_rdEventEditor updateDataRepresentation];
    [_rdEventEditor selectEvent:newEvent];
    [self noteUpdate];
}

- (void) finalCommit
{
    if (_rdAliases && [[_rdAliases events] count])
        [[self preferences] setPreference:_rdAliases forKey:@"atlantis.aliases" withCharacter:[self character]];
    else
        [[self preferences] removePreferenceForKey:@"atlantis.aliases" withCharacter:[self character]];
}



@end
