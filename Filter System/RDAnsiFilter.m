//
//  RDAnsiFilter.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/11/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDAnsiFilter.h"
#import "RDAtlantisMainController.h"
#import "NSColorAdditions.h"

static NSMutableArray *s_extendedColors = nil;

@implementation RDAnsiState

+ (void) initialize
{
	if (!s_extendedColors) {
		s_extendedColors = [[NSMutableArray alloc] init];
        int loop1, loop2, loop3;

		NSArray *points = [NSArray arrayWithObjects:@"00",@"5f",@"87",@"af",@"d7",@"ff",nil];
		for (loop1 = 0; loop1 < [points count]; loop1++) {
			for (loop2 = 0; loop2 < [points count]; loop2++) {
				for (loop3 = 0; loop3 < [points count]; loop3++) {
					NSString *colorString = [NSString stringWithFormat:@"%@%@%@",
											 [points objectAtIndex:loop1],
											 [points objectAtIndex:loop2],
											 [points objectAtIndex:loop3]];
					
					[s_extendedColors addObject:[NSColor colorWithWebCode:colorString]];
				}
			}
		}
		
        int colorLoop;
        
		for (colorLoop = 0; colorLoop < 24; colorLoop++) {
			NSString *colorString = [NSString stringWithFormat:@"%02X%02X%02X",
									 (colorLoop * 10) + 8, (colorLoop * 10) + 8, (colorLoop * 10) + 8];
			
			[s_extendedColors addObject:[NSColor colorWithWebCode:colorString]];
		}
	}
}

- (id) init
{
    _rdAnsiBoldMe = NO;
    _rdAnsiInvertMe = NO;
    _rdAnsiUnderlineMe = NO;
    
    _rdAnsiLastColor = 7;
    _rdAnsiLastBackground = -1;
    
    _rdHoldover = nil;
    _rdFont = [[NSFont userFixedPitchFontOfSize:10.0f] retain];
    _rdFontBold = [[[NSFontManager sharedFontManager] convertFont:_rdFont toHaveTrait:NSBoldFontMask] retain];
    _rdBoldOnIntense = NO;
    
    _rdBackground = [[NSColor blackColor] retain];
    _rdDefaultColor = [[NSColor colorWithCalibratedRed:0.8f green:0.8f blue:0.8f alpha:1.0f] retain];
    
    _rdCurrentAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:_rdFont,NSFontAttributeName,_rdBackground,NSBackgroundColorAttributeName,_rdDefaultColor,NSForegroundColorAttributeName,nil];    
    
    return self;
}

- (void) dealloc
{
    [_rdCurrentAttributes release];
    [_rdParaStyle release];
    [_rdFontBold release];
    [_rdFont release];
    [_rdColors release];
    [_rdBackground release];
    [super dealloc];
}

- (BOOL) bold
{
    return _rdAnsiBoldMe;
}

- (BOOL) invert
{
    return _rdAnsiInvertMe;
}

- (BOOL) underline
{
    return _rdAnsiUnderlineMe;
}

- (int) lastColor
{
    return _rdAnsiLastColor;
}

- (int) lastBackground
{
    return _rdAnsiLastBackground;
}

- (NSAttributedString *) holdover
{
    return _rdHoldover;
}

