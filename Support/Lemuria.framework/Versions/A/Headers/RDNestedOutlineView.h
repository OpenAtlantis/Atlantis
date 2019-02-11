//
//  RDNestedOutlineView.h
//  RDNestingViewsTest
//
//  Created by Rachel Blackman on 2/3/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lemuria/RBSplitView.h>

@class RDOutlineView;
@class RDNestedViewCache;
@class RBSplitSubview;
@class RSGradientSquareButton;
@protocol RDNestedViewDescriptor;
@protocol RDNestedViewDisplay;

@interface RDNestedOutlineView : RBSplitView <RDNestedViewDisplay,NSOutlineViewDelegate,NSOutlineViewDataSource> {

    NSTabView                *_rdTabView;
    RDOutlineView            *_rdOutlineView;
    NSScrollView             *_rdScrollView;
    
    RSGradientSquareButton   *_rdBottomBar;
    NSTimeInterval            _rdBottomBarLastClick;
    
    RBSplitView              *_rdOutlineContainer;
    RBSplitView              *_rdContentContainer;
    
    NSString                 *_rdSaveID;
    
    RDNestedViewCache        *_rdViewCollection;
    
    id                        _rdLastSelected;
    
    BOOL                      _rdSelfDrag;
    
    BOOL                      _rdViewCollapsed;
    float                     _rdExpandedSize;
    
    NSImage                  *_rdRedLightImage;
    NSImage                  *_rdYellowLightImage;
    NSImage                  *_rdCloseButtonImage;
    NSImage                  *_rdCloseButtonPressedImage;

}

- (void) resynchSelection;
- (void) expandToDisplayView:(id <RDNestedViewDescriptor>)view;
- (NSTabViewItem *) itemForView:(id <RDNestedViewDescriptor>)view;

- (NSOutlineView *) outlineView;

@end
