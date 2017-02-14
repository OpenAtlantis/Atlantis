//
//  HighlightEvent.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "HighlightEvent.h"


@implementation HighlightEvent

#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdPattern = [[RDStringPattern patternWithString:@"" type:RDPatternBeginsWith] retain];
        _rdFgColor = nil;
        _rdBgColor = nil;
    }
    return self;
}

- (id) initWithPattern:(RDStringPattern *) pattern foreground:(NSColor *) fg background:(NSColor *) bg
{
    self = [self init];
    if (self) {
        [_rdPattern release];
        _rdPattern = [pattern retain];
        
        if (fg) {
            _rdFgColor = [fg retain];
        }
        if (bg) {
            _rdBgColor = [bg retain];
        }
    }
    return self;
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [self init];
    if (self) {
        _rdPattern = [[coder decodeObjectForKey:@"highlight.pattern"] retain];
        _rdFgColor = [[coder decodeObjectForKey:@"highlight.foreground"] retain];
        _rdBgColor = [[coder decodeObjectForKey:@"highlight.background"] retain];
    
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    if (_rdPattern)
        [coder encodeObject:_rdPattern forKey:@"highlight.pattern"];
    if (_rdFgColor)
        [coder encodeObject:_rdFgColor forKey:@"highlight.foreground"];
    if (_rdBgColor)
        [coder encodeObject:_rdBgColor forKey:@"highlight.background"];
}

#pragma mark Accessors

- (RDStringPattern *) pattern
{
    return _rdPattern;
}

- (void) setPattern:(RDStringPattern *) pattern
{
    [pattern retain];
    [_rdPattern release];
    _rdPattern = pattern;
}

- (NSColor *) foreground
{
    return _rdFgColor;
}

- (void) setForeground:(NSColor *) fg
{
    [fg retain];
    [_rdFgColor release];
    _rdFgColor = fg;
}

- (NSColor *) background
{
    return _rdBgColor;
}

- (void) setBackground: (NSColor *) bg
{
    [bg retain];
    [_rdBgColor release];
    _rdBgColor = bg;
}

#pragma mark Execution

- (BOOL) highlightLine:(NSMutableAttributedString *) line
{
    if (!line)
        return NO;

    if (!_rdPattern)
        return NO;
        
    if (!_rdFgColor && !_rdBgColor)
        return NO;

    NSRange resultRange = [_rdPattern stringMatch:[line string]];

    BOOL highlighted = NO;

    while (resultRange.length) {
        
        highlighted = YES;
        
        if (_rdFgColor) {
            [line addAttribute:NSForegroundColorAttributeName value:_rdFgColor range:resultRange];
        }
        
        if (_rdBgColor) {
            [line addAttribute:NSBackgroundColorAttributeName value:_rdBgColor range:resultRange];
        }                

        resultRange = [_rdPattern stringMatch:nil];
    }    
    
    return highlighted;
}

@end