- (void) setBold:(BOOL)bold
{
    _rdAnsiBoldMe = bold;
    
    if ((_rdAnsiLastColor != -1) && (_rdAnsiLastColor > [_rdColors count]))
        return;
    
    int effFg = _rdAnsiLastColor + (((_rdAnsiLastColor != -1) && (_rdAnsiLastColor < 8)) ? (_rdAnsiBoldMe ? 8 : 0) : 0);
    NSColor *fgColor = nil;

    if (_rdAnsiLastColor == -1) {
        if (_rdAnsiBoldMe) {
            fgColor = [_rdColors objectAtIndex:15];
            effFg = 15;
        }
        else {
            fgColor = _rdDefaultColor;
        }
    }
     else if (effFg < [_rdColors count])
        fgColor = [_rdColors objectAtIndex:effFg];

    if (fgColor)
        [_rdCurrentAttributes setObject:fgColor forKey:(_rdAnsiInvertMe ? NSBackgroundColorAttributeName : NSForegroundColorAttributeName)];

    if ((effFg != -1) && (effFg < [_rdColors count]))
        [_rdCurrentAttributes setObject:[NSNumber numberWithInt:effFg] forKey:(_rdAnsiInvertMe ? @"RDAnsiBackgroundColor" : @"RDAnsiForegroundColor")];
    else
        [_rdCurrentAttributes removeObjectForKey:(_rdAnsiInvertMe ? @"RDAnsiBackgroundColor" : @"RDAnsiForegroundColor")];
        
    if (_rdBoldOnIntense)
        [_rdCurrentAttributes setObject:(_rdAnsiBoldMe ? _rdFontBold : _rdFont) forKey:NSFontAttributeName];
}

- (void) setInvert:(BOOL)invert
{
    _rdAnsiInvertMe = invert;

    NSColor *fgColor;
    NSColor *bgColor;
    
    int effFg = _rdAnsiLastColor + (((_rdAnsiLastColor != -1) && (_rdAnsiLastColor < 8)) ? (_rdAnsiBoldMe ? 8 : 0) : 0);
    int effBg = _rdAnsiLastBackground;

    if (_rdAnsiLastColor == -1) {
        if (_rdAnsiBoldMe) {
            fgColor = [_rdColors objectAtIndex:15];
            effFg = 15;
        }
        else {
            fgColor = _rdDefaultColor;
        }
    }
    else if (effFg < [_rdColors count]) {
        fgColor = [_rdColors objectAtIndex:effFg];
    }
    else {
        int tempFg = effFg - 16;
        
        fgColor = [s_extendedColors objectAtIndex:tempFg];
    }

    if (_rdAnsiLastBackground == -1)
        bgColor = _rdBackground;
    else if (effBg < [_rdColors count]) {
        bgColor = [_rdColors objectAtIndex:effBg];
    }
    else {
        int tempBg = effBg - 16;
        
        bgColor = [s_extendedColors objectAtIndex:tempBg];
    }

    if ((effFg != -1) && (effFg < [_rdColors count]))
        [_rdCurrentAttributes setObject:[NSNumber numberWithInt:effFg] forKey:(_rdAnsiInvertMe ? @"RDAnsiBackgroundColor" : @"RDAnsiForegroundColor")];
    else
        [_rdCurrentAttributes removeObjectForKey:(_rdAnsiInvertMe ? @"RDAnsiBackgroundColor" : @"RDAnsiForegroundColor")];

    if ((effBg != -1) && (effBg < [_rdColors count]))
        [_rdCurrentAttributes setObject:[NSNumber numberWithInt:effBg] forKey:(_rdAnsiInvertMe ? @"RDAnsiForegroundColor" : @"RDAnsiBackgroundColor")];
    else
        [_rdCurrentAttributes removeObjectForKey:(_rdAnsiInvertMe ? NSForegroundColorAttributeName : NSBackgroundColorAttributeName)];

    if (fgColor)
        [_rdCurrentAttributes setObject:fgColor forKey:(_rdAnsiInvertMe ? NSBackgroundColorAttributeName : NSForegroundColorAttributeName)];
    if (bgColor)
        [_rdCurrentAttributes setObject:bgColor forKey:(_rdAnsiInvertMe ? NSForegroundColorAttributeName : NSBackgroundColorAttributeName)];
}

- (void) setUnderline:(BOOL)underline
{
    _rdAnsiUnderlineMe = underline;

    int underlineStyle = NSNoUnderlineStyle;
    
    if (_rdAnsiUnderlineMe) {
        underlineStyle = NSSingleUnderlineStyle;
    }
    
    [_rdCurrentAttributes setObject:[NSNumber numberWithInt:underlineStyle] forKey:NSUnderlineStyleAttributeName];
}

