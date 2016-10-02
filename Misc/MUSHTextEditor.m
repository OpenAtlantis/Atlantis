//
//  MUSHTextEditor.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "MUSHTextEditor.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisMainController.h"
#import "RDAtlantisWorldPreferences.h"
#import "RDMonospaceLayoutManager.h"

@interface MUSHTextEditor (Private)
- (NSColor *) colorForId:(int) colorId;
- (void) colorPickedId:(int) colorId background:(BOOL) isBG;
- (NSString *) editorAsMUSHText;
@end

@implementation MUSHTextEditor

- (id) init
{
    self = [super init];
    if (self) {
        [NSBundle loadNibNamed:@"MUSHTextEditor" owner:self];
        _rdWorld = nil;
        _rdFont = nil;
        _rdRuler = nil;
        _rdLayoutManager = nil;
        
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
    [_rdWorld release];
    [_rdLayoutManager release];
    [_rdRuler release];
}

- (void) awakeFromNib
{
    [self setupForWorld:nil];
}

- (void) setupForWorld:(RDAtlantisWorldInstance *) world
{
    NSArray *cells = [_rdColorPicker cells];
    NSEnumerator *cellEnum = [cells objectEnumerator];
    
    NSCell *cellWalk;
    
    [world retain];
    [_rdWorld release];
    _rdWorld = world;
    
    while (cellWalk = [cellEnum nextObject]) {
        [cellWalk setType:NSImageCellType];
        
        NSImage *tempImage = [[NSImage alloc] initWithSize:NSMakeSize(100,100)];
        NSRect tempRect = NSMakeRect(0,0,100,100);
        [tempImage lockFocus];
        
        NSColor *tempColor = [self colorForId:[cellWalk tag]];
        [tempColor set];
        NSRectFill(tempRect);
        [tempImage unlockFocus];
        [cellWalk setImage:tempImage];
        [cellWalk setCellAttribute:NSCellIsBordered to:1];
        [cellWalk setCellAttribute:NSCellIsInsetButton to:1];
        [tempImage release];
    }

    [_rdFont release];
    _rdFont = nil;

    if (_rdWorld) {
        _rdFont = [[_rdWorld preferenceForKey:@"atlantis.formatting.font"] retain];
    }
    else {
        _rdFont = [[[[RDAtlantisMainController controller] globalWorld] preferenceForKey:@"atlantis.formatting.font" withCharacter:nil] retain];
    }
    
    if (!_rdFont)
        _rdFont = [[NSFont userFixedPitchFontOfSize:12.0f] retain];

    if (!_rdRuler) {
        NSTextContainer *container = [[NSTextContainer alloc] initWithContainerSize:[[_rdEditorView textContainer] containerSize]];
        NSTextStorage *storage = [[NSTextStorage alloc] initWithString:@""];
        _rdLayoutManager = [[RDMonospaceLayoutManager alloc] init];
        [_rdLayoutManager addTextContainer:container];
        [storage addLayoutManager:_rdLayoutManager];
        [container setTextView:_rdEditorView];
        [container release];

        _rdRuler = [[RDMonospaceRulerView alloc] initWithScrollView:[_rdEditorView enclosingScrollView] orientation:NSHorizontalRuler];
        [[_rdEditorView enclosingScrollView] setRulersVisible:YES];
        [[_rdEditorView enclosingScrollView] setHasVerticalRuler:NO];
        [[_rdEditorView enclosingScrollView] setHasHorizontalRuler:YES];
        [[_rdEditorView enclosingScrollView] setHorizontalRulerView:_rdRuler];
        [_rdEditorView setEditable:YES];
    }
    [_rdRuler setFont:_rdFont];
    
    [self colorPickedId:7 background:NO];
    [self colorPickedId:0 background:YES];
    
    _rdIsBackground = NO;
    
    [_rdEditorView setInsertionPointColor:[self colorForId:7]];

    [_rdSourceView turnOffKerning:self];
    [_rdEditorView setFont:_rdFont];
    [_rdSourceView setFont:_rdFont];
        
    int ansiType = [[NSUserDefaults standardUserDefaults] integerForKey:@"atlantis.mushEdit.ansiType"];    
    [_rdAnsiTypePicker selectCellWithTag:ansiType];
        
    NSColor *selectColor = [_rdWorld preferenceForKey:@"atlantis.colors.selection"];
    if (selectColor) {    
        NSDictionary *selectDict =
        [NSDictionary dictionaryWithObjectsAndKeys:
            selectColor,NSBackgroundColorAttributeName,
            nil];
        [_rdEditorView setSelectedTextAttributes:selectDict];
    }
}

- (int) idForColor:(NSColor *)color
{
    NSArray *colors;
    if (_rdWorld) {
        colors = [_rdWorld preferenceForKey:@"atlantis.colors.ansi"];
    }
    else {
        colors = [[[RDAtlantisMainController controller] globalWorld] preferenceForKey:@"atlantis.colors.ansi" withCharacter:nil];
    }

    return [colors indexOfObject:color];
}

- (NSColor *) colorForId:(int) colorId
{
    NSArray *colors;
    if (_rdWorld) {
        colors = [_rdWorld preferenceForKey:@"atlantis.colors.ansi"];
    }
    else {
        colors = [[[RDAtlantisMainController controller] globalWorld] preferenceForKey:@"atlantis.colors.ansi" withCharacter:nil];
    }
    
    return [colors objectAtIndex:colorId];
}

- (BOOL) isInUse
{
    if (![[self window] isVisible]) {
        return NO;
    }
    
    if (![[[_rdEditorView textStorage] string] length]) {
        return NO;
    }
    
    return YES;
}

- (void) display
{
    [[self window] makeKeyAndOrderFront:self];
}

- (void) ansiPicked:(id) sender
{
    int ansiType = [[_rdAnsiTypePicker selectedCell] tag];
    [[NSUserDefaults standardUserDefaults] setInteger:ansiType forKey:@"atlantis.mushEdit.ansiType"];
}

- (void) clearEditor:(id) sender
{
    [_rdEditorView setSelectedRange:NSMakeRange(0,[[_rdEditorView textStorage] length])];
    [_rdEditorView delete:sender];
    [self colorPickedId:7 background:NO];
    [self colorPickedId:0 background:YES];
    
    _rdIsBackground = NO;
    [_rdInvertColors setState:NSOffState];
    [_rdUnderline setState:NSOffState];
    
    [_rdEditorView setInsertionPointColor:[self colorForId:7]];
}

- (NSDictionary *) currentAttributes
{
    NSString *fgAttrName;
    NSString *bgAttrName;
    BOOL inverted = NO;
    BOOL underlined = NO;
    
    if ([_rdUnderline state] == NSOnState) {
        underlined = YES;
    }
    
    if ([_rdInvertColors state] == NSOnState) {
        inverted = YES;
        fgAttrName = NSBackgroundColorAttributeName;
        bgAttrName = NSForegroundColorAttributeName;
    }
    else {
        fgAttrName = NSForegroundColorAttributeName;
        bgAttrName = NSBackgroundColorAttributeName;
    }

    NSDictionary *result = 
        [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:_rdForegroundColor],@"RDAnsiForegroundColor",
                        [NSNumber numberWithInt:_rdBackgroundColor],@"RDAnsiBackgroundColor",
                        [self colorForId:_rdForegroundColor],fgAttrName,
                        _rdBackgroundColor ? [self colorForId:_rdBackgroundColor] : [NSColor blackColor], bgAttrName,
                        [NSNumber numberWithBool:inverted], @"RDAnsiInverseToggle",
                        _rdFont,NSFontAttributeName,
                        [NSNumber numberWithInt:(underlined ? NSUnderlineStyleSingle : NSUnderlineStyleNone)], NSUnderlineStyleAttributeName,
                        nil];
                        
    return result;
}

