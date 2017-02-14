//
//  WorldEventEditor.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldEventEditor.h"

#import "WorldEvent.h"
#import "ActionPicker.h"
#import "ConditionPicker.h"
#import "BaseAction.h"
#import "BaseCondition.h"
#import "EventDataProtocol.h"
#import "ActionClasses.h"
#import "ConditionClasses.h"
#import "RDAtlantisMainController.h"

#import "RDAtlantisWorldPreferences.h"

@implementation WorldEventEditor

+ (BOOL) globalTab
{
    return YES;
}

- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *)character
{
    self = [super initWithWorld:prefs forCharacter:character];
    if (self) {
        _rdEvents = nil;
        EventCollection *events = [prefs preferenceForKey:@"atlantis.events" withCharacter:character fallback:NO];
        if (events) 
            _rdEvents = [events retain];
        else
            _rdEvents = [[EventCollection alloc] init];
        
        _rdEventEditor = [[EventEditor alloc] init];
        [_rdEventEditor setDataRepresentation:_rdEvents];
        [_rdEventEditor setDelegate:self];
    }
    return self;
}

- (void) dealloc
{
    [_rdEvents release];
    [_rdEventEditor release];
    [super dealloc];
}

- (NSString *) configTabName
{
    return @"Events";
}

- (NSView *) configTabView
{
    return [_rdEventEditor editorView];
}

- (void) worldWasUpdated:(NSNotification *)notification
{
    if ([self shouldUpdateForNotification:notification]) {
        EventCollection *collection = [[self preferences] preferenceForKey:@"atlantis.events" withCharacter:[self character] fallback:NO];
        if (collection && (collection != _rdEvents)) {
            [_rdEventEditor setDataRepresentation:_rdEvents];
            [_rdEvents release];
            _rdEvents = [collection retain];
        }
    }
}

#pragma mark Event Editor Delegate

- (void) newConditionPicked:(BaseCondition *)condition context:(void *)context
{
    id <EventDataProtocol> event = (id <EventDataProtocol>)context;
    
    if (event) {
        [event eventAddCondition:condition];
    }
    [_rdEventEditor updateDataRepresentation];
    [_rdEventEditor tableViewSelectionDidChange:nil];
    [self noteUpdate];
}

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
    return [[[RDAtlantisMainController controller] eventConditions] conditionsForType:AtlantisTypeEvent];
}

- (NSArray *) actions
{
    return [[[RDAtlantisMainController controller] eventActions] actionsForType:AtlantisTypeEvent];
}

- (void) addEventAction:(id <EventDataProtocol>)event
{
    ActionPicker *picker = [ActionPicker sharedPanel];

    NSArray *actions = [[[RDAtlantisMainController controller] eventActions] actionsForType:AtlantisTypeEvent];
    
    [picker runSheetModalForWindow:[[_rdEventEditor editorView] window] actions:actions target:self contect:event];
}

- (void) popupConditions
{
    ConditionPicker *picker = [ConditionPicker sharedPanel];

    NSArray *conditions = [[[RDAtlantisMainController controller] eventConditions] conditions];
    
    [picker runSheetModalForWindow:[[_rdEventEditor editorView] window] conditions:conditions target:self context:NULL];    
}

- (void) addEventCondition:(id <EventDataProtocol>)event
{
    [self performSelector:@selector(popupConditions) withObject:nil afterDelay:0.5];
}

- (void) addEvent
{
    [[[_rdEventEditor editorView] window] makeFirstResponder:[[_rdEventEditor editorView] window]];

    WorldEvent *newEvent = [[WorldEvent alloc] init];
    [newEvent eventSetConditionsAnded:YES];
 
    [_rdEvents addEvent:newEvent];
    [_rdEventEditor updateDataRepresentation];
    [_rdEventEditor selectEvent:newEvent];
    [self noteUpdate];
}

- (void) finalCommit
{
    if (_rdEvents && [[_rdEvents events] count])
        [[self preferences] setPreference:_rdEvents forKey:@"atlantis.events" withCharacter:[self character]];
    else
        [[self preferences] removePreferenceForKey:@"atlantis.events" withCharacter:[self character]];
}

@end