- (void) setColor:(int)color
{
    _rdAnsiLastColor = color;
    
    int effFg = _rdAnsiLastColor + (((_rdAnsiLastColor != -1) && (_rdAnsiLastColor < 8)) ? (_rdAnsiBoldMe ? 8 : 0) : 0);
    NSColor *fgColor = nil;

    if (_rdAnsiLastColor == -1) {
        if (_rdAnsiBoldMe) {
            fgColor = [_rdColors objectAtIndex:15];
            effFg = 15;
        }
        else {
            fgColor = _rdDefaultColor;
        }
    }
	else if (effFg < [_rdColors count]) {
        fgColor = [_rdColors objectAtIndex:effFg];
	}
	else {
		int tempFg = effFg - 16;
		
		if (tempFg < [s_extendedColors count])
			fgColor = [s_extendedColors objectAtIndex:tempFg];
	}

    if ((effFg != -1) && (effFg < 16))
        [_rdCurrentAttributes setObject:[NSNumber numberWithInt:effFg] forKey:(_rdAnsiInvertMe ? @"RDAnsiBackgroundColor" : @"RDAnsiForegroundColor")];
    else
        [_rdCurrentAttributes removeObjectForKey:(_rdAnsiInvertMe ? @"RDAnsiBackgroundColor" : @"RDAnsiForegroundColor")];

    if (fgColor)
        [_rdCurrentAttributes setObject:fgColor forKey:(_rdAnsiInvertMe ? NSBackgroundColorAttributeName : NSForegroundColorAttributeName)];
}

- (void) setBackground:(int)background
{
    _rdAnsiLastBackground = background;

    NSColor *bgColor = nil;

    if (_rdAnsiLastBackground == -1)
        bgColor = _rdBackground;
    else if (_rdAnsiLastBackground < [_rdColors count])
        bgColor = [_rdColors objectAtIndex:_rdAnsiLastBackground];
	else {
		int tempBg = _rdAnsiLastBackground - 16;
		
		if (tempBg < [s_extendedColors count])
			bgColor = [s_extendedColors objectAtIndex:tempBg];
	}
	
    if ((_rdAnsiLastBackground != -1) && (_rdAnsiLastBackground < 16))
        [_rdCurrentAttributes setObject:[NSNumber numberWithInt:_rdAnsiLastBackground] forKey:(_rdAnsiInvertMe ? @"RDAnsiForegroundColor" : @"RDAnsiBackgroundColor")];
    else 
        [_rdCurrentAttributes removeObjectForKey:(_rdAnsiInvertMe ? @"RDAnsiForegroundColor" : @"RDAnsiBackgroundColor")];

    if (bgColor)
        [_rdCurrentAttributes setObject:bgColor forKey:(_rdAnsiInvertMe ? NSForegroundColorAttributeName : NSBackgroundColorAttributeName)];
	else 
        [_rdCurrentAttributes removeObjectForKey:(_rdAnsiInvertMe ? NSForegroundColorAttributeName : NSBackgroundColorAttributeName)];
}

- (void) setHoldover:(NSAttributedString *)string
{
    if (_rdHoldover) {
        [_rdHoldover release];
        _rdHoldover = nil;
    }
    
    if (string) {
        _rdHoldover = string;
        [_rdHoldover retain];
    }
}

- (void) reset
{
    _rdAnsiLastBackground = -1;
    _rdAnsiLastColor = -1;
    _rdAnsiBoldMe = NO;
    _rdAnsiInvertMe = NO;
    _rdAnsiUnderlineMe = NO;

    [_rdCurrentAttributes release];
    _rdCurrentAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSDate date],@"RDTimeStamp",_rdFont,NSFontAttributeName,_rdBackground,NSBackgroundColorAttributeName,_rdDefaultColor,NSForegroundColorAttributeName,_rdParaStyle,NSParagraphStyleAttributeName,nil];        
}

- (void) setColorArray:(NSArray *) colors
{
    if (colors) {
        if (_rdColors) {
            [_rdColors release];
            _rdColors = nil;
        }
        
        _rdColors = [colors retain];
    }
}

- (void) setDocumentBackground:(NSColor *) background
{
    if (background) {
        [_rdBackground release];
        _rdBackground = [background retain];
    }
}

