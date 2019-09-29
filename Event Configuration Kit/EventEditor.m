//
//  EventEditor.m
//  LemuriaTestbed
//
//  Created by Rachel Blackman on 2/24/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "EventEditor.h"
#import "EventCollection.h"
#import "EventDataProtocol.h"
#import "EventConditionProtocol.h"
#import "EventActionProtocol.h"

#import "BaseAction.h"
#import "BaseCondition.h"

#import "ActionPicker.h"
#import "ConditionPicker.h"

#import "RDAtlantisEventItem.h"

#import <objc/runtime.h>

@interface EventEditorDelegate
- (void) addEvent;
- (NSArray *) actions;
- (NSArray *) conditions;
- (void) newActionPicked:(BaseAction *)action context:(void *)context;
- (void) newConditionPicked:(BaseCondition *)condition context:(void *)context;
@end

@interface EventEditor (TableDelegate)
- (void) eventDoubleClicked:(id) sender;
@end

static NSImage *s_upArrow;
static NSImage *s_downArrow;

@implementation EventEditor

#pragma mark Initialization and Setup

- (id) init
{
    self = [super init];
    if (self) {
        if (![NSBundle loadNibNamed:@"EventEditor" owner:self]) {
            NSLog(@"Editor view could not load its own NIB!");
        }
        
        if (!s_upArrow) {
            s_upArrow = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"uparrow"]];
        }
        if (!s_downArrow) {
            s_downArrow = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"downarrow"]];
        }
        
        _rdNoRedraw = NO;
    }
    return self;
}

- (void) awakeFromNib
{
    // Setup Condition chain view
    [_rdConditionChainView setBackground:[NSColor whiteColor]];
    [_rdConditionChainView setFrame:[[_rdConditionScrollView contentView] bounds]];
    [_rdConditionChainView setDelegate:self];
    [_rdConditionChainView setAutocollapse:YES];

    // Setup Action chain view
    [_rdActionChainView setBackground:[NSColor whiteColor]];
    [_rdActionChainView setFrame:[[_rdActionScrollView contentView] bounds]];
    [_rdActionChainView setDelegate:self];
    [_rdActionChainView setAutocollapse:YES];
    
    // We have no event data
    _rdEventData = nil;

    // We are the data source for the navigation table
    [_rdTableView setDataSource:self];
    [_rdTableView setDoubleAction:@selector(eventDoubleClicked:)];
    [_rdTableView setTarget:self];
    [_rdTableView setDelegate:self];
    
    [_rdRemoveActionButton setEnabled:NO];
    [_rdRemoveConditionButton setEnabled:NO];
    
    int tempIndex = [_rdTabView indexOfTabViewItemWithIdentifier:@"eventConds"];
    _rdCondItem = [[_rdTabView tabViewItemAtIndex:tempIndex] retain];    
}

- (void) dealloc
{
    [_rdCondItem release];
    [_rdDelegate release];
    [_rdEventData release];
    [super dealloc];
}

#pragma mark Data Accessors

- (NSView *) editorView
{
    return _rdEditorContentView;
}

- (void) setDataRepresentation:(EventCollection *) eventData
{
    // Update instance variables
    _rdEventData = eventData;

    id <EventDataProtocol> tempEvent = [_rdEventData eventAtIndex:0];
    
    if (tempEvent) {
        [self setForEventType:tempEvent];
    }

    // Reload data
    [_rdTableView reloadData];
}

- (void) updateDataRepresentation
{
    [_rdTableView reloadData];
}

