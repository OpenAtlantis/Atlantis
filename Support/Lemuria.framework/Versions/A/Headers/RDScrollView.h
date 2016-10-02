//
//  RDScrollView.h
//  RDControlsTest
//
//  Created by Rachel Blackman on 9/17/05.
//  Copyright 2005 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RDScroller : NSScroller
{
    BOOL       _rdAutoScroll;
}

- (id) init;
- (void) mouseDown: (NSEvent *)theEvent;
- (void) trackScrollButtons:(NSEvent *)theEvent;
- (void) trackKnob:(NSEvent *)theEvent;

- (BOOL) autoScroll;
- (void) setAutoScroll: (BOOL) scroll;
- (void) calculateAutoScroll;

@end

@interface RDScrollView : NSScrollView {

}

- (id) initWithFrame:(NSRect) frame;
- (void) scrollWheel:(NSEvent *) theEvent;
- (BOOL) autoScroll;
- (void) recalculateAutoScroll;

@end
