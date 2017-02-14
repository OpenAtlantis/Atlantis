//
//  RDHTMLLog.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDHTMLLog.h"
#import "AtlantisState.h"
#import "NSStringExtensions.h"
#import "RDAtlantisWorldInstance.h"

@implementation RDHTMLLog

+ (NSString *) logtypeName
{
    // TODO: Localize
    return @"HTML";
}

+ (BOOL) canAppendToLog
{
    return NO;
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
    return @"HTML";
}

- (NSDictionary *) defaultOptions
{
    NSDictionary *myDict;
    
    myDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"log.html.defaults"];
    
    if (!myDict) {
        myDict = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES],@"css",
            [NSNumber numberWithBool:YES],@"nbspSpace",
            nil];
    }
    
    return myDict;
}

- (NSDictionary *) currentConfigurationState
{
    BOOL cssEnabled = ([_rdCssEnabled state] == NSOnState);
    BOOL nbspEnabled = ([_rdNbspSpaceEnabled state] == NSOnState);
    BOOL headerEnabled = ([_rdHeaderEnabled state] == NSOnState);
    BOOL footerEnabled = ([_rdFooterEnabled state] == NSOnState);
    BOOL titleEnabled = ([_rdTitleEnabled state] == NSOnState);
    
    NSString *cssFilename = [_rdCssFilename stringValue];
    NSString *titleString = [_rdTitle stringValue];
    NSString *headerData = [[_rdHeaderData textStorage] string];
    NSString *footerData = [[_rdFooterData textStorage] string];

    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithBool:cssEnabled],@"css",
                    cssFilename,@"cssFile",
                    [NSNumber numberWithBool:nbspEnabled],@"nbspSpace",
                    [NSNumber numberWithBool:headerEnabled],@"headerEnabled",
                    headerData,@"headerData",
                    [NSNumber numberWithBool:footerEnabled],@"footerEnabled",
                    footerData,@"footerData",
                    [NSNumber numberWithBool:titleEnabled],@"titleEnabled",
                    titleString,@"title",
                    nil];
                    
    return result;
}

- (NSDictionary *) configureOptions:(NSDictionary *)oldOptions
{
    if (!_rdConfigWindow) {
        [NSBundle loadNibNamed:@"LogConf_HTML" owner:self];
    }

    [_rdCssEnabled setState:NSOffState];
    [_rdCssFilename setEnabled:NO];
    [_rdNbspSpaceEnabled setState:NSOffState];
    [_rdHeaderEnabled setState:NSOffState];
    [_rdHeaderData setEditable:NO];
    [_rdHeaderEnabled setState:NSOffState];
    [_rdHeaderData setEditable:NO];
    [_rdTitleEnabled setState:NSOffState];
    [_rdTitle setEnabled:NO];
    
    
    NSDictionary *realOptions = oldOptions;
    
    if (!realOptions) {
        realOptions = [self defaultOptions]; 
    }

    NSNumber *css = [realOptions objectForKey:@"css"];
    if (css) {
        if ([css boolValue]) {
            [_rdCssEnabled setState:NSOnState];
            [_rdCssFilename setEnabled:YES];
        }
    }
    NSNumber *nbsp = [realOptions objectForKey:@"nbspSpace"];
    if (nbsp) {
        if ([nbsp boolValue]) {
            [_rdNbspSpaceEnabled setState:NSOnState];
        }
    }
    NSNumber *headerEnabled = [realOptions objectForKey:@"headerEnabled"];
    if (headerEnabled) {
        if ([headerEnabled boolValue]) {
            [_rdHeaderEnabled setState:NSOnState];
            [_rdHeaderData setEditable:YES];
        }
    }
    NSNumber *footerEnabled = [realOptions objectForKey:@"footerEnabled"];
    if (footerEnabled) {
        if ([footerEnabled boolValue]) {
            [_rdFooterEnabled setState:NSOnState];
            [_rdFooterData setEditable:YES];
        }
    }
    NSNumber *titleEnabled = [realOptions objectForKey:@"titleEnabled"];
    if (titleEnabled) {
        if ([titleEnabled boolValue]) {
            [_rdTitleEnabled setState:NSOnState];
            [_rdTitle setEnabled:YES];
        }
    }

    
    NSString *cssFilename = [realOptions objectForKey:@"cssFile"];
    if (cssFilename) {
        [_rdCssFilename setStringValue:cssFilename];
    }
    else {
        [_rdCssFilename setStringValue:@""];
    }
    NSString *title = [realOptions objectForKey:@"title"];
    if (title) {
        [_rdTitle setStringValue:title];
    }
    else {
        [_rdTitle setStringValue:@""];
    }
    
    NSString *headerData = [realOptions objectForKey:@"headerData"];
    if (headerData) {
        [[_rdHeaderData textStorage] replaceCharactersInRange:NSMakeRange(0,[[_rdHeaderData textStorage] length]) withString:headerData];
    }

    NSString *footerData = [realOptions objectForKey:@"footerData"];
    if (footerData) {
        [[_rdFooterData textStorage] replaceCharactersInRange:NSMakeRange(0,[[_rdFooterData textStorage] length]) withString:footerData];
    }
    
    int result = [NSApp runModalForWindow:_rdConfigWindow];
    
    NSDictionary *results = oldOptions;
    
    if (result == 1) {      
        results = [self currentConfigurationState];
    }
    
    [_rdConfigWindow orderOut:self];
    
    return results;
}