- (void) setDocumentDefault:(NSColor *) defaultColor
{
    if (defaultColor) {
        [_rdDefaultColor release];
        _rdDefaultColor = [defaultColor retain];
    }
}

- (void) setParagraphStyle:(NSParagraphStyle *)paraStyle
{
    [_rdCurrentAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];
    [_rdParaStyle release];
    _rdParaStyle = [paraStyle retain];
}

- (void) setFont:(NSFont *) font
{
    if (font && (!_rdFont || ![font isEqualTo:_rdFont])) {
        [_rdFont release];
        _rdFont = [font retain];
        
        [_rdFontBold release];
        _rdFontBold = [[[NSFontManager sharedFontManager] convertFont:_rdFont toHaveTrait:NSBoldFontMask] retain];        
    }
}

- (void) setBoldOnIntense:(BOOL) bOnIntense
{
    _rdBoldOnIntense = bOnIntense;
}

- (void) setTimestamp:(NSDate *)timestamp
{
    [_rdCurrentAttributes setObject:timestamp forKey:@"RDTimeStamp"];
}

- (void) applyToString:(NSMutableAttributedString *)string withRange:(NSRange)range
{
/*    NSColor *fgColor;
    NSColor *bgColor;
    
    int effFg = _rdAnsiLastColor + (((_rdAnsiLastColor != -1) && (_rdAnsiLastColor < 8)) ? (_rdAnsiBoldMe ? 8 : 0) : 0);
    int effBg = _rdAnsiLastBackground;

    if (_rdAnsiLastColor == -1) {
        if (_rdAnsiBoldMe) {
            fgColor = [_rdColors objectAtIndex:15];
            effFg = 15;
        }
        else {
            fgColor = _rdDefaultColor;
        }
    }
     else 
        fgColor = [_rdColors objectAtIndex:effFg];

    if (_rdAnsiLastBackground == -1)
        bgColor = _rdBackground;
    else
        bgColor = [_rdColors objectAtIndex:_rdAnsiLastBackground];


    NSDictionary *attrs;
    NSFont *font = _rdFont;
    
    if (_rdAnsiBoldMe && _rdBoldOnIntense) {
        font = _rdFontBold;
    }
    
    int underlineStyle = NSNoUnderlineStyle;
    
    if (_rdAnsiUnderlineMe) {
        underlineStyle = NSSingleUnderlineStyle;
    }
        
    attrs = [NSDictionary dictionaryWithObjectsAndKeys:
        font,NSFontAttributeName,
        fgColor,(_rdAnsiInvertMe ? NSBackgroundColorAttributeName : NSForegroundColorAttributeName),
        bgColor,(_rdAnsiInvertMe ? NSForegroundColorAttributeName : NSBackgroundColorAttributeName),
        [NSNumber numberWithInt:effFg],(_rdAnsiInvertMe ? @"RDAnsiBackgroundColor" : @"RDAnsiForegroundColor"),
        [NSNumber numberWithInt:effBg],(_rdAnsiInvertMe ? @"RDAnsiForegroundColor" : @"RDAnsiBackgroundColor"),
        [NSNumber numberWithInt:underlineStyle],NSUnderlineStyleAttributeName,nil];
    [string setAttributes:attrs range:range];    */
    
    [_rdCurrentAttributes setObject:[NSDate date] forKey:@"RDTimeStamp"];    
    [string setAttributes:_rdCurrentAttributes range:range];
}

- (NSDictionary *) attributes
{
    return _rdCurrentAttributes;
}

@end


@implementation RDAnsiFilter