- (void) setForEventType:(id <EventDataProtocol>) tempEvent
{
    if (tempEvent) {
        NSTableColumn *descColumn = [_rdTableView tableColumnWithIdentifier:@"eventDesc"];
        NSTableColumn *nameColumn = [_rdTableView tableColumnWithIdentifier:@"eventName"];
        
        if (descColumn)
            [descColumn setEditable:[tempEvent eventCanEditDescription]];
        if (nameColumn)
            [nameColumn setEditable:[tempEvent eventCanEditName]];

        int condIndex = [_rdTabView indexOfTabViewItemWithIdentifier:@"eventConds"];
        
        if ((condIndex != NSNotFound) && ![tempEvent eventSupportsConditions]) {
            [_rdTabView removeTabViewItem:_rdCondItem];
            [_rdTabView setTabViewType:NSNoTabsNoBorder];
        }
        else if ((condIndex == NSNotFound) && [tempEvent eventSupportsConditions]) {
            [_rdTabView insertTabViewItem:_rdCondItem atIndex:0];
            [_rdTabView setTabViewType:NSTopTabsBezelBorder];
        }
    }
}

- (void) selectEvent:(id <EventDataProtocol>)event
{
    unsigned position = [_rdEventData indexOfEvent:event];
    
    if (position != NSNotFound) {
        [_rdTableView selectRow:position byExtendingSelection:NO];
    }
}

#pragma mark ChainedListView 

- (void) chainedListViewSelectionDidChange:(RDChainedListView *) chainView
{
    RDChainedListItem *item = [chainView currentActiveItem];
    
    if (chainView == _rdConditionChainView) {
        if (!item) {
            [_rdRemoveConditionButton setEnabled:NO];
        }
        else {
            [_rdRemoveConditionButton setEnabled:YES];        
        }
    }
    else if (chainView == _rdActionChainView) {
        if (!item) {
            [_rdRemoveActionButton setEnabled:NO];
        }
        else {
            [_rdRemoveActionButton setEnabled:YES];        
        }
    }
}

#pragma mark Tableview Data Delegate

- (int) numberOfRowsInTableView:(NSTableView *) aTable
{
    if (aTable == _rdTableView) {
        // Sanity check
        if (_rdEventData) {
            return [_rdEventData eventsCount];
        }
    }
    
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if (_rdEventData && (aTableView == _rdTableView)) {
        if (rowIndex < [_rdEventData eventsCount]) {
            id<EventDataProtocol> event = [_rdEventData eventAtIndex:rowIndex];
            
            if (event) {                
                if ([[aTableColumn identifier] isEqualToString:@"eventName"]) {
                    return [event eventName];
                }
                else if ([[aTableColumn identifier] isEqualToString:@"eventDesc"]) {
                    return [event eventDescription];
                }
                else if ([[aTableColumn identifier] isEqualToString:@"eventActive"]) {
                    return [NSNumber numberWithBool:[event eventIsEnabled]];
                }
                else {
                    return [event eventExtraData:[aTableColumn identifier]];
                }
            }
        }
    }
    
    return @"";
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if (aTableView == _rdTableView) {
        id <EventDataProtocol> event = [_rdEventData eventAtIndex:rowIndex];
        
        if (event) {
            if ([[aTableColumn identifier] isEqualToString:@"eventName"]) {
                if ([event eventCanEditName]) {
                    [event eventSetName:(NSString *)anObject];
                }
            }
            else if ([[aTableColumn identifier] isEqualToString:@"eventDesc"]) {
                if ([event eventCanEditDescription]) {
                    [event eventSetDescription:(NSString *)anObject];
                }
            }
            else if ([[aTableColumn identifier] isEqualToString:@"eventActive"]) {
                [event eventSetEnabled:[(NSNumber *)anObject boolValue]];
            }
            else {
                [event eventSetExtraData:anObject forName:[aTableColumn identifier]];
            }
        }
    }
}