- (void) okButton:(id) sender
{
    [NSApp stopModalWithCode:1];
}

- (void) cancelButton:(id) sender
{
    [NSApp stopModalWithCode:0];
}

- (void) cssToggled:(id) sender
{
    if ([_rdCssEnabled state] == NSOnState) {
        [_rdCssFilename setEnabled:YES];
    }
    else {
        [_rdCssFilename setEnabled:NO];
    }
}

- (void) titleToggled:(id) sender
{
    if ([_rdTitleEnabled state] == NSOnState) {
        [_rdTitle setEnabled:YES];
    }
    else {
        [_rdTitle setEnabled:NO];
    }
}

- (void) headerToggled:(id) sender
{
    if ([_rdHeaderEnabled state] == NSOnState) {
        [_rdHeaderData setEditable:YES];
    }
    else {
        [_rdHeaderData setEditable:NO];
    }
}

- (void) footerToggled:(id) sender
{
    if ([_rdFooterEnabled state] == NSOnState) {
        [_rdFooterData setEditable:YES];
    }
    else {
        [_rdFooterData setEditable:NO];
    }
}


- (void) makeDefaults:(id) sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[self currentConfigurationState] forKey:@"log.html.defaults"];    
}

- (BOOL) useCSS
{
    if ([self options]) {
        NSNumber *css = [[self options] objectForKey:@"css"];
        if (css)
            return [css boolValue];
        else
            return YES;
    }
    
    return YES;
}


- (NSString *) webCode:(NSColor *)color
{
    NSColor *tempColor = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];

    int red = [tempColor redComponent] * 255.0;
    int green = [tempColor greenComponent] * 255.0;
    int blue = [tempColor blueComponent] * 255.0;
    
    return [NSString stringWithFormat:@"#%02X%02X%02X",red,green,blue];
}

- (NSString *) headerData
{
    NSString *result;

    if ([self options]) {
        NSNumber *headerEnabled = [[self options] objectForKey:@"headerEnabled"];
        if (headerEnabled && ![headerEnabled boolValue])
            return nil;

        result = [[self options] objectForKey:@"headerData"];
    }
    
    return result;
}

- (NSString *) footerData
{
    NSString *result;

    if ([self options]) {
        NSNumber *footerEnabled = [[self options] objectForKey:@"footerEnabled"];
        if (footerEnabled && ![footerEnabled boolValue])
            return nil;

        result = [[self options] objectForKey:@"footerData"];
    }
    
    return result;
}


- (NSString *) cssFile
{
    if ([self options]) {
        NSString *cssFile = [[self options] objectForKey:@"cssFile"];
        if (cssFile && [cssFile length]) {
            NSDictionary *stateOptions = [[self world] baseStateInfo];
            NSString *result = [cssFile expandWithDataIn:stateOptions];
            return result;
        }
    }
    
    NSMutableString *tempString = [[[self filename] lastPathComponent] mutableCopy];
    NSString *extension = [[self filename] pathExtension];
    if (extension) {
        unsigned length = [tempString length];
        [tempString replaceCharactersInRange:NSMakeRange(length - [extension length],[extension length]) withString:@"css"];
    }
    else
        [tempString appendString:@".css"];
    [tempString autorelease];
    
    return [NSString stringWithString:tempString];    
}