- (void) colorPickedId:(int) colorId background:(BOOL)isBG
{
    if (isBG) {
        if (colorId > 7)
            _rdBackgroundColor = colorId - 8;
        else
            _rdBackgroundColor = colorId;
    }
    else {
        _rdForegroundColor = colorId;
    }

    NSColor *color;
    
    if (isBG && !colorId) {
        if (_rdWorld) {
            color = [_rdWorld preferenceForKey:@"atlantis.colors.background"];
        }
        else {
            color = [[[RDAtlantisMainController controller] globalWorld] preferenceForKey:@"atlantis.colors.background" withCharacter:nil];
        }
    }
    else
        color = [self colorForId:isBG ? _rdBackgroundColor : _rdForegroundColor];
    
    if (color) {
        NSImage *tempImage = [[NSImage alloc] initWithSize:NSMakeSize(100,100)];
        NSRect tempRect = NSMakeRect(0,0,100,100);
        [tempImage lockFocus];        
        [color set];
        NSRectFill(tempRect);
        [tempImage unlockFocus];
        if (isBG)
            [_rdCurrentBackground setImage:tempImage];
        else
            [_rdCurrentColor setImage:tempImage];
        [tempImage release];
    }
    
    NSDictionary *dict = [[self currentAttributes] retain];
    [_rdEditorView setTypingAttributes:dict];

    NSRange selectedRange = [_rdEditorView selectedRange];
    if (selectedRange.length) {
        [[_rdEditorView textStorage] setAttributes:dict range:selectedRange];
    }
    [dict release];
}