- (id) initWithWorld:(RDAtlantisWorldInstance *)world
{
    self = [super initWithWorld:world];
    if (self) {
        _rdState = [[RDAnsiState alloc] init];
        [_rdState setColorArray:[world preferenceForKey:@"atlantis.colors.ansi"]];
        [_rdState setParagraphStyle:[world paragraphStyle]];
        NSColor *tempColor = [world preferenceForKey:@"atlantis.colors.background"];
        if (tempColor)        
            [_rdState setDocumentBackground:tempColor];

        tempColor = [world preferenceForKey:@"atlantis.colors.default"];
        if (tempColor)        
            [_rdState setDocumentDefault:tempColor];
            
        NSFont *font = [world preferenceForKey:@"atlantis.formatting.font"];
        if (font) 
            [_rdState setFont:font];
        NSNumber *boldTest = [[self world] preferenceForKey:@"atlantis.formatting.boldIntense"];
        if (boldTest) {
            [_rdState setBoldOnIntense:[boldTest boolValue]];
        }
        else {
            boldTest = [[[RDAtlantisMainController controller] globalWorld] preferenceForKey:@"atlantis.formatting.boldIntense" withCharacter:nil];
            if (boldTest)
                [_rdState setBoldOnIntense:[boldTest boolValue]];
            else
                [_rdState setBoldOnIntense:NO];
        }
            
        [_rdState reset];
    }
    return self;
}

- (void) dealloc
{
    [_rdState release];
    [super dealloc];
}

- (void) worldWasRefreshed
{
    [_rdState setColorArray:[[self world] preferenceForKey:@"atlantis.colors.ansi"]];
    [_rdState setParagraphStyle:[[self world] paragraphStyle]];
    NSColor *tempColor = [[self world] preferenceForKey:@"atlantis.colors.background"];
    if (tempColor)        
        [_rdState setDocumentBackground:tempColor];
    tempColor = [[self world] preferenceForKey:@"atlantis.colors.default"];
    if (tempColor)        
        [_rdState setDocumentDefault:tempColor];
    NSFont *font = [[self world] preferenceForKey:@"atlantis.formatting.font"];
    if (font)
        [_rdState setFont:font];
    NSNumber *boldTest = [[self world] preferenceForKey:@"atlantis.formatting.boldIntense"];
    if (boldTest) {
        [_rdState setBoldOnIntense:[boldTest boolValue]];
    }
    else {
        boldTest = [[[RDAtlantisMainController controller] globalWorld] preferenceForKey:@"atlantis.formatting.boldIntense" withCharacter:nil];
        if (boldTest)
            [_rdState setBoldOnIntense:[boldTest boolValue]];
        else
            [_rdState setBoldOnIntense:NO];
    }
    NSNumber *beepTest = [[self world] preferenceForKey:@"atlantis.formatting.beep"];
    if (beepTest) {
        _rdBeepBehavior = [beepTest intValue];
    }
    else {
        _rdBeepBehavior = 0;
    }
}