- (BOOL) openFile 
{
    if ([super openFile]) {
        NSString *gameName = [[self world] preferenceForKey:@"atlantis.world.name"];
        NSString *characterName = [[self world] preferenceForKey:@"atlantis.world.character"];
        
        NSString *friendlyName = nil;
        NSDictionary *stateOptions = [[self world] baseStateInfo];
        
        if (gameName && characterName) {
            friendlyName = [NSString stringWithFormat:@"%@ on %@", characterName, gameName];
        }
        else if (!characterName && gameName) {
            friendlyName = gameName;
        }
        
        NSString *version = [[NSBundle mainBundle] localizedStringForKey:@"CFBundleShortVersionString" value:@"" table:@"InfoPlist"];
        NSString *atlantisVersion = [NSString stringWithFormat:@"Atlantis %@", version];

        if ([self useCSS]) {
            NSMutableString *cssFilename = [[[self filename] mutableCopy] autorelease];
            NSString *bareFilename = [[self filename] lastPathComponent];
            [cssFilename replaceCharactersInRange:NSMakeRange([cssFilename length] - [bareFilename length],[bareFilename length]) withString:@""];
            [cssFilename appendString:[self cssFile]];

            NSFileManager *fileman = [NSFileManager defaultManager];
            BOOL isDirectory = NO;
            BOOL fileExists = [fileman fileExistsAtPath:cssFilename isDirectory:&isDirectory];
            if (fileExists && isDirectory) {
                [super closeFile];
                return NO;
            }
            
            if (!fileExists) {
                if (![fileman createFileAtPath:cssFilename contents:[NSData data] attributes:nil]) {
                    [super closeFile];
                    return NO;
                }
                
                NSFileHandle *css = [NSFileHandle fileHandleForWritingAtPath:cssFilename];
                NSString *tempstring;
                
                tempstring = [NSString stringWithFormat:@"/* Stylesheet for %@\n *\n", friendlyName];
                 [css writeData:[tempstring dataUsingEncoding:NSUTF8StringEncoding]];
                 tempstring = [NSString stringWithFormat:@" * Generated by %@\n * http://www.riverdark.net/atlantis/\n */\n\n", atlantisVersion];
                 [css writeData:[tempstring dataUsingEncoding:NSUTF8StringEncoding]];
                 
                 NSColor *tempColor;
                 NSColor *consoleColor;
                 NSArray *ansiColors = [[self world] preferenceForKey:@"atlantis.colors.ansi"];
                 NSColor *bgColor = [[self world] preferenceForKey:@"atlantis.colors.background"];
                 
                 tempColor = [ansiColors objectAtIndex:7];
                 consoleColor = [[self world] preferenceForKey:@"atlantis.colors.system"];
                 if (!consoleColor)
                    consoleColor = [NSColor yellowColor];
                 
                 tempstring = [NSString stringWithFormat:@"body\n{\n  color: %@;\n  background-color: %@;\n}\n\n", [self webCode:tempColor], [self webCode:bgColor] ];
                 [css writeData:[tempstring dataUsingEncoding:NSUTF8StringEncoding]];
                 
                 tempstring = [NSString stringWithFormat:@"a \n{\n  color: %@;\n  text-decoration: underline;\n}\n\n", [self webCode:[[self world] preferenceForKey:@"atlantis.colors.url"]]];
                 [css writeData:[tempstring dataUsingEncoding:NSUTF8StringEncoding]];                 
                 
                 tempstring = [NSString stringWithFormat:@".timestamp\n{\n  color: %@;\n}\n\n", [self webCode:consoleColor]];
                 [css writeData:[tempstring dataUsingEncoding:NSUTF8StringEncoding]];
                 
                 tempstring = [NSString stringWithFormat:@".versionFooter\n{\n  margin-top: 0.5em;\n  color: %@;\n  font-family: Helvetica Neue, Arial, sans-serif;\n  font-size: 0.8em;\n  font-style: italic;\n  text-align: right;\n  border-top: 1px solid %@;\n}\n\n",
                     [self webCode:tempColor], [self webCode:tempColor]];
                 [css writeData:[tempstring dataUsingEncoding:NSUTF8StringEncoding]];
                 
                 NSFont *font = [[self world] displayFont];
                 tempstring = [NSString stringWithFormat:@".mushText\n{\n  font-family: %@, Courier, fixed;\n  font-size: %fpt;\n  white-space: pre-wrap;\n}\n\n", [font displayName], [font pointSize]];
                 [css writeData:[tempstring dataUsingEncoding:NSUTF8StringEncoding]];
                 
                 int loop;
                 for (loop = 0; loop < 16; loop++) {
                     tempColor = [ansiColors objectAtIndex:loop];
                     tempstring = [NSString stringWithFormat:@".fg%02d\n{\n  color: %@;\n}\n\n",
                         loop, [self webCode:tempColor]];
                     [css writeData:[tempstring dataUsingEncoding:NSUTF8StringEncoding]];
                     
                     tempstring = [NSString stringWithFormat:@".bg%02d\n{\n  background-color: %@;\n}\n\n",
                         loop, [self webCode:tempColor]];
                     [css writeData:[tempstring dataUsingEncoding:NSUTF8StringEncoding]];
                 }
                 
                 [css closeFile];
            }
        }
        
        [self writeStringToFile:@"<?xml version=\"1.0\" encoding=\"UTF-8\">\n"];
        [self writeStringToFile:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n"];
        [self writeStringToFile:@"<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"];
        [self writeStringToFile:@"<head>\n"];
        [self writeStringToFile:@"  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\n"];
        NSString *title = [[self options] objectForKey:@"title"];
        if (title && [title length]) {
            [self writeStringToFile:[NSString stringWithFormat:@"  <title>%@</title>\n", [title expandWithDataIn:stateOptions]]];
        }
        else {
            [self writeStringToFile:[NSString stringWithFormat:@"  <title>%@ (%@)</title>\n", friendlyName, [[NSDate date] description]]];
        }
        [self writeStringToFile:[NSString stringWithFormat:@"  <meta name=\"Generator\" content=\"%@\" />\n", atlantisVersion]];
        if ([self useCSS]) {
            [self writeStringToFile:[NSString stringWithFormat:@"  <link rel=\"stylesheet\" type=\"text/css\" href=\"%@\" />\n", [self cssFile]]];
        }
        [self writeStringToFile:@"</head>\n"];
        if ([self useCSS]) {
            [self writeStringToFile:@"<body>\n"];
        }
        else {
            [self writeStringToFile:@"<body style='background-color: #000000;'>\n"];
        }
        
        NSString *header = [self headerData];
        if (header) {
            NSString *expanded = [header expandWithDataIn:stateOptions];
            [self writeStringToFile:@"\n  <!-- Begin user-defined header. -->\n"];
            [self writeStringToFile:expanded];
            [self writeStringToFile:@"\n  <!-- End user-defined header. -->\n\n"];                
        }
        
        if ([self useCSS]) {
            [self writeStringToFile:@"  <div class='log'>\n"];
        }        
        
        return YES;
    }
    return NO;
}

- (BOOL) closeFile
{
    if ([self isOpen]) {
        NSString *version = [[NSBundle mainBundle] localizedStringForKey:@"CFBundleShortVersionString" value:@"" table:@"InfoPlist"];
        NSString *atlantisVersion = [NSString stringWithFormat:@"Atlantis %@", version];
        
        if ([self useCSS]) {
            [self writeStringToFile:[NSString stringWithFormat:@"    <div class=\"versionFooter\">Logfile generated by <a href=\"http://www.riverdark.net/atlantis/\">%@</a></div>\n", atlantisVersion]];
            [self writeStringToFile:@"  </div>\n"];
        }
        else
            [self writeStringToFile:[NSString stringWithFormat:@"  <div style='margin-top: 0.5em; border-top: 1px solid gray; text-align: right; font-family: Helvetica Neue, Arial, sans-serif; font-style: italic; color: #FFFFFF;'>Logfile generated by <a href=\"http://www.riverdark.net/atlantis/\">%@</a></div>\n", atlantisVersion]];

        NSString *footer = [self footerData];
        if (footer) {
            NSDictionary *stateOptions = [[self world] baseStateInfo];
            NSString *expanded = [footer expandWithDataIn:stateOptions];
            [self writeStringToFile:@"  <!-- Begin user-defined footer. -->\n\n"];
            [self writeStringToFile:expanded];
            [self writeStringToFile:@"\n\n  <!-- End user-defined footer. -->\n"];                
        }
        
        [self writeStringToFile:@"</body>\n</html>\n"];
    }
    return [super closeFile];
}


- (NSString *) htmlString:(NSAttributedString *)mainString css:(BOOL) useCSS
{
    NSMutableString *result = [NSMutableString string];
    NSColor *currentFG = [NSColor colorWithCalibratedRed:1.0f green:1.0f blue:0.0f alpha:1.0f];
    NSColor *currentBG = [NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    
    unsigned long pos = 0;
    
    if ([self writeTimestamps]) {
        NSRange effectiveRange;
        NSDictionary *attrs;
        
        if ([mainString length])
            attrs = [mainString attributesAtIndex:0 effectiveRange:&effectiveRange];
        NSDate *timestamp = [attrs objectForKey:@"RDTimeStamp"];
        if (timestamp) {
            if (!useCSS) {
                NSColor *consoleColor = [[self world] preferenceForKey:@"atlantis.colors.system"];
                if (!consoleColor)
                    consoleColor = [NSColor yellowColor];
                [result appendFormat:@"<span style='color: %@'>", [self webCode:consoleColor]];
            }
            else {
                [result appendString:@"<span class='timestamp'>"];
            }
            [result appendFormat:@"%@</span>",
                [timestamp descriptionWithCalendarFormat:@"[%H:%M:%S] " timeZone:nil locale:nil]];
        }
    }
        
    while (pos < [mainString length]) {
        NSRange effectiveRange;
        NSDictionary *attrs;
        
        attrs = [mainString attributesAtIndex:pos effectiveRange:&effectiveRange];
        
        if (attrs) {
            NSMutableString *wholeBlock = [NSMutableString string];
            NSMutableString *spanBlock = [NSMutableString string];
            
            if (!useCSS) {
                NSColor *newFG = [attrs objectForKey:NSForegroundColorAttributeName];
                NSColor *newBG = [attrs objectForKey:NSBackgroundColorAttributeName];
                
                if (!newFG) {
                    newFG = [NSColor colorWithCalibratedRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
                }
                if (!newBG) {
                    newBG = [NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:1.0f];            
                }
                
                if (![[self webCode:newFG] isEqualToString:[self webCode:currentFG]]) {
                    [spanBlock appendString:[NSString stringWithFormat:@"color: %@; ", [self webCode:newFG]]];
                    currentFG = newFG;
                }
                
                if (![[self webCode:newBG] isEqualToString:[self webCode:currentBG]]) {
                    [spanBlock appendString:[NSString stringWithFormat:@"background-color: %@; ", [self webCode:newBG]]];
                    currentBG = newBG;
                }
            }
            else {
                NSNumber *ansiFg = [attrs objectForKey:@"RDAnsiForegroundColor"];
                NSNumber *ansiBg = [attrs objectForKey:@"RDAnsiBackgroundColor"];
                
                if (ansiFg && ([ansiFg intValue] != -1)) {
                    [spanBlock appendString:[NSString stringWithFormat:@"fg%02d ",[ansiFg intValue]]];
                }
                if (ansiBg && ([ansiBg intValue] != -1)) {
                    [spanBlock appendString:[NSString stringWithFormat:@"bg%02d ",[ansiBg intValue]]];
                }
            }
            
            if ([spanBlock length]) {
                if (useCSS) {
                    [result appendString:@"<span class='"];
                    [result appendString:spanBlock];
                    [result appendString:@"'>"];
                }
                else {
                    [result appendString:@"<span style='"];
                    [result appendString:spanBlock];
                    [result appendString:@"'>"];                    
                }
            }
            
            NSString *link = [attrs objectForKey:NSLinkAttributeName];
            
            NSMutableString *textblock = [[[mainString string] substringWithRange:NSMakeRange(pos,effectiveRange.length)] mutableCopy];
            
            [textblock replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
//            [textblock replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@"\r" withString:@"<BR/>" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@"\n" withString:@"<BR/>" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x201c] withString:@"&#8220;"
                                          options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x201d] withString:@"&#8221;"
                                          options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x2018] withString:@"&#8216;"
                                          options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x2019] withString:@"&#8217;"
                                          options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
                                                      

            NSNumber *nbsp = [[self options] objectForKey:@"nbspSpace"];
            if (nbsp && [nbsp boolValue]) {
                unsigned pos = 0;
                BOOL inSpace = NO;
                
                while (pos < [textblock length]) {
                    if ([textblock characterAtIndex:pos] == ' ') {
                        if (inSpace || (pos == 0)) {
                            [textblock replaceCharactersInRange:NSMakeRange(pos,1) withString:@"&nbsp;"];
                            pos += 5;
                        } 
                        inSpace = YES;
                    }
                    else {
                        inSpace = NO;
                    }
                    pos++;
                }
            }
            
            if (link) {
                textblock = [[NSString stringWithFormat:@"<a href=\"%@\">%@</a>", link, textblock] retain];
            }
            [result appendString:wholeBlock];
            [result appendString:textblock];
            if ([spanBlock length])
                [result appendString:@"</span>"];
                
            [textblock release];
        }
        else {
            NSMutableString *textblock = [[[mainString string] substringWithRange:NSMakeRange(pos,effectiveRange.length)] mutableCopy];
            
            [textblock replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
//            [textblock replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@"\r" withString:@"<BR/>" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:@"\n" withString:@"<BR/>" options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x201c] withString:@"&#8220;"
                                          options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x201d] withString:@"&#8221;"
                                          options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x2018] withString:@"&#8216;"
                                          options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];
            [textblock replaceOccurrencesOfString:[NSString stringWithFormat:@"%c", 0x2019] withString:@"&#8217;"
                                          options:NSLiteralSearch range:NSMakeRange(0, [textblock length])];

            NSNumber *nbsp = [[self options] objectForKey:@"nbspSpace"];
            if (nbsp && [nbsp boolValue]) {
                unsigned pos = 0;
                BOOL inSpace = NO;
                
                while (pos < [textblock length]) {
                    if ([textblock characterAtIndex:pos] == ' ') {
                        if (inSpace || (pos == 0)) {
                            [textblock replaceCharactersInRange:NSMakeRange(pos,1) withString:@"&nbsp;"];
                            pos += 5;
                        }
                        inSpace = YES;
                    }
                    else {
                        inSpace = NO;
                    }
                    pos++;
                }
            }

            [result appendString:textblock];
            [textblock release];
        }            
        
        if (effectiveRange.length)
            pos += effectiveRange.length;
        else
            pos++;
    }
    
    return [NSString stringWithString:result];
}


