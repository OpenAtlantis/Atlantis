//
//  RDFormattedText.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/14/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDFormattedText.h"
#import "RDAtlantisWorldInstance.h"
#import "AtlantisState.h"

@implementation RDFormattedText

+ (NSString *) logtypeName
{
    // TODO: Localize
    return @"Plain Text (Formatted)";
}

+ (BOOL) canAppendToLog
{
    return YES;
}

+ (BOOL) supportsOptions
{
    return YES;
}

- (id) initWithFilename:(NSString *)filename forSpawn:(NSString *)spawnPath inWorld:(RDAtlantisWorldInstance *)world withOptions:(NSDictionary *)options
{
    self = [super initWithFilename:filename forSpawn:spawnPath inWorld:world withOptions:options];
    if (self) {
            
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

+ (NSString *) shortTypeName
{
    // TODO: Localize
    return @"Formatted Text";
}

- (NSDictionary *) defaultOptions
{
    NSDictionary *myDict;
    
    myDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"log.formatted.defaults"];
    
    if (!myDict) {
        myDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt:2],@"indent",
                    [NSNumber numberWithInt:78],@"wrapchars",
                    [NSNumber numberWithBool:YES],@"skiplines",
                    [NSNumber numberWithBool:NO],@"condenselines",
                    [NSNumber numberWithBool:YES],@"wrap", nil];
    }
    
    return myDict;
}

- (NSDictionary *) configureOptions:(NSDictionary *)oldOptions
{
    if (!_rdConfigWindow) {
        [NSBundle loadNibNamed:@"LogConf_Formatted" owner:self];
    }
    
    NSDictionary *realOptions = oldOptions;
    NSNumber *indentBy = nil;
    NSNumber *wrapAt = nil;
    NSNumber *wordWrap = nil;
    NSNumber *skipLines = nil;
    NSNumber *condenseLines = nil;
    
    if (!realOptions) {
        realOptions = [self defaultOptions]; 
    }

    indentBy = [realOptions objectForKey:@"indent"];
    wrapAt = [realOptions objectForKey:@"wrapchars"];
    wordWrap = [realOptions objectForKey:@"wrap"];
    skipLines = [realOptions objectForKey:@"skiplines"];
    condenseLines = [realOptions objectForKey:@"condenselines"];
    
    if (!indentBy)
        indentBy = [NSNumber numberWithInt:2];
    if (!wrapAt)
        wrapAt = [NSNumber numberWithInt:78];
    if (!wordWrap)
        wordWrap = [NSNumber numberWithBool:YES];
    if (!skipLines)
        skipLines = [NSNumber numberWithBool:YES];
    if (!condenseLines)
        condenseLines = [NSNumber numberWithBool:NO];
        
    if ([skipLines boolValue]) {
        [_rdSkipLines setState:NSOnState];
        [_rdCondenseLines setEnabled:YES];
    } 
    else {
        [_rdSkipLines setState:NSOffState];
        [_rdCondenseLines setEnabled:NO];
    }

    if ([condenseLines boolValue])
        [_rdCondenseLines setState:NSOnState];
    else
        [_rdCondenseLines setState:NSOffState];
        
    if ([wordWrap boolValue]) {
        [_rdWordWrap setState:NSOnState];
        [_rdIndentField setEnabled:YES];
        [_rdCharactersField setEnabled:YES];
    }
    else {
        [_rdWordWrap setState:NSOffState];
        [_rdIndentField setEnabled:NO];
        [_rdCharactersField setEnabled:NO];
    }
    
    [_rdIndentField setIntValue:[indentBy intValue]];
    [_rdCharactersField setIntValue:[wrapAt intValue]];
    
    int result = [NSApp runModalForWindow:_rdConfigWindow];
    
    NSDictionary *results = oldOptions;
    
    if (result == 1) {
        
        indentBy = [NSNumber numberWithInt:[_rdIndentField intValue]];
        wrapAt = [NSNumber numberWithInt:[_rdCharactersField intValue]];
        wordWrap = [NSNumber numberWithBool:([_rdWordWrap state] == NSOnState)];
        skipLines = [NSNumber numberWithBool:([_rdSkipLines state] == NSOnState)];
        condenseLines = [NSNumber numberWithBool:([_rdCondenseLines state] == NSOnState)];

        results = 
            [NSDictionary dictionaryWithObjectsAndKeys:
                indentBy,@"indent",
                wrapAt,@"wrapchars",
                wordWrap,@"wrap",
                skipLines,@"skiplines", 
                condenseLines,@"condenselines",
                nil];
    }
    
    [_rdConfigWindow orderOut:self];
    
    return results;
}