- (void) toggleInverse:(id) sender
{
    NSDictionary *dict = [[self currentAttributes] retain];
    [_rdEditorView setTypingAttributes:dict];

    NSRange selectedRange = [_rdEditorView selectedRange];
    if (selectedRange.length) {
        [[_rdEditorView textStorage] setAttributes:dict range:selectedRange];
    }
    [dict release];
}

- (void) toggleUnderline:(id) sender
{
    NSDictionary *dict = [[self currentAttributes] retain];
    [_rdEditorView setTypingAttributes:dict];

    NSRange selectedRange = [_rdEditorView selectedRange];
    if (selectedRange.length) {
        [[_rdEditorView textStorage] setAttributes:dict range:selectedRange];
    }
    [dict release];
}

- (void) colorPicked:(id) sender
{
    int tag = [[sender selectedCell] tag];
    
    [self colorPickedId:tag background:_rdIsBackground];
}

- (void) switchContext:(id) sender
{
    if (sender == _rdCurrentColor) {
        _rdIsBackground = NO;
    }
    else if (sender == _rdCurrentBackground) {
        _rdIsBackground = YES;
    }
}

- (BOOL) isUnderlinedInAttributes:(NSDictionary *) attrDict
{
    NSNumber *underline = [attrDict objectForKey:NSUnderlineStyleAttributeName];
    if (underline) {
        if ([underline intValue] == NSSingleUnderlineStyle)
            return YES;
    }
    
    return NO;
}

- (BOOL) isInvertedInAttributes:(NSDictionary *) attrDict
{
    NSNumber *inverse = [attrDict objectForKey:@"RDAnsiInverseToggle"];
    if (inverse) {
        return [inverse boolValue];
    }
    
    return NO;
}


- (BOOL) isHighlightedInAttributes:(NSDictionary *) attrDict
{
    NSNumber *fgNumber = [attrDict objectForKey:@"RDAnsiForegroundColor"];
    if (fgNumber) {
        if ([fgNumber intValue] > 7)
            return YES;
    }
    else {
        int color = -1;
    
        NSColor *testMe = [attrDict objectForKey:NSForegroundColorAttributeName];
        if (testMe) {
            int test = [self idForColor:testMe];
            if (test != NSNotFound) {
                color = test;
            }
        }        
    
        if (color != -1) {
            if (color > 7)
                return YES;
        }
    }
    
    return NO;
}