- (void) moveUp:(id) sender
{
    int selected = [_rdTableView selectedRow];
    if (selected >= 0) {
        id <EventDataProtocol> event = [_rdEventData eventAtIndex:selected];
        NSArray *conditions = [event eventConditions];
        NSArray *actions = [event eventActions];        
        
        if ([sender isKindOfClass:[RDAtlantisConditionItem class]]) {
            id <EventConditionProtocol> condition = [(RDAtlantisConditionItem *)sender itemCondition];
            
            int index = [conditions indexOfObject:condition];
            if (index > 0) { 
                [event eventMoveCondition:condition toPosition:(index - 1)];
                [_rdConditionChainView moveItem:sender toPosition:(index - 1)];
            }
        }
        else if ([sender isKindOfClass:[RDAtlantisActionItem class]]) {
            id <EventActionProtocol> action = [(RDAtlantisActionItem *)sender itemAction];
            
            int index = [actions indexOfObject:action];
            if (index > 0) {
                [event eventMoveAction:action toPosition:(index - 1)];
                [_rdActionChainView moveItem:sender toPosition:(index - 1)];
            }
        }
    }
}

- (void) moveDown:(id) sender
{
    int selected = [_rdTableView selectedRow];
    if (selected >= 0) {
        id <EventDataProtocol> event = [_rdEventData eventAtIndex:selected];
        NSArray *conditions = [event eventConditions];
        NSArray *actions = [event eventActions];        
        
        if ([sender isKindOfClass:[RDAtlantisConditionItem class]]) {
            id <EventConditionProtocol> condition = [(RDAtlantisConditionItem *)sender itemCondition];
            
            int index = [conditions indexOfObject:condition];
            if ((index + 1) < [conditions count]) {
                [event eventMoveCondition:condition toPosition:(index + 1)];
                [_rdConditionChainView moveItem:sender toPosition:(index + 1)];
            }
        }
        else if ([sender isKindOfClass:[RDAtlantisActionItem class]]) {
            id <EventActionProtocol> action = [(RDAtlantisActionItem *)sender itemAction];
            
            int index = [actions indexOfObject:action];
            if ((index + 1) < [actions count]) {
                [event eventMoveAction:action toPosition:(index + 1)];
                [_rdActionChainView moveItem:sender toPosition:(index + 1)];
            }
        }
    }

}

- (void)resynchChainedView
{
    int selected = [_rdTableView selectedRow];
    
    [_rdConditionChainView removeAllItems];
    [_rdActionChainView removeAllItems];
    
    if (selected >= 0) {
        id <EventDataProtocol> event = [_rdEventData eventAtIndex:selected];

        int condIndex = [_rdTabView indexOfTabViewItemWithIdentifier:@"eventConds"];
        
        if ((condIndex != NSNotFound) && ![event eventSupportsConditions]) {
            [_rdTabView removeTabViewItem:_rdCondItem];
        }
        else if ((condIndex == NSNotFound) && [event eventSupportsConditions]) {
            [_rdTabView insertTabViewItem:_rdCondItem atIndex:0];
        }
        
        if ([event eventConditionsAnded]) {
            [_rdConditionType selectItemAtIndex:1];
        }
        else {
            [_rdConditionType selectItemAtIndex:0];
        }
        
        [_rdRemoveActionButton setEnabled:NO];
        [_rdRemoveConditionButton setEnabled:NO];
    
        NSArray *conditions = [event eventConditions];
        NSArray *actions = [event eventActions];
        
        if (conditions) {
            NSEnumerator *conditionEnum = [conditions objectEnumerator];
            
            id <EventConditionProtocol> conditionWalk;
            
            while (conditionWalk = [conditionEnum nextObject]) {
                NSView *configurationView = [conditionWalk conditionConfigurationView];
                NSString *conditionName = [conditionWalk conditionName];
                
                RDAtlantisConditionItem *newItem = [[RDAtlantisConditionItem alloc] initWithFrame:NSMakeRect(0,0,300,200)];
                [newItem setTitle:conditionName];
                [newItem setMainContentView:configurationView];
                [newItem setAlternateContentView:configurationView];
                [newItem setShowsAlternate:NO];
                [newItem setActive:NO];
                [newItem setItemCondition:conditionWalk];
                [newItem resynch];
                
                RDChainedListButton *upButton = [[RDChainedListButton alloc] initWithImage:s_upArrow action:@selector(moveUp:) target:self];
                RDChainedListButton *downButton = [[RDChainedListButton alloc] initWithImage:s_downArrow action:@selector(moveDown:) target:self];
                
                [newItem addOptionButton:downButton];
                [newItem addOptionButton:upButton];

                [_rdConditionChainView addItem:newItem];
                
                [upButton release];
                [downButton release];
                
                [newItem autorelease];
            }
        }

        if (actions) {
            NSEnumerator *actionEnum = [actions objectEnumerator];
            
            id <EventActionProtocol> actionWalk;
            
            while (actionWalk = [actionEnum nextObject]) {
                NSView *configurationView = [actionWalk actionConfigurationView];
                NSString *actionName = [actionWalk actionName];
                
                RDAtlantisActionItem *newItem = [[RDAtlantisActionItem alloc] initWithFrame:NSMakeRect(0,0,300,200)];
                [newItem setTitle:actionName];
                [newItem setMainContentView:configurationView];
                [newItem setAlternateContentView:configurationView];
                [newItem setShowsAlternate:NO];
                [newItem setActive:NO];
                [newItem setItemAction:actionWalk];
                [newItem resynch];

                RDChainedListButton *upButton = [[RDChainedListButton alloc] initWithImage:s_upArrow action:@selector(moveUp:) target:self];
                RDChainedListButton *downButton = [[RDChainedListButton alloc] initWithImage:s_downArrow action:@selector(moveDown:) target:self];
                
                [newItem addOptionButton:downButton];
                [newItem addOptionButton:upButton];
                
                [upButton release];
                [downButton release];                
                
                [_rdActionChainView addItem:newItem];                
                [newItem autorelease];
            }
        }
    }
    
    [_rdConditionChainView setNeedsDisplay:YES];
    [_rdActionChainView setNeedsDisplay:YES];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if (_rdNoRedraw) {
        _rdNoRedraw = NO;
        return;
    }

    [self resynchChainedView];
}