/*
- (void) filterInput:(id) input
{
    if ([input isKindOfClass:[NSMutableAttributedString class]]) {
        NSMutableAttributedString *string = (NSMutableAttributedString *)input;
        
        // Grab any leftover unterminated ANSI codes?
        if ([_rdState holdover]) {
            [string insertAttributedString:[_rdState holdover] atIndex:0];
            [_rdState setHoldover:nil];
        }
        
        int lastPosition = 0;
        NSString *tempString = [string string];
        int length = [tempString length];
        
        [_rdState applyToString:string withRange:NSMakeRange(0,length)];

        NSRange foundRange = [tempString rangeOfString:@"\x07" options:0 range:NSMakeRange(0,[tempString length])];
        if (foundRange.length) {
            switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"atlantis.beeptype"]) {
                case 0: // Do nothing
                    break;
                case 1: // Show status
                    [[self world] outputStatus:@"Beep!" toSpawn:@""];
                    break;
                case 2: // System beep
                    NSBeep();
                    break;
            }
        }
        
        foundRange = [tempString rangeOfString:@"\x1b[" options:0 range:NSMakeRange(lastPosition,length - lastPosition)];
        if (!foundRange.length)
            foundRange = [tempString rangeOfString:@"\x1b\n[" options:0 range:NSMakeRange(lastPosition, length - lastPosition)];
        if (!foundRange.length)
            foundRange = [tempString rangeOfString:@"\x1b\n" options:0 range:NSMakeRange(lastPosition, length - lastPosition)];
        if (!foundRange.length)
            foundRange = [tempString rangeOfString:@"\x1b" options:0 range:NSMakeRange(lastPosition, length - lastPosition)];
        
        while (foundRange.length) {
            int escbegin = foundRange.location + foundRange.length;
            NSRange finishRange = NSMakeRange(escbegin,length - escbegin);
            NSRange endRange = [tempString rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet] options:0 range:finishRange];
            
            if (!endRange.length) {
                // unterminated ANSI!  Aiie!
                NSRange eatMe = NSMakeRange(foundRange.location, length - foundRange.location);
                NSAttributedString *holdover = [string attributedSubstringFromRange:eatMe];
                // Munch these from our existing string, having stored them as holdover
                [string replaceCharactersInRange:eatMe withString:@""];
                [_rdState setHoldover:holdover];
                return;
            }
            
            NSString *escTerminator = [tempString substringWithRange:endRange];
            
            // ANSI color sequence
            if ([escTerminator isEqualToString:@"m"]) {
                NSString *ansiSequence = [tempString substringWithRange:NSMakeRange(escbegin,endRange.location - escbegin)];
                
                NSArray *ansicodes = [ansiSequence componentsSeparatedByString:@";"];
                NSEnumerator *ansiEnum = [ansicodes objectEnumerator];
                
                id walkobj;
                while (walkobj = [ansiEnum nextObject]) {
                    int code = [(NSString *)walkobj intValue];
                    
                    // Get ANSI sequence category
                    switch (code / 10) {
                        
                        case 0: // ANSI attribute set
                        case 2: // ANSI attribute clear
                        {
                            BOOL toggle = ((code / 10) == 0);
                            
                            switch (code % 10) {
                                case 0: // ANSI reset
                                    [_rdState reset];
                                    break;
                                    
                                case 1: // ANSI bold on / off
                                    [_rdState setBold:toggle];
                                    break;
                                    
                                case 3: // ANSI italics on / off
                                    break;
                                    
                                case 4: // ANSI underline on /off
                                    [_rdState setUnderline:toggle];
                                    break;
                                    
                                case 7: // ANSI inverse on / off
                                    [_rdState setInvert:toggle];
                                    break;
                            }
                        }
                            break;
                            
                        case 3: // ANSI foreground color
                            if (code < 38)
                                [_rdState setColor:(code - 30)];
                            else if (code == 39) {
                                [_rdState setColor:-1];
                                [_rdState setBold:FALSE];
                            }
                            else if (code == 38) {
                                // 256-color support
                                NSString *nextObj = [ansiEnum nextObject];
                                if ([nextObj isEqualToString:@"5"]) {
                                    nextObj = [ansiEnum nextObject];
                                    NSLog([NSString stringWithFormat:@"Got unsupported 256-color fg: %@", nextObj]);                                                                        
                                }
                            }
                            break;
                            
                        case 4: // ANSI background color
                            if (code < 48) 
                                [_rdState setBackground:(code - 40)];
                            else if (code == 49)
                                [_rdState setBackground:-1];
                            else if (code == 48) {
                                // 256-color support
                                NSString *nextObj = [ansiEnum nextObject];
                                if ([nextObj isEqualToString:@"5"]) {
                                    nextObj = [ansiEnum nextObject];
                                    NSLog([NSString stringWithFormat:@"Got unsupported 256-color bg: %@", nextObj]);                                                                        
                                }
                            }
                            break;
                            
                        case 9: // ANSI extended foreground
                            [_rdState setColor:((code - 90) + 8)];
                            break;
                            
                        case 10:
                            [_rdState setBackground:((code - 100) + 8)];
                            break;
                    }
                }
            }
            
            [_rdState applyToString:string withRange:finishRange];
            [string replaceCharactersInRange:NSMakeRange(foundRange.location,1 + (endRange.location - foundRange.location)) withString:@""];
            
            lastPosition = foundRange.location;
            
            tempString = [string string];
            length = [tempString length];
            foundRange = [tempString rangeOfString:@"\x1b[" options:0 range:NSMakeRange(lastPosition,length - lastPosition)];
            if (!foundRange.length)
                foundRange = [tempString rangeOfString:@"\x1b\n[" options:0 range:NSMakeRange(lastPosition, length - lastPosition)];
            if (!foundRange.length)
                foundRange = [tempString rangeOfString:@"\x1b\n" options:0 range:NSMakeRange(lastPosition, length - lastPosition)];
            if (!foundRange.length)
                foundRange = [tempString rangeOfString:@"\x1b" options:0 range:NSMakeRange(lastPosition, length - lastPosition)];
        }
    }    
}
*/