- (NSString *) bgColorForAttributes:(NSDictionary *) attrDict
{
    NSNumber *bgNumber = [attrDict objectForKey:@"RDAnsiBackgroundColor"];
    int color = -1;
    
    if (bgNumber) {
        color = [bgNumber intValue];
    } 
    else {
        NSColor *testMe = [attrDict objectForKey:NSBackgroundColorAttributeName];
        if (testMe) {
            int test = [self idForColor:testMe];
            if (test != NSNotFound) {
                color = test;
            }
        }        
    }
    
    if (color > 0) {

        switch (color) {
            case 0:
                return @"X";
            case 1:
                return @"R";
            case 2:
                return @"G";
            case 3:
                return @"Y";
            case 4:
                return @"B";
            case 5:
                return @"M";
            case 6:
                return @"C";
            case 7:
                return @"W";
        }
    }
    return nil;
}


- (NSString *) fgColorForAttributes:(NSDictionary *) attrDict
{
    NSNumber *fgNumber = [attrDict objectForKey:@"RDAnsiForegroundColor"];
    
    int color = -1;
    
    if (fgNumber) {
        color = [fgNumber intValue];
        if (color > 7)
            color -= 8;
    } 
    else {
        NSColor *testMe = [attrDict objectForKey:NSForegroundColorAttributeName];
        if (testMe) {
            int test = [self idForColor:testMe];
            if (test != NSNotFound) {
                color = test;
                if (color > 7)
                    color -= 8;
            }
        }        
    }
    
    if (color != -1) {
    
        switch (color) {
            case 0:
                return @"x";
            case 1:
                return @"r";
            case 2:
                return @"g";
            case 3:
                return @"y";
            case 4:
                return @"b";
            case 5:
                return @"m";
            case 6:
                return @"c";
            case 7:
                return @"w";
        }
    }
    return nil;
}