- (void) writeString:(NSAttributedString *)string withState:(AtlantisState *)state
{
    NSAttributedString *realString = string;

    NSString *customClass = nil;

    // If this line is marked 'omit from logs,' we, well, omit it from logs.
    if ([[string string] length]) {
        NSRange effRange;
        NSDictionary *attrs = [string attributesAtIndex:0 effectiveRange:&effRange];
        if ([attrs objectForKey:@"RDLogOmitLine"])
            return;
        customClass = [attrs objectForKey:@"RDLineClass"];

        if ([customClass isEqualToString:@"mushText"])
            customClass = nil;

        if ([[string string] characterAtIndex:[string length] - 1] == '\n') {
            realString = [string attributedSubstringFromRange:NSMakeRange(0,[string length] - 1)];
        }
    }
    
    if (![realString length]) 
    {
        if ([self useCSS]) {
            [self writeStringToFile:@"    <div class='mushText'>&nbsp;</div>\n"];
        }
        else {
            NSFont *font = [[state world] displayFont];
            NSString *fontString = [NSString stringWithFormat:
                                  @"  <div style='font-family: %@, Courier, fixed; font-size: %fpt; white-space: pre-wrap;'>&nbsp;</div>",
                [font displayName], [font pointSize]];
            [self writeStringToFile:fontString];
        }
        return;
    }

    NSMutableString *newString = [[self htmlString:realString css:[self useCSS]] mutableCopy];    
    
    if ([self useCSS]) {
        if (customClass)
            [newString insertString:[NSString stringWithFormat:@"    <div class='mushText %@'>",customClass] atIndex:0];
        else
            [newString insertString:@"    <div class='mushText'>" atIndex:0];
        [newString appendString:@"</div>\n"];
    }
    else {
        NSFont *font = [[state world] displayFont];
        NSString *fontString = [NSString stringWithFormat:
            @"  <div style='font-family: %@, Courier, fixed; font-size: %fpt; white-space: pre-wrap;'>",
            [font displayName], [font pointSize]];
   
        [newString insertString:fontString atIndex:0];
        [newString appendString:@"</div>\n"];    
    }
    
    [self writeStringToFile:newString];
    [newString release];
}



@end
