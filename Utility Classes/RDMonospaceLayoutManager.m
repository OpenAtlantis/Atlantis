//
//  RDMonospaceLayoutManager.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/3/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "RDMonospaceLayoutManager.h"


@implementation RDMonospaceLayoutManager

- (NSView *)rulerAccessoryViewForTextView:(NSTextView *)aTextView paragraphStyle:(NSParagraphStyle *)paraStyle ruler:(NSRulerView *)aRulerView enabled:(BOOL)flag
{
    return nil;
}

- (void)drawGlyphsForGlyphRange:(NSRange)glyphRange atPoint:(NSPoint)containerOrigin
{
    [super drawGlyphsForGlyphRange:glyphRange atPoint:containerOrigin];
}

@end