- (NSString *) editorAsMUSHText
{
    unsigned int pos = 0;
    NSMutableString *result = [[NSMutableString alloc] init];
    
    int showType = [[_rdAnsiTypePicker selectedCell] tag];
    
    BOOL wasHighlighted = NO;
    BOOL wasUnderlined = NO;
    BOOL wasInverted = NO;
    
    int  lastFg = 7;
    int  lastBg = 0;
    
    switch (showType) {
        case 0:
            [result appendString:@"%cn"];
            break;
            
        case 1:                    
            [result appendString:@"%xn"];
            break;
    }
    
#ifdef PARASPLIT    
    NSEnumerator *paraEnum = [[[_rdEditorView textStorage] paragraphs] objectEnumerator];
    
    NSAttributedString *mainString;
    BOOL first = YES;

    while (mainString = [paraEnum nextObject])  {
        first = NO;
        pos = 0;
#else
    NSAttributedString *mainString = [_rdEditorView textStorage];
    pos = 0;

#endif
        while (pos < [mainString length]) {
            NSRange effectiveRange;
            NSDictionary *attrs = [mainString attributesAtIndex:pos effectiveRange:&effectiveRange];
            NSMutableString *currentColor = [[NSMutableString alloc] init];
            
            if (showType == 3)
                effectiveRange = NSMakeRange(0,[mainString length]);
            
            if (attrs) {
                BOOL isHighlighted = [self isHighlightedInAttributes:attrs];
                BOOL isUnderlined = [self isUnderlinedInAttributes:attrs];
                BOOL isInverted = [self isInvertedInAttributes:attrs];
                
                int currentFg = 7;
                int currentBg = 0;
                
                NSNumber *fgNumber = [attrs objectForKey:@"RDAnsiForegroundColor"];
                NSNumber *bgNumber = [attrs objectForKey:@"RDAnsiBackgroundColor"];
                
                if (fgNumber) {
                    currentFg = [fgNumber intValue];
                }
                else {
                    NSColor *testMe = [attrs objectForKey:NSForegroundColorAttributeName];
                    if (testMe) {
                        int test = [self idForColor:testMe];
                        if (test != NSNotFound) {
                            currentFg = test;
                        }
                    }
                }
                if (bgNumber) {
                    currentBg = [bgNumber intValue];
                }
                else {
                    NSColor *testMe = [attrs objectForKey:NSBackgroundColorAttributeName];
                    if (testMe) {
                        int test = [self idForColor:testMe];
                        if (test != NSNotFound) {
                            currentBg = test;
                        }
                    }
                }
                
                if ((!isHighlighted && wasHighlighted) || (!isUnderlined && wasUnderlined) || (!isInverted && wasInverted)) {
                    [currentColor appendString:@"n"];
                    wasHighlighted = NO;
                    wasUnderlined = NO;
                    wasInverted = NO;
                    lastFg = 7;
                    lastBg = 0;
                }
                
                // Build string, whoo!
                if (isHighlighted)
                    [currentColor appendString:@"h"];
                
                NSString *tempString;
                
                if (currentFg != lastFg) {
                    tempString = [self fgColorForAttributes:attrs];
                    if (tempString)
                        [currentColor appendString:tempString];
                }
                
                if (currentBg != lastBg) {
                    tempString = [self bgColorForAttributes:attrs];
                    if (tempString)
                        [currentColor appendString:tempString];
                }
                
                if (isUnderlined)
                    [currentColor appendString:@"u"];
                
                if (isInverted)
                    [currentColor appendString:@"i"];
                
                wasHighlighted = isHighlighted;
                wasUnderlined = isUnderlined;
                wasInverted = isInverted;
                lastFg = currentFg;
                lastBg = currentBg;
            }
            else
                effectiveRange = NSMakeRange(pos, [mainString length] - pos);
            
            NSString *currentBlock = [[mainString string] substringWithRange:effectiveRange];
            
            if (currentBlock) {
                
                NSMutableString *escaped = [[NSMutableString alloc] init];
                int position = 0;
                unichar lastChar = 0;
                BOOL isRun = NO;
                int runLength = 0;
                
                while (position < [currentBlock length]) {
                    unichar currentChar = [currentBlock characterAtIndex:position];
                    
                    if (isRun) {
                        if (currentChar == lastChar) {
                            runLength++;
                        }
                        else {
                            NSString *repeatString;
                            
                            if (lastChar == ',') {
                                repeatString = [NSString stringWithString:@"\\,"];
                            }
                            else if (lastChar == ' ') {
                                repeatString = [NSString stringWithString:@"%b"];
                            }
                            else if (lastChar == '(') {
                                repeatString = [NSString stringWithString:@"\\("];
                            }
                            else if (lastChar == ')') {
                                repeatString = [NSString stringWithString:@"\\)"];
                            }
                            else {
                                repeatString = [NSString stringWithFormat:@"%c", lastChar];
                            }
                            
                            if ((runLength > 8) || ((lastChar == ' ') && (runLength > 4))) {
                                if (lastChar == ' ') {
                                    NSString *repeatBlock = [NSString stringWithFormat:@"[space(%d)]", runLength];
                                    [escaped appendString:repeatBlock];
                                }
                                else {
                                    NSString *repeatBlock = [NSString stringWithFormat:@"[repeat(%@,%d)]", repeatString, runLength];
                                    [escaped appendString:repeatBlock];                            
                                }
                            }
                            else {
                                int loop;
                                for (loop = 0; loop < runLength; loop++) {
                                    [escaped appendString:repeatString];
                                }
                            }
                            
                            runLength = 0;
                            isRun = NO;
                        }
                    }
                    
                    if (!isRun) {
                        if (currentChar == '%') {
                            [escaped appendString:@"%%"];
                        }
                        else if ((currentChar == ' ') && (((pos == 0) && (position == 0)) || ((showType == 2) && ((position == 0) || (position == ([currentBlock length] - 1)))))) {
                            [escaped appendString:@"%b"];
                        }
                        else if (currentChar == '[') {
                            [escaped appendString:@"\\["];
                        }
                        else if (currentChar == ']') {
                            [escaped appendString:@"\\]"];
                        }
                        else if (currentChar == '\\') {
                            [escaped appendString:@"\\\\"];
                        }
                        else if (currentChar == '\t') {
                            [escaped appendString:@"%t"];
                        }
                        else if (currentChar == '\r') {
                            [escaped appendString:@"%r"];
                        }
                        else if (currentChar == '\n') {
                            [escaped appendString:@"%r"];
                        }
                        else if ((currentChar == '(') && (showType == 2)) {
                            [escaped appendString:@"\\("];
                        }
                        else if ((currentChar == ')') && (showType == 2)) {
                            [escaped appendString:@"\\)"];
                        }
                        else {                    
                            if ((position + 1) < [currentBlock length]) {
                                unichar nextChar = [currentBlock characterAtIndex:(position + 1)];
                                
                                if (nextChar == currentChar) {
                                    isRun = YES;
                                    runLength = 1;
                                }
                            }
                            
                            if (!isRun) {
                                NSString *charString;
                                
                                if ([currentColor length] && (showType == 2) && (currentChar == ',')) {
                                    charString = [NSString stringWithString:@"\\,"];
                                }
                                else {
                                    charString = [NSString stringWithFormat:@"%c",currentChar];
                                }
                                
                                [escaped appendString:charString];
                            }
                        }
                    }
                    
                    lastChar = currentChar;
                    position++;
                }            
                
                if (isRun)
                {
                    NSString *repeatString;
                    
                    if (lastChar == ',') {
                        repeatString = [NSString stringWithString:@"\\,"];
                    }
                    else if (lastChar == ' ') {
                        repeatString = [NSString stringWithString:@"%b"];
                    }
                    else if (lastChar == '(') {
                        repeatString = [NSString stringWithString:@"\\("];
                    }
                    else if (lastChar == ')') {
                        repeatString = [NSString stringWithString:@"\\)"];
                    }
                    else {
                        repeatString = [NSString stringWithFormat:@"%c", lastChar];
                    }
                    
                    if (runLength > 8) {
                        if (lastChar == ' ') {
                            NSString *repeatBlock = [NSString stringWithFormat:@"[space(%d)]", runLength];
                            [escaped appendString:repeatBlock];
                        }
                        else {
                            NSString *repeatBlock = [NSString stringWithFormat:@"[repeat(%@,%d)]", repeatString, runLength];
                            [escaped appendString:repeatBlock];                            
                        }
                    }
                    else {
                        int loop;
                        for (loop = 0; loop < runLength; loop++) {
                            [escaped appendString:repeatString];
                        }
                    }
                    
                    runLength = 0;
                    isRun = NO;
                }
                
                int colorPosition = 0;
                BOOL needWrapper = NO;
                
                switch (showType) {
                    case 0:
                        while (colorPosition < [currentColor length]) {
                            [result appendString:@"%c"];
                            [result appendString:[currentColor substringWithRange:NSMakeRange(colorPosition,1)]];
                            colorPosition++;
                        }
                        [result appendString:escaped];
                        break;
                        
                    case 1:                    
                        while (colorPosition < [currentColor length]) {
                            [result appendString:@"%x"];
                            [result appendString:[currentColor substringWithRange:NSMakeRange(colorPosition,1)]];
                            colorPosition++;
                        }
                        [result appendString:escaped];
                        break;
                        
                    case 2:
                        if ([currentColor length] && ![currentColor isEqualToString:@"w"])
                            needWrapper = YES;
                        else
                            needWrapper = NO;
                        if (needWrapper) {
                            [result appendString:@"[ansi("];
                            [result appendString:currentColor];
                            [result appendString:@","];
                        }
                            [result appendString:escaped];
                        if (needWrapper) {
                            [result appendString:@")]"];
                        }
                            break;
                        
                    case 3:
                        [result appendString:escaped];
                        break;
                }
                
                [escaped release];
            }
            
            [currentColor release];
            
            pos = effectiveRange.location + effectiveRange.length;
        }
#ifdef PARASPLIT
    }
#endif
    
    switch (showType) {
        case 0:
            [result appendString:@"%cn"];
            break;
            
        case 1:                    
            [result appendString:@"%xn"];
            break;
            
    }
    
    return [result autorelease];;
}

- (void) doConversion:(id) sender
{
    NSString *converted = [self editorAsMUSHText];
    NSMutableString *mutString = [[_rdSourceView textStorage] mutableString];
    if (converted) {
        [mutString setString:converted];
    }
    else {
        [mutString setString:@""];
    }
    
    
    
    [_rdSourceView setFont:_rdFont];
    [_rdSourceView setNeedsDisplay:YES];
}

@end
