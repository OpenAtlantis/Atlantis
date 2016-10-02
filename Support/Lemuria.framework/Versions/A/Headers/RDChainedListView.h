//
//  RDChainedListView.h
//  CLVTest
//
//  Created by Rachel Blackman on 2/17/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RDChainedListItem;

@interface RDChainedListView : NSView {

    NSColor                 *_rdBackground;
    
    NSMutableArray          *_rdItems;

    float                    _rdSpacing;
    float                    _rdMargin;
    float                    _rdCurLastY;
    
    RDChainedListItem       *_rdCurrentActive;
    BOOL                     _rdAutocollapse;
    BOOL                     _rdInLayout;
    
    id                       _rdDelegate;
}

- (NSColor *) background;
- (void) setBackground:(NSColor *) background;

- (void) addItem:(RDChainedListItem *) item;
- (void) removeItem:(RDChainedListItem *) item;
- (void) relayoutFromItem:(RDChainedListItem *) item;
- (void) moveItem:(RDChainedListItem *)item toPosition:(int) position;
- (void) removeAllItems;

- (RDChainedListItem *) itemAtPosition:(unsigned) pos;
- (unsigned) positionOfItem:(RDChainedListItem *) item;

- (RDChainedListItem *) currentActiveItem;

- (BOOL) autocollapse;
- (void) setAutocollapse:(BOOL) autocollapse;

- (id) delegate;
- (void) setDelegate:(id) delegate;

@end
