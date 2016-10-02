//
//  RDNestedViewManager.h
//  RDNestingViewsTest
//
//  Created by Rachel Blackman on 2/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lemuria/RDNestedViewDescriptor.h>
#import <Lemuria/RDNestedViewWindow.h>

@interface RDNestedViewManagerDelegate
- (unsigned) weightForView:(NSString *) path;
- (id) nestedWindowToolbar:(NSString *) windowUID;
@end

@interface RDNestedViewManager : NSObject {

    NSMutableArray              *_rdAllViews;
    NSMutableArray              *_rdActiveViews;
    NSMutableDictionary         *_rdActiveViewCounts;

    NSMutableDictionary         *_rdWindows;
    NSMutableDictionary         *_rdWindowMappings;
    
    Class                        _rdDisplayStyle;

    unsigned long                _rdUIDCounter;
    
    id <RDNestedViewDescriptor>  _rdDraggedItem;
    NSRect                       _rdDragRect;
    RDNestedViewWindow*          _rdDragWindow;
    
    NSImage *                    _rdWindowIconBase;
    
    id <RDNestedViewDescriptor>  _rdCurView;
    
    BOOL                         _rdIsTerminating;
    BOOL                         _rdNewWindowOpening;
    NSString                     *_rdOpeningWindowUID;
    id                           _rdDelegate;

}

+ (RDNestedViewManager *) manager;

- (NSString *) currentWindowUID;

- (id) init;

- (BOOL) isTiger;
- (BOOL) isLeopard;

- (id) delegate;
- (void) setDelegate:(id) delegate;

- (void) syncDisplayClass;
- (void) setDisplayClass:(Class) class;

- (void) updateAllViews;

- (void) selectView:(id <RDNestedViewDescriptor>)view;
- (BOOL) selectNextActiveView;
- (NSArray *) activeViews;

- (BOOL) hasActivity:(id <RDNestedViewDescriptor>)view;
- (BOOL) hasActivitySelf:(id <RDNestedViewDescriptor>)view;
- (int) activityCount:(id <RDNestedViewDescriptor>)view;
- (int) activityCountSelf:(id <RDNestedViewDescriptor>)view;

- (void) addView:(id <RDNestedViewDescriptor>)view;
- (void) removeView:(id <RDNestedViewDescriptor>)view;

- (RDNestedViewWindow *) windowForUID:(NSString *) windowUID;
- (void) renameWindow:(RDNestedViewWindow *)window withTitle:(NSString *) title;
- (void) removeWindow:(RDNestedViewWindow *)window;

- (void) view:(id <RDNestedViewDescriptor>)aView hasActivity:(BOOL)activity;
- (void) viewReceivedFocus:(id <RDNestedViewDescriptor>)aView;
- (id <RDNestedViewDescriptor>) currentFocusedView;

- (id <RDNestedViewDescriptor>) viewByPath:(NSString *)path;
- (id <RDNestedViewDescriptor>) viewByUid:(NSString *) uid;

- (void) viewRequestedClose:(id <RDNestedViewDescriptor>)aView;

- (unsigned long) uidCounter;

- (void) placeholderView:(id <RDNestedViewDescriptor>)view inWindow:(RDNestedViewWindow *)window;

- (BOOL) beginDraggingView:(id <RDNestedViewDescriptor>)view onEvent:(NSEvent *)anEvent;
- (BOOL) isDragging;

@end
