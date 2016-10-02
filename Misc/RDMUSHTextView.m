//
//  RDMUSHTextView.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/18/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDMUSHTextView.h"
#import "RDAtlantisApplication.h"

@implementation RDMUSHTextView

- (id) initWithFrame:(NSRect) frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _rdBaseCursor = nil;
    }
    return self;
}

- (void) awakeFromNib
{
    _rdBaseCursor = nil;
}

- (void) dealloc
{
    [_rdBaseCursor release];
    [super dealloc];
}

- (void) copy:(id) sender
{
    NSRange selected = [self selectedRange];
    if (selected.length) {
        NSAttributedString *string = [[self textStorage] attributedSubstringFromRange:selected];
        NSPasteboard *generalPboard = [NSPasteboard generalPasteboard];
        [generalPboard declareTypes:[NSArray arrayWithObjects:NSStringPboardType,@"RDTextType",nil] owner:nil];
        [generalPboard setString:[string string] forType:NSStringPboardType];
        [generalPboard setData:[NSArchiver archivedDataWithRootObject:string] forType:@"RDTextType"];
    }
    else {
        NSBeep();
    }
}

- (void)recolorCursor
{
    if ([RDAtlantisApplication isTiger]) {
        if (!_rdBaseCursor) {
            NSCursor *iBeam = [NSCursor IBeamCursor];
            NSImage *iBeamImg = [[iBeam image] copy];
            NSRect imgRect = {NSZeroPoint, [iBeamImg size]};
            [iBeamImg lockFocus];

            NSColor *tempBackground = [[self backgroundColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

            float backgroundRed = [tempBackground redComponent];
            float backgroundGreen = [tempBackground blueComponent];
            float backgroundBlue = [tempBackground greenComponent];
            
            NSColor *tempColor = [NSColor colorWithCalibratedRed:(1.0 - backgroundRed) green:(1.0 - backgroundGreen) blue:(1.0 - backgroundBlue) alpha:1.0];            
            [tempColor set];
                        
            NSRectFillUsingOperation(imgRect,NSCompositeSourceAtop);
            [iBeamImg unlockFocus];
            _rdBaseCursor = [[NSCursor alloc] initWithImage:iBeamImg hotSpot:[iBeam hotSpot]];
            [_rdBaseCursor setOnMouseEntered:YES];
//            [iBeamImg release];
        }
        [[self enclosingScrollView] setDocumentCursor:_rdBaseCursor];
        [self addCursorRect:[self visibleRect] cursor:_rdBaseCursor];
    }
}


- (void) setBackgroundColor:(NSColor *)color
{
    [super setBackgroundColor:color];
    [_rdBaseCursor release];
    _rdBaseCursor = nil;
    [self recolorCursor];
}

- (void)resetCursorRects
{
    [super resetCursorRects];
    [self recolorCursor];
}

- (void) mouseEntered:(NSEvent *)theEvent
{
    [self recolorCursor];
}

/*
- (void) mouseMoved:(NSEvent *)theEvent
{
    [self recolorCursor];
} */

- (void) mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    [self recolorCursor];
}

- (void) mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
    [self resetCursorRects];
}

- (void) doCommandBySelector:(SEL)selector
{
    [super doCommandBySelector:selector];
}

- (void) insertNewline:(id) sender
{
    [super insertNewline:sender];
}

- (void) paste:(id) sender
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *types = [pasteboard types];
    if ([types containsObject:@"RDTextType"]) {
        NSData *data = [pasteboard dataForType:@"RDTextType"];
        NSAttributedString *string = [NSUnarchiver unarchiveObjectWithData:data];
        [self insertText:string];
    }
    else
        [super paste:sender];
}

@end
