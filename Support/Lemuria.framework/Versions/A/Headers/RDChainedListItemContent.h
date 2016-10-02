//
//  RDChainedListItemContent.h
//  CLVTest
//
//  Created by Rachel Blackman on 2/17/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RDChainedListItemContent : NSView {

    NSView                  *_rdMainView;
    NSView                  *_rdAlternateView;
    
    BOOL                     _rdAlternate;
    BOOL                     _rdAnimating;
    BOOL                     _rdResynching;
}

- (void) setMainView:(NSView *) view;
- (void) setAlternateView:(NSView *) view;

- (NSView *) mainView;
- (NSView *) alternateView;

- (BOOL) isShowingAlternate;
- (void) setShowsAlternate:(BOOL) alternate;

- (void) resynch;
- (void) resynchNoDisplay;

@end
