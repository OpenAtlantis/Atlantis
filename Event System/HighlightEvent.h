//
//  HighlightEvent.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDStringPattern.h"

@interface HighlightEvent : NSObject <NSCoding> {

    RDStringPattern             *_rdPattern;
    NSColor                     *_rdFgColor;
    NSColor                     *_rdBgColor;

}

- (id) initWithPattern:(RDStringPattern *) pattern foreground:(NSColor *)fg background:(NSColor *) bg;

- (RDStringPattern *) pattern;
- (NSColor *) foreground;
- (NSColor *) background;

- (void) setPattern:(RDStringPattern *) pattern;
- (void) setForeground:(NSColor *) fg;
- (void) setBackground:(NSColor *) bg;

- (BOOL) highlightLine:(NSMutableAttributedString *) line;

@end
