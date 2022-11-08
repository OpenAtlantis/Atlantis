//
//  EventEditor.h
//  LemuriaTestbed
//
//  Created by Rachel Blackman on 2/24/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lemuria/Lemuria.h>

@class EventCollection;
@protocol EventDataProtocol;

@interface EventEditor : NSObject <NSTableViewDataSource, NSTableViewDelegate> {

    IBOutlet NSView                  *_rdEditorContentView;
    
    IBOutlet NSTableView             *_rdTableView;

    IBOutlet NSScrollView            *_rdConditionScrollView;
    IBOutlet RDChainedListView       *_rdConditionChainView;
    IBOutlet NSPopUpButton           *_rdConditionType;
    IBOutlet NSSegmentedControl      *_rdAddConditionButton;
    IBOutlet NSSegmentedControl      *_rdRemoveConditionButton;

    IBOutlet NSScrollView            *_rdActionScrollView;
    IBOutlet RDChainedListView       *_rdActionChainView;
    IBOutlet NSSegmentedControl      *_rdAddActionButton;
    IBOutlet NSSegmentedControl      *_rdRemoveActionButton;
    
    IBOutlet NSTabView               *_rdTabView;
    NSTabViewItem                    *_rdCondItem;

    EventCollection                  *_rdEventData;

    id                                _rdDelegate;

    BOOL                              _rdNoRedraw;

}

- (NSView *) editorView;

- (IBAction) addEvent:(id) sender;
- (IBAction) removeEvent:(id) sender;

- (IBAction) moveEventUp:(id) sender;
- (IBAction) moveEventDown:(id) sender;


- (IBAction) addAction:(id) sender;
- (IBAction) removeAction:(id) sender;

- (IBAction) addCondition:(id) sender;
- (IBAction) removeCondition:(id) sender;
- (IBAction) changeConditionsAnded:(id) sender;

- (void) setDataRepresentation:(EventCollection *) eventData;
- (void) setForEventType:(id <EventDataProtocol>) event;
- (void) updateDataRepresentation;
- (void) selectEvent:(id <EventDataProtocol>) event;


- (id) delegate;
- (void) setDelegate:(id) delegate;

- (void) setNameColumnTitle:(NSString *) title;
- (void) setDescriptionColumnTitle:(NSString *) title;
- (void) addExtraDataColumn:(NSString *) identifier withTitle:(NSString *) title andCell:(NSCell *) cell;
- (void) addExtraDataColumn:(NSString *) identifier withTitle:(NSString *) title andCell:(NSCell *) cell atIndex:(int) position;
- (void) setExtraDataColumn:(NSString *)identifier isEditable:(BOOL)editable;

@end