- (void) wrapToggled:(id) sender
{
    if ([_rdWordWrap state] == NSOnState) {
        [_rdIndentField setEnabled:YES];
        [_rdCharactersField setEnabled:YES];    
    }
    else {
        [_rdIndentField setEnabled:NO];
        [_rdCharactersField setEnabled:NO];    
    }
}

- (void) skipToggled:(id) sender
{
    if ([_rdSkipLines state] == NSOnState) {
        [_rdCondenseLines setEnabled:YES];
    }
    else {
        [_rdCondenseLines setEnabled:NO];
    }
}


- (void) makeDefaults:(id) sender
{

    NSNumber *indentBy = nil;
    NSNumber *wrapAt = nil;
    NSNumber *wordWrap = nil;
    NSNumber *skipLines = nil;
    NSNumber *condenseLines = nil;

    indentBy = [NSNumber numberWithInt:[_rdIndentField intValue]];
    wrapAt = [NSNumber numberWithInt:[_rdCharactersField intValue]];
    wordWrap = [NSNumber numberWithBool:([_rdWordWrap state] == NSOnState)];
    skipLines = [NSNumber numberWithBool:([_rdSkipLines state] == NSOnState)];
    condenseLines = [NSNumber numberWithBool:([_rdCondenseLines state] == NSOnState)];
    
    NSDictionary *result = 
        [NSDictionary dictionaryWithObjectsAndKeys:
            indentBy,@"indent",
            wrapAt,@"wrapchars",
            wordWrap,@"wrap",
            skipLines,@"skiplines", 
            condenseLines,@"condenselines",
            nil];
            
    [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"log.formatted.defaults"];
}

- (void) okButton:(id) sender
{
    [NSApp stopModalWithCode:1];
}

- (void) cancelButton:(id) sender
{
    [NSApp stopModalWithCode:0];
}

- (BOOL) openFile 
{
    if ([super openFile]) {
        NSString *gameName = [[self world] preferenceForKey:@"atlantis.world.name"];
        NSString *characterName = [[self world] preferenceForKey:@"atlantis.world.character"];
        
        NSString *friendlyName = nil;
        
        if (gameName && characterName) {
            friendlyName = [NSString stringWithFormat:@"%@ on %@", characterName, gameName];
        }
        else if (!characterName && gameName) {
            friendlyName = gameName;
        }
        
        // TODO: Localize
        [self writeStringToFile:@"\n"];
        if (friendlyName) {
            [self writeStringToFile:[NSString stringWithFormat:@"    //// Logfile for %@\n", friendlyName]];
        }
        if ([self spawnPath]) {
            [self writeStringToFile:[NSString stringWithFormat:@"    //// Logging spawn: %@\n", [self spawnPath]]];
        }
        [self writeStringToFile:[NSString stringWithFormat:@"    //// Started at %@\n\n", [[NSDate date] description]]];
        return YES;
    }
    return NO;
}

- (BOOL) closeFile
{
    if ([self isOpen]) {
        // TODO: Localize
        [self writeStringToFile:[NSString stringWithFormat:@"    //// Closed at %@\n\n", [[NSDate date] description]]];
    }
    return [super closeFile];
}

