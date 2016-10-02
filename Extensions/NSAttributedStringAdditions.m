//
//  NSAttributedStringAdditions.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/25/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "NSAttributedStringAdditions.h"
#import "RDAtlantisWorldInstance.h"
#import "NSColorAdditions.h"

@implementation NSAttributedString (RDAtlantisMarkup)

- (id) initWithAML:(NSString *)aml forWorld:(RDAtlantisWorldInstance *)world
{
    self = [self initWithAML:aml forWorld:world withFont:[world preferenceForKey:@"atlantis.formatting.font"] withDefaultFG:[world preferenceForKey:@"atlantis.colors.default"] withDefaultBG:[world preferenceForKey:@"atlantis.colors.background"]];
    if (self) {
    
    }
    return self;
}

- (id) initWithAML:(NSString *)aml forWorld:(RDAtlantisWorldInstance *)world withFont:(NSFont *)defaultFont withDefaultFG:(NSColor *)defaultFG withDefaultBG:(NSColor *)defaultBG
{
    if (!aml || !world)
        return nil;
        
    int currentFG = -1;
    int currentBG = -1;
    BOOL isUnderlined = NO;
    BOOL isItalic = NO;
    BOOL isBold = NO;
    NSString *link = nil;
    NSFont *italicfont;
    NSFont *boldfont;
    NSFont *bolditalicfont;
    NSArray *colors;
    NSFont *basefont;
    int pos = 0;
    
    if (defaultFont) {
        basefont = defaultFont;
    }
    else {
        basefont = [NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]];
    }
    
    colors = [world preferenceForKey:@"atlantis.colors.ansi"];

    italicfont = [[NSFontManager sharedFontManager] convertFont:basefont toHaveTrait:NSItalicFontMask];
    boldfont = [[NSFontManager sharedFontManager] convertFont:basefont toHaveTrait:NSBoldFontMask];
    bolditalicfont = [[NSFontManager sharedFontManager] convertFont:boldfont toHaveTrait:NSItalicFontMask];

    NSCharacterSet *tagBegins = [NSCharacterSet characterSetWithCharactersInString:@"<"];
    NSCharacterSet *tagEnd = [NSCharacterSet characterSetWithCharactersInString:@">"];
    
    NSMutableAttributedString *tempstring = [[NSMutableAttributedString alloc] init];
    
    NSString *lineclass = nil;
    bool omitLog = NO;
    bool omitScreen = NO;
    
    NSMutableArray *tooltips = [[NSMutableArray alloc] init];
    NSMutableDictionary *attrs = [[NSDictionary dictionary] mutableCopy];  
    
    [attrs setObject:defaultFG forKey:NSForegroundColorAttributeName];
    if (defaultBG)
        [attrs setObject:defaultBG forKey:NSBackgroundColorAttributeName];  
    [attrs setObject:basefont forKey:NSFontAttributeName];  
    
    while (pos < [aml length]) {

        NSRange searchRange = [aml rangeOfCharacterFromSet:tagBegins options:NSLiteralSearch range:NSMakeRange(pos,[aml length] - pos)];
        
        if (searchRange.length) {
            if (searchRange.location != pos) {
                NSMutableString *substring = [[NSMutableString alloc] initWithString:[aml substringWithRange:NSMakeRange(pos,searchRange.location - pos)]];
                
                [substring replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSLiteralSearch range:NSMakeRange(0,[substring length])];
                [substring replaceOccurrencesOfString:@"&apos;" withString:@"'" options:NSLiteralSearch range:NSMakeRange(0,[substring length])];
                [substring replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSLiteralSearch range:NSMakeRange(0,[substring length])];
                [substring replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSLiteralSearch range:NSMakeRange(0,[substring length])];
                [substring replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:NSMakeRange(0,[substring length])];
                
                // Apply attributes
                
                NSAttributedString *workstring = [[NSAttributedString alloc] initWithString:substring attributes:attrs];                
                [tempstring appendAttributedString:workstring]; 
                [substring release];
                [workstring release];
            }

            NSRange endmark = [aml rangeOfCharacterFromSet:tagEnd options:NSLiteralSearch range:NSMakeRange(searchRange.location,[aml length] - searchRange.location)];
            
            if (endmark.length == 0) {
                // Uhm, we're hosed; eat the rest of the string and do what we can.
                pos = [aml length];                
            }

            NSMutableString *tagblock = [[aml substringWithRange:NSMakeRange(searchRange.location + 1,endmark.location - searchRange.location - 1)] mutableCopy];
            
            BOOL negated = NO;
            
            if ([tagblock length] && ([tagblock characterAtIndex:0] == '/')) {
                [tagblock deleteCharactersInRange:NSMakeRange(0,1)];
                negated = YES;
            }

            NSArray *elements = [tagblock componentsSeparatedByString:@" "];
            
            NSString *tag = [[elements objectAtIndex:0] lowercaseString];
            if (tag) {
                if ([tag isEqualToString:@"ansi"]) {
                    currentFG = [[elements objectAtIndex:1] intValue];
                    NSColor *foregroundColor = nil;
                    if (currentFG == -1) 
                        foregroundColor = defaultFG;
                    else if (currentFG < [colors count])
                        foregroundColor = [colors objectAtIndex:currentFG];                    
                        
                    if (foregroundColor)
                        [attrs setObject:foregroundColor forKey:NSForegroundColorAttributeName];
                }
                else if ([tag isEqualToString:@"ansi_bg"]) {
                    currentBG = [[elements objectAtIndex:1] intValue];
                    NSColor *backgroundColor = nil;
                    if (currentBG == -1) 
                        backgroundColor = defaultBG;
                    else if (currentBG < [colors count])
                        backgroundColor = [colors objectAtIndex:currentBG];                    
                        
                    if (backgroundColor)
                        [attrs setObject:backgroundColor forKey:NSBackgroundColorAttributeName];
                }
                else if ([tag isEqualToString:@"color"]) {
                    NSString *colorTag = [elements objectAtIndex:1];
                    NSColor *foregroundColor = nil;
                    if ([colorTag isEqualToString:@"-1"]) {
                        foregroundColor = [colors objectAtIndex:currentFG];
                    }
                    else {
                        foregroundColor = [NSColor colorWithWebCode:colorTag];
                    }

                    if (foregroundColor)
                        [attrs setObject:foregroundColor forKey:NSForegroundColorAttributeName];
                }
                else if ([tag isEqualToString:@"bg"]) {
                    NSString *colorTag = [elements objectAtIndex:1];
                    NSColor *backgroundColor = nil;
                    if ([colorTag isEqualToString:@"-1"]) {                        
                        if (currentBG != -1)
                            backgroundColor = [colors objectAtIndex:currentBG];
                        else
                            backgroundColor = defaultBG;
                    }
                    else {
                        backgroundColor = [NSColor colorWithWebCode:colorTag];
                    }

                    if (backgroundColor)
                        [attrs setObject:backgroundColor forKey:NSBackgroundColorAttributeName];                
                }
                else if ([tag isEqualToString:@"i"]) {
                    if (isItalic == negated) {
                        isItalic = !negated;
                        NSFont *tempFont = nil;
                        if (isItalic && isBold) {
                            tempFont = bolditalicfont;
                        }
                        else if (isItalic) {
                            tempFont = italicfont;
                        }
                        else if (isBold) {
                            tempFont = boldfont;
                        }
                        else {
                            tempFont = basefont;
                        }
                        
                        if (tempFont)
                            [attrs setObject:tempFont forKey:NSFontAttributeName];
                    }
                    
                }
                else if ([tag isEqualToString:@"u"]) {
                    isUnderlined = !negated;
                    if (isUnderlined) {
                        [attrs setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
                    }
                    else {
                        [attrs removeObjectForKey:NSUnderlineStyleAttributeName];
                    }
                }
                else if ([tag isEqualToString:@"b"]) {
                    if (isBold == negated) {
                        isBold = !negated;
                        NSFont *tempFont = nil;
                        if (isItalic && isBold) {
                            tempFont = bolditalicfont;
                        }
                        else if (isItalic) {
                            tempFont = italicfont;
                        }
                        else if (isBold) {
                            tempFont = boldfont;
                        }
                        else {
                            tempFont = basefont;
                        }
                        
                        if (tempFont)
                            [attrs setObject:tempFont forKey:NSFontAttributeName];
                    }
                }
                else if ([tag isEqualToString:@"link"]) {
                    if (negated) {
                        [link release];
                        link = nil;
                        [attrs removeObjectForKey:NSLinkAttributeName];
                    }
                    else {
                        [link release];
                        link = nil;
                        NSRange whitespace = [tagblock rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
                        if (whitespace.length) {
                            link = [[tagblock substringFromIndex:(whitespace.location + whitespace.length)] retain];
                        }
                        else
                            link = nil;
                            
                        if (link)
                            [attrs setObject:link forKey:NSLinkAttributeName];
                        else
                            [attrs removeObjectForKey:NSLinkAttributeName];
                    }
                }
                else if ([tag isEqualToString:@"tooltip"]) {
                    NSRange whitespace = [tagblock rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
                    if (whitespace.length) {
                        NSMutableString *tempString = [[tagblock substringFromIndex:(whitespace.location + whitespace.length)] mutableCopy];

                        [tempString replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSLiteralSearch range:NSMakeRange(0,[tempString length])];
                        [tempString replaceOccurrencesOfString:@"&apos;" withString:@"'" options:NSLiteralSearch range:NSMakeRange(0,[tempString length])];
                        [tempString replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSLiteralSearch range:NSMakeRange(0,[tempString length])];
                        [tempString replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSLiteralSearch range:NSMakeRange(0,[tempString length])];
                        [tempString replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:NSMakeRange(0,[tempString length])];
                        
                        [tooltips addObject:[NSString stringWithString:tempString]];
                        [tempString release];
                    }
                }
                else if ([tag isEqualToString:@"class"]) {
                    NSRange whitespace = [tagblock rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
                    if (whitespace.length) {
                        NSString *tempString = [tagblock substringFromIndex:(whitespace.location + whitespace.length)];
                        lineclass = tempString;
                    }
                }
                else if ([tag isEqualToString:@"gag"]) {
                    NSRange whitespace = [tagblock rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
                    if (whitespace.length) {
                        NSString *tempString = [tagblock substringFromIndex:(whitespace.location + whitespace.length)];
                        NSArray *tempArray = [tempString componentsSeparatedByString:@" "];
                        NSEnumerator *tempEnum = [tempArray objectEnumerator];
                        NSString *tempWalk;
                        
                        while (tempWalk = [tempEnum nextObject]) {
                            if ([[tempWalk lowercaseString] isEqualToString:@"log"]) {
                                omitLog = YES;
                            }
                            else if ([[tempWalk lowercaseString] isEqualToString:@"screen"]) {
                                omitScreen = YES;
                            }
                        }
                    }
                }
            }

            [tagblock release];
            pos = endmark.location + endmark.length;
        }
        else {
            NSMutableString *substring = [[aml substringWithRange:NSMakeRange(pos,[aml length] - pos)] mutableCopy];
            
            [substring replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSLiteralSearch range:NSMakeRange(0,[substring length])];
            [substring replaceOccurrencesOfString:@"&apos;" withString:@"'" options:NSLiteralSearch range:NSMakeRange(0,[substring length])];
            [substring replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSLiteralSearch range:NSMakeRange(0,[substring length])];
            [substring replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSLiteralSearch range:NSMakeRange(0,[substring length])];
            [substring replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:NSMakeRange(0,[substring length])];
            
            NSAttributedString *workstring = [[NSAttributedString alloc] initWithString:substring attributes:attrs];                
            [tempstring appendAttributedString:workstring]; 
            [substring release];  
            [workstring release];
            pos = [aml length];      
        }
    }

    [attrs release];

    if ([tempstring length]) {
        NSMutableDictionary *finalAttrs = [[NSMutableDictionary alloc] init];
        
        if ([tooltips count]) {
            [finalAttrs setObject:tooltips forKey:@"RDTooltips"];
        }            
        [tooltips release];

        if (lineclass) {
            [finalAttrs setObject:lineclass forKey:@"RDLineClass"];
        }
        
        if (omitLog) {
            [finalAttrs setObject:@"yes" forKey:@"RDLogOmitLine"];
        }

        if (omitScreen) {
            [finalAttrs setObject:@"yes" forKey:@"RDScreenOmitLine"];
        }
        
        NSParagraphStyle *paraStyle = [world formattingParagraphStyle];
        if (paraStyle) {
            [finalAttrs setObject:paraStyle forKey:NSParagraphStyleAttributeName];
        }
        [tempstring addAttributes:finalAttrs range:NSMakeRange(0,[tempstring length])];
        [finalAttrs release];
    }
    
    [self initWithAttributedString:tempstring];
    [tempstring release];
    return self;
}


- (NSString *) stringAsAML
{
    BOOL isItalic = NO;
    BOOL isBold = NO;
    BOOL isUnderlined = NO;
    NSMutableString *result = [[NSMutableString alloc] init];
    int color = -1;
    int bg = -1;
    
    int pos = 0;
    
    if (![self length]) {
        return @"";
    }
    
    NSRange checkMe;
    NSDictionary *attrs = [self attributesAtIndex:0 effectiveRange:&checkMe];
    
    NSString *lineclass = [attrs objectForKey:@"RDLineClass"];
    if (lineclass) {
        [result appendString:[NSString stringWithFormat:@"<class %@>", lineclass]];
    }
    
    NSMutableString *omitString = [[NSMutableString alloc] init];
    
    if ([attrs objectForKey:@"RDLogOmitLine"]) {
        [omitString appendString:@"log "];
    }
    if ([attrs objectForKey:@"RDScreenOmitLine"]) {
        [omitString appendString:@"screen"];
    }
    
    if (![omitString isEqualToString:@""]) {
        [result appendString:[NSString stringWithFormat:@"<gag %@>", omitString]];
    }
    [omitString release];
    
    NSArray *tooltips = [attrs objectForKey:@"RDTooltips"];
    if (tooltips && [tooltips count]) {
        NSEnumerator *tooltipEnum = [tooltips objectEnumerator];
        NSString *walk;
        
        while (walk = [tooltipEnum nextObject]) {
            [result appendString:@"<tooltip "];
            [result appendString:walk];
            [result appendString:@">"];
        }
    }
    
    while (pos < [self length]) {
        attrs = [self attributesAtIndex:pos effectiveRange:&checkMe];
        
        if (attrs) {
            NSNumber *foreground = [attrs objectForKey:@"RDAnsiForegroundColor"];
            NSNumber *background = [attrs objectForKey:@"RDAnsiBackgroundColor"];
            
            int newFG, newBG;
            if (foreground)
                newFG = [foreground intValue];
            else
                newFG = -1;
                
            if (background)
                newBG = [background intValue];
            else
                newBG = -1;
                
            BOOL newItalic;
            BOOL newUnderline;
            BOOL newBold;
            
            NSFont *font = [attrs objectForKey:NSFontAttributeName];
            if (font) {
                NSFontTraitMask fontMask = [[NSFontManager sharedFontManager] traitsOfFont:font];
                if (fontMask & NSItalicFontMask) {
                    newItalic = YES;
                }
                else {
                    newItalic = NO;
                }

                if (fontMask & NSBoldFontMask) {
                    newBold = YES;
                }
                else {
                    newBold = NO;
                }
            }
            
            if ([[attrs objectForKey:NSUnderlineStyleAttributeName] boolValue]) {
                newUnderline = YES;
            }
            else {
                newUnderline = NO;
            }
            
            if (newFG != color) {
                [result appendString:[NSString stringWithFormat:@"<ansi %d>",newFG]];
            }
            if (newBG != bg) {
                [result appendString:[NSString stringWithFormat:@"<ansi_bg %d>",newBG]];
            }
            if (newItalic != isItalic) {
                if (newItalic)
                    [result appendString:@"<i>"];
                else
                    [result appendString:@"</i>"];
            }
            if (newBold != isBold) {
                if (newBold)
                    [result appendString:@"<b>"];
                else
                    [result appendString:@"</b>"];
            }
            if (newUnderline != isUnderlined) {
                if (newUnderline)
                    [result appendString:@"<u>"];
                else
                    [result appendString:@"</u>"];
            }

            NSString *link = [attrs objectForKey:NSLinkAttributeName];
            
            color = newFG;
            bg = newBG;
            isItalic = newItalic;
            isBold = newBold;
            isUnderlined = newUnderline;
            
            NSMutableString *textblock = [[[self string] substringWithRange:NSMakeRange(pos,checkMe.length)] mutableCopy];
            
            [textblock replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@"\r" withString:@"<BR/>" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];

            if (link) {
                textblock = [[NSString stringWithFormat:@"<link %@>%@</link>", link, textblock] retain];
            }

            [result appendString:textblock];
            [textblock release];
        }
        
        
        if (checkMe.length)
            pos += checkMe.length;
        else
            pos++;
    }
    
    return [result autorelease];
}

@end