- (void) eventDoubleClicked:(id) sender
{
    NSPoint mousePoint = [[_rdTableView window] mouseLocationOutsideOfEventStream];
    
    mousePoint = [_rdTableView convertPoint:mousePoint fromView:nil];
    
    int row = [_rdTableView rowAtPoint:mousePoint];
    int col = [_rdTableView columnAtPoint:mousePoint];

    NSTableColumn *colObj = [[_rdTableView tableColumns] objectAtIndex:col];
    
    id <EventDataProtocol> event = [_rdEventData eventAtIndex:row];
    
    if (colObj && event) {
        if ([[colObj identifier] isEqualToString:@"eventName"]) {
            if ([event eventCanEditNameSpecial]) {
                [event eventEditNameHook];
                return;
            }
        }
        else if (![[colObj identifier] isEqualToString:@"eventDesc"] && ![[colObj identifier] isEqualToString:@"eventEnabled"]) {
            [event eventEditExtraDataHook:[colObj identifier]];
            return;
        }
    }
    
    // Handle Leopard event blocking, bleh.
    if ([[RDNestedViewManager manager] isLeopard])
        [_rdTableView editColumn:col row:row withEvent:nil select:YES];
}

#pragma mark Commands

- (void) enableEvent:(id) sender
{
    NSPoint mousePoint = [[_rdTableView window] mouseLocationOutsideOfEventStream];
    
    mousePoint = [_rdTableView convertPoint:mousePoint fromView:nil];
    
    int row = [_rdTableView rowAtPoint:mousePoint];
    int col = [_rdTableView columnAtPoint:mousePoint];

    NSTableColumn *colObj = [[_rdTableView tableColumns] objectAtIndex:col];
    
    id <EventDataProtocol> event = [_rdEventData eventAtIndex:row];
    
    if (colObj && event) {
        if ([[colObj identifier] isEqualToString:@"eventActive"]) {
            [event eventSetEnabled:![event eventIsEnabled]];
            
            [_rdTableView reloadData];
        }
    }
}