- (void) writeString:(NSAttributedString *)string withState:(AtlantisState *)state
{
    // If this line is marked 'omit from logs,' we, well, omit it from logs.
    NSDictionary *attrs = nil;
    if ([string length]) {
        NSRange effRange;
        attrs = [string attributesAtIndex:0 effectiveRange:&effRange];
        if ([attrs objectForKey:@"RDLogOmitLine"])
            return;
    }
    else {
        // dead string aiiie
        return;
    }

    NSString *realString = [NSString stringWithString:[string string]];

    if ([realString length] && ([realString characterAtIndex:[realString length] - 1] == '\n')) {
        realString = [realString substringWithRange:NSMakeRange(0,[realString length] - 1)];
    }

    NSMutableString *newString = [[NSMutableString alloc] init];
    unsigned indent = 2;
    unsigned margin = 79;
    BOOL wordWrap = YES;
    BOOL skipLines = YES;
    BOOL condenseLines = NO;
    
    if ([self options]) {
        indent = [[[self options] objectForKey:@"indent"] intValue];
        margin = [[[self options] objectForKey:@"wrapchars"] intValue];
        wordWrap = [[[self options] objectForKey:@"wrap"] boolValue];
        skipLines = [[[self options] objectForKey:@"skiplines"] boolValue];
        condenseLines = [[[self options] objectForKey:@"condenselines"] boolValue];
    }

    if ([self writeTimestamps]) {
        NSDate *timestamp = [attrs objectForKey:@"RDTimeStamp"];
        if (timestamp) {
            [newString appendString:[timestamp descriptionWithCalendarFormat:@"[%H:%M:%S] " timeZone:nil locale:nil]];
        }
    }
    
    BOOL blankLine = NO;
    
    if (![realString length])
        blankLine = YES;
    else {
        int pos = 0;
        BOOL allBlank = YES;
        NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
        while (allBlank && (pos < [realString length])) {
            if (![charSet characterIsMember:[realString characterAtIndex:pos]]) {
                allBlank = NO;
            }
            pos++;
        }
        
        if (allBlank)
            blankLine = YES;
    }    
    

    if (blankLine) {
        if (!condenseLines && !skipLines)
            [self writeStringToFile:@"\n"];
        if (skipLines && !condenseLines)
            [self writeStringToFile:@"\n"];
        return;
    }

    if (wordWrap) {
        unsigned pos = 0;    
        unsigned firstline = 0;
        
        if ([self writeTimestamps]) {
            firstline = 11;
        }
        while (pos < [realString length]) {
            if ((pos + (pos ? (margin - indent) : (margin - firstline))) >= [realString length]) {
                NSString *tempString = [realString substringFromIndex:pos];
                if (pos) {
                    int loop;
                    for (loop = 0; loop < indent; loop++)
                        [newString appendString:@" "];
                }
                [newString appendString:tempString];
                [newString appendString:@"\n"];
                pos = [realString length];
            }
            else {
                unsigned nextMark = pos + (pos ? (margin - indent) : (margin - firstline));
                unsigned resumeAt;
                
                while ((nextMark != pos) && (nextMark < [realString length]) && !isspace([realString characterAtIndex:nextMark]))
                    nextMark--;
                
                BOOL hyphenate = NO;
                
                if (nextMark == pos) {
                    // Just give up and hyphenate.
                    nextMark = pos + (pos ? ((margin - 1) - indent) : ((margin - 1) - firstline));
                    hyphenate = YES;
                    resumeAt = pos + (pos ? (margin - indent) : (margin - firstline));
                }
                else {
                    resumeAt = nextMark;
                    while ((resumeAt < [realString length]) && isspace([realString characterAtIndex:resumeAt]))
                        resumeAt++;                
                }
                
                NSString *tempString = [realString substringWithRange:NSMakeRange(pos,nextMark - pos)];
                if (pos) {
                    int loop;
                    for (loop = 0; loop < indent; loop++)
                        [newString appendString:@" "];
                }
                [newString appendString:tempString];
                if (hyphenate)
                    [newString appendString:@"-"];
                [newString appendString:@"\n"];
                pos = resumeAt;
            }
        }
    }
    else {
        [newString appendString:realString];
        [newString appendString:@"\n"];
    }
    
    if (skipLines)
        [newString appendString:@"\n"];

    [self writeStringToFile:newString];
    [newString release];
}


@end
