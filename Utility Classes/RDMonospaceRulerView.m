//
//  RDMonospaceRulerView.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/3/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "RDMonospaceRulerView.h"

#define RULER_THICKNESS 16.0

        
static NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

@interface NSFont (StringWidth)
- (CGFloat) widthOfString:(NSString *)string;
@end


@implementation RDMonospaceRulerView


- (id)initWithScrollView:(NSScrollView *)aScrollView orientation:(NSRulerOrientation)orientation
{
	
	if ( self = [super initWithScrollView:(NSScrollView *)aScrollView
							  orientation:(NSRulerOrientation)orientation])
	{
		// Set default width
		[self setRuleThickness:RULER_THICKNESS];
        [self setReservedThicknessForAccessoryView:0.0f];
        [self setReservedThicknessForMarkers:0.0f];
		
		NSTextView *textView = [aScrollView documentView];

        _rdDrawAttributes = nil;
        [self setFont:[textView font]];
		[self setClientView:self];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(windowDidUpdate:)
													 name:NSWindowDidUpdateNotification
												   object:[aScrollView window]];
                                                   
        [self setAccessoryView:nil];
	}
	
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_rdDrawAttributes release];
    [super dealloc];
}

- (void)windowDidUpdate:(NSNotification *)notification
{
	[self display];
}

- (void) setFont:(NSFont *)font
{
    _rdFont = font;
    
    
    _rdFontWidth = [font widthOfString:alphabet] / [alphabet length];    

    float height = ([[NSFont labelFontOfSize:[NSFont labelFontSize]] capHeight] * 1.5f);
    
    [self setAccessoryView:nil];
    [self setRuleThickness:height + 1.0f];
    [self setReservedThicknessForAccessoryView:0.0f];
    [self setReservedThicknessForMarkers:height];
    
    if (_rdDrawAttributes) {
        [_rdDrawAttributes release];
        _rdDrawAttributes = nil;
    }
    
    _rdIndent = [[[[self scrollView] documentView] textContainer] lineFragmentPadding];
    
    _rdDrawAttributes = [[NSDictionary dictionaryWithObjectsAndKeys:[NSFont labelFontOfSize:[NSFont labelFontSize]],NSFontAttributeName,[NSColor controlTextColor],NSForegroundColorAttributeName,nil] retain];
}

-(void)drawRect:(NSRect)rect
{
	if( ! [[self window] isKeyWindow] ) return;
    
    [super drawRect:rect];
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)drawRect 
{
	
	NSRect aRect = [self bounds];
	
    [[NSColor controlHighlightColor] set];
    [NSBezierPath fillRect: aRect];     
	
    NSPoint left = NSMakePoint(0,aRect.size.height);
    NSPoint right = NSMakePoint(aRect.size.width,aRect.size.height);
		
    [[NSColor darkGrayColor] set];
    [NSBezierPath setDefaultLineWidth:1.0];
    [NSBezierPath strokeLineFromPoint:left toPoint:right];
    
    float divider = _rdIndent;

    [NSBezierPath setDefaultLineWidth:0.5f];
    int characterIndex = 0;
    
    while (divider <= (drawRect.origin.x + drawRect.size.width)) {
    
        float top = aRect.size.height - (aRect.size.height / 4.0f);
    
        if (!(characterIndex % 10))
            top = 0;
        else if (!(characterIndex % 5))
            top = aRect.size.height / 2.0f;
    
        [NSBezierPath strokeLineFromPoint:NSMakePoint(divider,top) toPoint:NSMakePoint(divider,aRect.size.height)];
        
        if (characterIndex && !(characterIndex % 10)) {
            NSString *tempString = [NSString stringWithFormat:@"%d", characterIndex];
            NSPoint textPoint = NSMakePoint(divider + 2.0f,2.0f);
            
            [tempString drawAtPoint:textPoint withAttributes:_rdDrawAttributes];
        }
        
        divider += _rdFontWidth;
        characterIndex++;        
    }

}

- (void) drawMarkersInRect:(NSRect)drawRect
{

}

- (BOOL)rulerView:(NSRulerView *)aRulerView shouldAddMarker:(NSRulerMarker *)aMarker
{
	return NO;
}

@end