- (void) moveEventUp:(id) sender
{
    id <EventDataProtocol> event = nil;
    int selected = [_rdTableView selectedRow];
    [[_rdTableView window] makeFirstResponder:[_rdTableView window]];
    
    if (selected != -1) {
        event = [_rdEventData eventAtIndex:selected];
    
        if (event) {
            unsigned newIndex = selected - 1;
            
            if ((newIndex >= 0) && (newIndex < [_rdEventData eventsCount])) {
                [_rdEventData moveEvent:event toIndex:newIndex];
                [_rdTableView reloadData];
                _rdNoRedraw = YES;
                [_rdTableView selectRow:newIndex byExtendingSelection:NO];
                _rdNoRedraw = NO;
            }
        }
    }
}

- (void) moveEventDown:(id) sender
{
    id <EventDataProtocol> event = nil;
    int selected = [_rdTableView selectedRow];
    [[_rdTableView window] makeFirstResponder:[_rdTableView window]];
    
    if (selected != -1) {
        event = [_rdEventData eventAtIndex:selected];
    
        if (event) {
            unsigned newIndex = selected + 1;
            
            if ((newIndex >= 0) && (newIndex < [_rdEventData eventsCount])) {
                [_rdEventData moveEvent:event toIndex:newIndex];
                [_rdTableView reloadData];
                _rdNoRedraw = YES;
                [_rdTableView selectRow:newIndex byExtendingSelection:NO];
                _rdNoRedraw = NO;
            }
        }
    }
}

- (void) addEvent:(id) sender
{
    if (_rdDelegate) {
        [_rdDelegate addEvent];
    }
}

- (void) removeEvent:(id) sender
{
    id <EventDataProtocol> event = nil;
    int selected = [_rdTableView selectedRow];
    [[_rdTableView window] makeFirstResponder:[_rdTableView window]];
    
    if (selected != -1) {
        event = [_rdEventData eventAtIndex:selected];
        
        if (event) {
            [_rdEventData removeEvent:event];
        }
    }
    [_rdTableView reloadData];
}

- (void) changeConditionsAnded:(id) sender
{
    id <EventDataProtocol> event = nil;
    int selected = [_rdTableView selectedRow];
    
    if (selected != -1) {
        event = [_rdEventData eventAtIndex:selected];
        
        if (event) {
            int selected = [_rdConditionType indexOfSelectedItem];

            [event eventSetConditionsAnded:selected];
        }
    }
}

- (void) addCondition:(id) sender
{
    id <EventDataProtocol> event = nil;
    int selected = [_rdTableView selectedRow];
    
    if (selected != -1) {
        event = [_rdEventData eventAtIndex:selected];

        BaseCondition *condition = nil;
        
        if ([sender isKindOfClass:[NSMenuItem class]]) {
            Class aClass = [(NSMenuItem*)sender representedObject];            
            condition = (BaseCondition *)class_createInstance(aClass,0);
        }        
        
        if (event && condition && _rdDelegate) {
            [_rdDelegate newConditionPicked:condition context:event];
        }
    }
}

- (void) removeCondition: (id) sender
{
    id <EventDataProtocol> event = nil;
    int selected = [_rdTableView selectedRow];
    
    if (selected != -1) {
        event = [_rdEventData eventAtIndex:selected];
        
        if (event) {
            id <EventConditionProtocol> condition = nil;
            
            RDChainedListItem *item = [_rdConditionChainView currentActiveItem];
            if (item) {
                unsigned itemPos = [_rdConditionChainView positionOfItem:item];
                
                if (itemPos != NSNotFound) {
                    condition = [[event eventConditions] objectAtIndex:itemPos];
                    
                    if (condition) {
                        [[_rdTableView window] makeFirstResponder:[_rdTableView window]];
                        [event eventRemoveCondition:condition];
                        [_rdConditionChainView removeItem:item];
                        [_rdConditionChainView setNeedsDisplay:YES];
                    }
                }
            }
        }
    }
}

