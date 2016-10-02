//
//  RDChainedListItem.h
//  CLVTest
//
//  Created by Rachel Blackman on 2/16/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RDChainedListButton;
@class RDChainedListItemContent;

@interface RDChainedListItem : NSView {

    NSMutableArray              *_rdOptionButtons;
    RDChainedListItemContent    *_rdContentView;
        
    NSColor                     *_rdBackground;
    NSColor                     *_rdOutlineActive;
    NSColor                     *_rdOutlineInactive;

    NSString                    *_rdTitle;
    NSDictionary                *_rdTitleAttributes;

    float                        _rdBorderWidth;
    BOOL                         _rdActive;
    BOOL                         _rdAlternate;
    
    BOOL                         _rdAvoidRecursion;
}

- (NSView *) mainContentView;
- (NSView *) alternateContentView;

- (void) setMainContentView:(NSView *) view;
- (void) setAlternateContentView:(NSView *) view;

- (void) setTitle:(NSString *) title;
- (NSString *) title;
- (NSDictionary *) titleAttributes;
- (void) setTitleAttributes:(NSDictionary *)attributes;

- (NSColor *) background;
- (NSColor *) outlineActive;
- (NSColor *) outlineInactive;

- (void) setBackground:(NSColor *) bgColor;
- (void) setOutlineActive:(NSColor *) activeColor;
- (void) setOutlineInactive:(NSColor *) inactiveColor;

- (BOOL) isActive;
- (void) setActive:(BOOL) active;

- (BOOL) showsAlternate;
- (void) setShowsAlternate:(BOOL) alternate;

- (void) addOptionButton:(RDChainedListButton *)button;
- (BOOL) checkForButton:(NSPoint) mouseLoc;

- (void) resynch;

@end
