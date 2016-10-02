//
//  RDNestedViewDisplay.h
//  RDNestingViewsTest
//
//  Created by Rachel Blackman on 1/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lemuria/RDNestedViewCollection.h>
#import <Lemuria/RDNestedViewDescriptor.h>

@protocol RDNestedViewDisplay

- (id) initWithFrame:(NSRect)rect forWindowID:(NSString *)name;

- (void) setCollection:(RDNestedViewCache *)collection;
- (RDNestedViewCache *) collection;

- (NSView *) contentView;
- (NSRect) contentFrame;

- (BOOL) selectView:(id <RDNestedViewDescriptor>) view; 
- (id <RDNestedViewDescriptor>) selectedView;

- (void) resynchViews;

- (void) mouseMoved:(NSEvent *)theEvent;

- (id <RDNestedViewDescriptor>) nextView;
- (id <RDNestedViewDescriptor>) previousView;

- (BOOL) isViewListCollapsed;
- (void) expandViewList;
- (void) collapseViewList;

- (void) view:(id <RDNestedViewDescriptor>)aView hasActivity:(BOOL)activity;
- (void) collection:(RDNestedViewCache *)aCollection hasUpdatedAddingView:(id <RDNestedViewDescriptor>)aView;
- (void) collection:(RDNestedViewCache *)aCollection hasUpdatedRemovingView:(id <RDNestedViewDescriptor>)aView;
- (void) collectionIsEmpty:(RDNestedViewCache *)aCollection;

@end