- (void) addAction:(id) sender
{
    id <EventDataProtocol> event = nil;
    int selected = [_rdTableView selectedRow];
    
    if (selected != -1) {
        event = [_rdEventData eventAtIndex:selected];
        
        BaseAction *action = nil;
        
        if ([sender isKindOfClass:[NSMenuItem class]]) {
            Class aClass = [(NSMenuItem*)sender representedObject];            
            action = (BaseAction *)class_createInstance(aClass,0);
        }        
        
        if (event && action && _rdDelegate) {
            [_rdDelegate newActionPicked:action context:event];
        }
    }
}

- (void) removeAction:(id) sender
{
    id <EventDataProtocol> event = nil;
    int selected = [_rdTableView selectedRow];
    
    if (selected != -1) {
        event = [_rdEventData eventAtIndex:selected];
        
        if (event) {
            id <EventActionProtocol> action = nil;
            
            RDChainedListItem *item = [_rdActionChainView currentActiveItem];
            if (item) {
                unsigned itemPos = [_rdActionChainView positionOfItem:item];
                
                if (itemPos != NSNotFound) {
                    action = [[event eventActions] objectAtIndex:itemPos];
                    
                    if (action) {
                        [[_rdTableView window] makeFirstResponder:[_rdTableView window]];
                        [event eventRemoveAction:action];
                        [_rdActionChainView removeItem:item];
                        [_rdConditionChainView setNeedsDisplay:YES];
                    }
                }
            }
        }
    }
}

#pragma mark Delegate

- (void) setDelegate:(id) delegate
{
    [delegate retain];
    [_rdDelegate release];
    _rdDelegate = delegate;
    
    [_rdAddActionButton setMenu:[[ActionPicker sharedPanel] menuForActions:[_rdDelegate actions] withTarget:self] forSegment:0];
    [_rdAddConditionButton setMenu:[[ConditionPicker sharedPanel] menuForConditions:[_rdDelegate conditions] withTarget:self] forSegment:0];
}

- (id) delegate
{
    return _rdDelegate;
}

#pragma mark Customization

- (void) setNameColumnTitle:(NSString *) title
{
    NSTableColumn *nameColumn = [_rdTableView tableColumnWithIdentifier:@"eventName"];
    
    if (nameColumn) {
        [[nameColumn headerCell] setStringValue:title];
    }
}

- (void) setDescriptionColumnTitle:(NSString *) title
{
    NSTableColumn *descColumn = [_rdTableView tableColumnWithIdentifier:@"eventDesc"];
    
    if (descColumn) {
        [[descColumn headerCell] setStringValue:title];
    }
}


- (void) addExtraDataColumn:(NSString *) identifier withTitle:(NSString *) title andCell:(NSCell *) cell;
{
    if ([_rdTableView tableColumnWithIdentifier:identifier])
        return;
        
    NSTableColumn *newCol = [[NSTableColumn alloc] initWithIdentifier:identifier];
    [[newCol headerCell] setStringValue:title];
    [newCol setMinWidth:40.0f];
    if (cell)
        [newCol setDataCell:cell];
        
    [_rdTableView addTableColumn:newCol];
    [_rdTableView sizeToFit];
}

- (void) addExtraDataColumn:(NSString *) identifier withTitle:(NSString *) title andCell:(NSCell *) cell atIndex:(int) position;
{
    [self addExtraDataColumn:identifier withTitle:title andCell:cell];
    
    int colIndex = [_rdTableView columnWithIdentifier:identifier];
    if (colIndex != NSNotFound) {
        [_rdTableView moveColumn:colIndex toColumn:position];
    }
}

- (void) setExtraDataColumn:(NSString *)identifier isEditable:(BOOL)editable
{
    NSTableColumn *column = [_rdTableView tableColumnWithIdentifier:identifier];
    if (column) {
        [column setEditable:editable];
    }
} 

@end