- (void) filterInput:(id) input
{
    if ([input isKindOfClass:[NSMutableAttributedString class]]) {
        NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[_rdState attributes]];
        NSMutableAttributedString *string = [(NSMutableAttributedString *)input mutableCopy];
        
        NSCharacterSet *linefeedSet = [[NSCharacterSet characterSetWithCharactersInString:@"\n\r"] retain];
        
        // Grab any leftover unterminated ANSI codes?
        if ([_rdState holdover]) {
            [string insertAttributedString:[_rdState holdover] atIndex:0];
            [_rdState setHoldover:nil];
        }
        [_rdState setTimestamp:[NSDate date]];
        
        int lastPosition = 0;
        NSString *tempString = [string string];
        int length = [tempString length];
        
        NSRange foundRange = [tempString rangeOfString:@"\x07" options:0 range:NSMakeRange(0,[tempString length])];
        if (foundRange.length) {
            switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"atlantis.beeptype"]) {
                case 0: // Do nothing
                    break;
                case 1: // Show status
                    [[self world] outputStatus:@"Beep!" toSpawn:@""];
                    break;
                case 2: // System beep
                    NSBeep();
                    break;
            }
        }
        
        NSRange testRange = NSMakeRange(lastPosition,length - lastPosition);
        foundRange = [tempString rangeOfString:@"\x1b[" options:0 range:testRange];
        if (!foundRange.length)
            foundRange = [tempString rangeOfString:@"\x1b\n[" options:0 range:testRange];
        if (!foundRange.length)
            foundRange = [tempString rangeOfString:@"\x1b\n" options:0 range:testRange];
        if (!foundRange.length)
            foundRange = [tempString rangeOfString:@"\x1b" options:0 range:testRange];
        
        while (foundRange.length) {
            int escbegin = foundRange.location + foundRange.length;
            NSRange finishRange = NSMakeRange(escbegin,length - escbegin);
            NSRange endRange = [tempString rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet] options:0 range:finishRange];
            
            if (!endRange.length) {
                // unterminated ANSI!  Aiie!
                NSRange eatMe = NSMakeRange(foundRange.location, length - foundRange.location);
                NSAttributedString *holdover = [string attributedSubstringFromRange:eatMe];
                // Munch these from our existing string, having stored them as holdover
//                [string replaceCharactersInRange:eatMe withString:@""];
                [_rdState setHoldover:holdover];
                [string release];
                [(NSMutableAttributedString *)input setAttributedString:result];
                [result release];
                return;
            }

            NSRange realRange = NSMakeRange(lastPosition,foundRange.location - lastPosition);
            if (realRange.length && (realRange.location != NSNotFound))
                [result appendAttributedString:[[[NSAttributedString alloc] initWithString:[tempString substringWithRange:realRange] attributes:[_rdState attributes]] autorelease]];            

            lastPosition = endRange.location + endRange.length;
            
            
            NSString *escTerminator = [tempString substringWithRange:endRange];
            
            // ANSI color sequence
            if ([escTerminator isEqualToString:@"m"]) {
                NSString *ansiSequence = [tempString substringWithRange:NSMakeRange(escbegin,endRange.location - escbegin)];
                
                NSArray *ansicodes = [ansiSequence componentsSeparatedByString:@";"];
                NSEnumerator *ansiEnum = [ansicodes objectEnumerator];
                
                id walkobj;
                while (walkobj = [ansiEnum nextObject]) {
                    int code = [(NSString *)walkobj intValue];
                    
                    // Get ANSI sequence category
                    switch (code / 10) {
                        
                        case 0: // ANSI attribute set
                        case 2: // ANSI attribute clear
                        {
                            BOOL toggle = ((code / 10) == 0);
                            
                            switch (code % 10) {
                                case 0: // ANSI reset
                                    [_rdState reset];
                                    break;
                                    
                                case 1: // ANSI bold on / off
                                    [_rdState setBold:toggle];
                                    break;
                                    
                                case 3: // ANSI italics on / off
                                    break;
                                    
                                case 4: // ANSI underline on /off
                                    [_rdState setUnderline:toggle];
                                    break;
                                    
                                case 7: // ANSI inverse on / off
                                    [_rdState setInvert:toggle];
                                    break;
                            }
                        }
                            break;
                            
                        case 3: // ANSI foreground color
                            if (code < 38)
                                [_rdState setColor:(code - 30)];
                            else if (code == 39) {
                                [_rdState setColor:-1];
                                [_rdState setBold:FALSE];
                            }
                            else if (code == 38) {
                                // 256-color support
                                NSString *nextObj = [ansiEnum nextObject];
                                if ([nextObj isEqualToString:@"5"]) {
                                    nextObj = [ansiEnum nextObject];
									[_rdState setColor:[nextObj intValue]];
                                }
                            }
                            break;
                            
                        case 4: // ANSI background color
                            if (code < 48) 
                                [_rdState setBackground:(code - 40)];
                            else if (code == 49)
                                [_rdState setBackground:-1];
                            else if (code == 48) {
                                // 256-color support
                                NSString *nextObj = [ansiEnum nextObject];
                                if ([nextObj isEqualToString:@"5"]) {
                                    nextObj = [ansiEnum nextObject];
									[_rdState setBackground:[nextObj intValue]];
                                }
                            }
                            break;
                            
                        case 9: // ANSI extended foreground
                            [_rdState setColor:((code - 90) + 8)];
                            break;
                            
                        case 10:
                            [_rdState setBackground:((code - 100) + 8)];
                            break;
                    }
                }
            }
            else if ([escTerminator isEqualToString:@"a"]) {
                // Atlantis private escape sequences
                NSString *ansiSequence = [tempString substringWithRange:NSMakeRange(escbegin,endRange.location - escbegin)];
                
                NSArray *ansicodes = [ansiSequence componentsSeparatedByString:@";"];
                NSEnumerator *ansiEnum = [ansicodes objectEnumerator];
                
                id walkobj;
                while (walkobj = [ansiEnum nextObject]) {
                    int code = [walkobj intValue];
                    switch (code) {
                        case 1:
                            {
                                // MUD prompt marker
                                NSRange lineMarker = [[result string] rangeOfCharacterFromSet:linefeedSet options:NSBackwardsSearch];
                                if (lineMarker.location == NSNotFound) {
                                    lineMarker = NSMakeRange(0,[result length]);
                                }
                                else {
                                    lineMarker.length = [result length] - lineMarker.location;
                                }
                                [result addAttribute:@"RDPromptMarker" value:@"yes" range:lineMarker];
                            }
                            break;                            
                    }
                }
            }
            
            testRange = NSMakeRange(lastPosition,length - lastPosition);
            foundRange = [tempString rangeOfString:@"\x1b[" options:0 range:testRange];
            if (!foundRange.length)
                foundRange = [tempString rangeOfString:@"\x1b\n[" options:0 range:testRange];
            if (!foundRange.length)
                foundRange = [tempString rangeOfString:@"\x1b\n" options:0 range:testRange];
            if (!foundRange.length)
                foundRange = [tempString rangeOfString:@"\x1b" options:0 range:testRange];
        }
        
        NSRange closingRange = NSMakeRange(lastPosition,[string length] - lastPosition);
        if (closingRange.length)
            [result appendAttributedString:[[[NSAttributedString alloc] initWithString:[tempString substringWithRange:closingRange] attributes:[_rdState attributes]] autorelease]];            

        [string release];
        [(NSMutableAttributedString *)input setAttributedString:result];
        [result release];
    }    
}

@end
