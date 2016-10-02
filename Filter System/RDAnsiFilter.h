//
//  RDAnsiFilter.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/11/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDAtlantisFilter.h"

@interface RDAnsiState : NSObject
{
    BOOL        _rdAnsiBoldMe;
    BOOL        _rdAnsiInvertMe;
    BOOL        _rdAnsiUnderlineMe;
    int         _rdAnsiLastColor;
    int         _rdAnsiLastBackground;   
    
    BOOL                   _rdBoldOnIntense;
    
    NSAttributedString *   _rdHoldover;
    NSArray            *   _rdColors;
    NSColor            *   _rdBackground;
    NSColor            *   _rdDefaultColor;
    NSFont             *   _rdFont;
    NSFont             *   _rdFontBold;
    NSParagraphStyle   *   _rdParaStyle;
    NSDate             *   _rdDateStamp;
    
    NSMutableDictionary *  _rdCurrentAttributes;
}

- (BOOL) bold;
- (BOOL) invert;
- (BOOL) underline;
- (int) lastColor;
- (int) lastBackground;
- (NSAttributedString *) holdover;

- (void) setBold:(BOOL)bold;
- (void) setInvert:(BOOL)invert;
- (void) setUnderline:(BOOL)underline;
- (void) setColor:(int)color;
- (void) setBackground:(int)background;
- (void) setHoldover:(NSAttributedString *)string;

- (void) setColorArray:(NSArray *)colors;
- (void) setDocumentBackground:(NSColor *) background;
- (void) setDocumentDefault:(NSColor *)defaultColor;
- (void) setBoldOnIntense:(BOOL) bOnInt;
- (void) setParagraphStyle:(NSParagraphStyle *) paraStyle;
- (void) setTimestamp:(NSDate *)timestamp;

- (void) applyToString:(NSMutableAttributedString *)string withRange:(NSRange)range;
- (void) reset;

- (NSDictionary *) attributes;

@end



@interface RDAnsiFilter : RDAtlantisFilter {
    
    RDAnsiState                     *_rdState;
    
    int         _rdBeepBehavior;
    
}

@end
