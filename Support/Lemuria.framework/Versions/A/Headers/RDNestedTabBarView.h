//
//  RDNestedTabBarView.h
//  Lemuria
//
//  Created by Rachel Blackman on 9/8/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol RDNestedViewDescriptor;
@protocol RDNestedViewDisplay;
@class RDNestedViewCache;
@class PSMTabBarControl;

@interface RDNestedTabBarView : NSView <RDNestedViewDisplay> {

    RDNestedViewCache           *_rdViewCollection;
    PSMTabBarControl            *_rdTabBar;
    NSTabView                   *_rdTabView;
    
    BOOL                         _rdSelfDrag;

}

@end
