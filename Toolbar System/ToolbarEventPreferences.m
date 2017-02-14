//
//  ToolbarEventPreferences.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ToolbarEventPreferences.h"
#import "ToolbarCollection.h"
#import "EventEditor.h"
#import "ToolbarUserEvent.h"
#import "RDAtlantisMainController.h"
#import "BaseAction.h"
#import "BaseCondition.h"
#import "ActionPicker.h"
#import "ConditionPicker.h"
#import "ActionClasses.h"
#import "ConditionClasses.h"

static NSImage *s_rdToolbarIcon = nil;


@implementation ToolbarEventPreferences

- (id) initForEvents:(ToolbarCollection *) collection
{
    self = [super init];
    if (self) {
        _rdEventEditor = [[EventEditor alloc] init];

        NSImageCell *imageCell = [NSImageCell new];
        
        [_rdEventEditor setNameColumnTitle:@"Label"];
        [_rdEventEditor setDescriptionColumnTitle:@"Palette Label"];
        [_rdEventEditor addExtraDataColumn:@"eventIcon" withTitle:@"Icon" andCell:imageCell atIndex:1];
        [_rdEventEditor setExtraDataColumn:@"eventIcon" isEditable:NO];
        
        _rdToolbarCollection = [collection retain];
        [[_rdEventEditor editorView] setFrame:NSMakeRect(0,0,800,500)];
        [_rdEventEditor setDataRepresentation:_rdToolbarCollection];
        [_rdEventEditor setDelegate:self];        
        [_rdEventEditor setForEventType:[[ToolbarUserEvent alloc] init]];
    }
    return self;
}

- (void) dealloc
{
    [_rdEventEditor release];
    [_rdToolbarCollection release];
    [super dealloc];
}

- (void)preferencePaneCommit
{
    [[RDAtlantisMainController controller] saveToolbarEvents];
}

- (NSString *) preferencePaneName
{
    return @"Toolbar Events";
}

- (NSImage *) preferencePaneImage
{
    if (!s_rdToolbarIcon)
        s_rdToolbarIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"toolbar"]];
    
    return s_rdToolbarIcon;
}

- (NSView *) preferencePaneView
{
    return [_rdEventEditor editorView];
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
}

- (void) newConditionPicked:(BaseCondition *)condition context:(void *)context
{
    id <EventDataProtocol> event = (id <EventDataProtocol>)context;
    
    if (event) {
        [event eventAddCondition:condition];
    }
    [_rdEventEditor updateDataRepresentation];
    [_rdEventEditor tableViewSelectionDidChange:nil];
}

- (NSArray *) conditions
{
    return [[[RDAtlantisMainController controller] eventConditions] conditionsForType:AtlantisTypeUI];
}

- (NSArray *) actions
{
    return [[[RDAtlantisMainController controller] eventActions] actionsForType:AtlantisTypeUI];
}

- (void) addEventAction:(id <EventDataProtocol>)event
{
    ActionPicker *picker = [ActionPicker sharedPanel];

    NSArray *actions = [[[RDAtlantisMainController controller] eventActions] actionsForType:AtlantisTypeUI];
    
    [picker runSheetModalForWindow:[[_rdEventEditor editorView] window] actions:actions target:self contect:event];
}

- (void) addEventCondition:(id <EventDataProtocol>)event
{
    // Do nothing, this is empty
}

- (void) addEvent
{
    [[[_rdEventEditor editorView] window] makeFirstResponder:[[_rdEventEditor editorView] window]];

    ToolbarUserEvent *newEvent = [[ToolbarUserEvent alloc] init];
    [newEvent eventSetConditionsAnded:YES];
 
    [_rdToolbarCollection addEvent:newEvent];
    [_rdEventEditor updateDataRepresentation];
    [_rdEventEditor selectEvent:newEvent];
}



@end
