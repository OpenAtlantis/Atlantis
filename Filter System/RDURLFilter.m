//
//  RDURLFilter.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDURLFilter.h"

static NSString *s_eightSpaces = @"        ";

@implementation RDURLFilter

- (NSString *) shrinkURL:(NSString *)input
{
    NSString *escaped = [(NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  (CFStringRef)input, NULL,  CFSTR(":/?=&+#"), kCFStringEncodingUTF8) autorelease];	
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@", escaped]];
    NSData *data = [url resourceDataUsingCache:YES];
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    return result;
}
- (void) filterOutput:(id) output
{
    BOOL autoshrink = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.input.urlAutoshrink"];
    int urllength = [[[NSUserDefaults standardUserDefaults] objectForKey:@"atlantis.input.urlMaxLen"] intValue]; 

    if ([output isKindOfClass:[NSMutableString class]] && autoshrink) {

        NSMutableString *finalString = (NSMutableString *)output;
        NSMutableCharacterSet *urlTerminatorSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
        [urlTerminatorSet addCharactersInString:@"<>(\"')|\u2018\u2019\u201b\u201c\u201d\u201e\u201f"];
                
        NSRange foundUrlRange;
        NSRange searchRange;
        NSString *searchString = finalString;
        searchRange = NSMakeRange(0,[searchString length]);
        do 
        {
            NSRange foundRanges[4];
            foundUrlRange.length = 0;
            foundUrlRange.location = [searchString length];

            foundRanges[0] = [searchString rangeOfString:@"://" options:0 range:searchRange];
            foundRanges[1] = [searchString rangeOfString:@"www." options:0 range:searchRange];

            int loop;
            for (loop = 0; loop < 2; loop++) {
                if (foundRanges[loop].length) {
                    if (loop == 0) {
                        int pos = foundRanges[0].location - 1;
                        
                        while (pos && isalpha([searchString characterAtIndex:pos]))
                            pos--;
                            
                        if (pos) {
                            foundRanges[0].length += (foundRanges[0].location - (pos + 1));
                            foundRanges[0].location = pos + 1;
                        }
                        else {
                            foundRanges[0].length += foundRanges[0].location;
                            foundRanges[0].location = 0;
                        }
                    }
                
                    if (foundRanges[loop].location < foundUrlRange.location) {
                        foundUrlRange = foundRanges[loop];
                    }
                }
            }
            
            if (foundUrlRange.length > 0) {
                NSRange endOfUrlRange;
                
                searchRange.location = foundUrlRange.location + foundUrlRange.length;
                searchRange.length = [searchString length] - searchRange.location;
                
                endOfUrlRange = [searchString rangeOfCharacterFromSet:urlTerminatorSet options:0 range:searchRange];
                if (endOfUrlRange.length == 0) 
                    endOfUrlRange.location = [searchString length] - 1;
                
                foundUrlRange.length = endOfUrlRange.location - foundUrlRange.location;
                
                NSString *url = [searchString substringWithRange:foundUrlRange];
                BOOL isComplete = NO;
                NSRange testRange = [url rangeOfString:@"://" options:0 range:NSMakeRange(0,[url length])];
                if (testRange.length)
                    isComplete = YES;
                    
                NSMutableString *realURL = nil;

                if (isComplete) {
                    realURL = [url mutableCopy];
                }
                else {
                    realURL = [[NSString stringWithFormat:@"http://%@", url] mutableCopy];
                }
                
                if ([realURL length]) {
                    unichar testChar = [realURL characterAtIndex:[realURL length] - 1];
                    while ((testChar != '/') && [realURL length] && ![[NSCharacterSet alphanumericCharacterSet] characterIsMember:testChar]) {
                        foundUrlRange.length--;
                        [realURL deleteCharactersInRange:NSMakeRange([realURL length] - 1, 1)];
                        testChar = [realURL characterAtIndex:[realURL length] - 1];
                    }
                }
                
                if (![realURL isEqualToString:@"http://www"] && ([realURL length] >= urllength)) {
                    NSString *tinyURL = [self shrinkURL:realURL];
                    [finalString replaceCharactersInRange:foundUrlRange withString:tinyURL];
                    foundUrlRange.length = [tinyURL length];
                }
                
                [realURL release];
                searchRange.location = foundUrlRange.location + foundUrlRange.length;
                searchRange.length = [finalString length] - searchRange.location;
            }
            
        } while (foundUrlRange.length != 0);
        
        [urlTerminatorSet release];        
    }
}

- (void) filterInput:(id) input
{
    if ([input isKindOfClass:[NSMutableAttributedString class]]) {

        NSMutableAttributedString *finalString = (NSMutableAttributedString *)input;
        NSMutableCharacterSet *urlTerminatorSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
        [urlTerminatorSet addCharactersInString:@"<>(\"')|\u2018\u2019\u201b\u201c\u201d\u201e\u201f"];
                
        NSRange foundUrlRange;
        NSRange searchRange;
        NSString *searchString = [finalString string];
        searchRange = NSMakeRange(0,[searchString length]);
        do 
        {
            NSRange foundRanges[4];
            foundUrlRange.length = 0;
            foundUrlRange.location = [searchString length];

            foundRanges[0] = [searchString rangeOfString:@"://" options:0 range:searchRange];
            foundRanges[1] = [searchString rangeOfString:@"www." options:0 range:searchRange];
            foundRanges[2] = [searchString rangeOfString:@"mailto:" options:0 range:searchRange];
            foundRanges[3] = [searchString rangeOfString:@"telnet:" options:0 range:searchRange];

            int loop;
            for (loop = 0; loop < 4; loop++) {
                if (foundRanges[loop].length) {
                    if (loop == 0) {
                        NSRange tempRange = NSMakeRange(0,foundRanges[0].location);                        
                        NSRange checkRange = [searchString rangeOfCharacterFromSet:urlTerminatorSet options:NSBackwardsSearch range:tempRange];
                        
                        if (checkRange.length) {
                            foundRanges[0].length += (foundRanges[0].location - (checkRange.location + checkRange.length));
                            foundRanges[0].location = checkRange.location + checkRange.length;
                        }
                        else {
                            foundRanges[0].length += foundRanges[0].location;
                            foundRanges[0].location = 0;
                        }
                    }
                
                    if (foundRanges[loop].location < foundUrlRange.location) {
                        foundUrlRange = foundRanges[loop];
                    }
                }
            }
            
            if (foundUrlRange.length > 0) {
                NSURL *newURL = nil;
                NSRange endOfUrlRange;
                
                searchRange.location = foundUrlRange.location + foundUrlRange.length;
                searchRange.length = [searchString length] - searchRange.location;
                
                endOfUrlRange = [searchString rangeOfCharacterFromSet:urlTerminatorSet options:0 range:searchRange];
                if (endOfUrlRange.length == 0) 
                    endOfUrlRange.location = [searchString length] - 1;
                
                foundUrlRange.length = endOfUrlRange.location - foundUrlRange.location;
                
                NSString *url = [searchString substringWithRange:foundUrlRange];
                BOOL isComplete = NO;
                NSRange testRange = [url rangeOfString:@"://" options:0 range:NSMakeRange(0,[url length])];
                if (testRange.length)
                    isComplete = YES;
                    
                testRange = [url rangeOfString:@"mailto:" options:0 range:NSMakeRange(0,[url length])];
                if (testRange.length)
                    isComplete = YES;                    

                testRange = [url rangeOfString:@"telnet:" options:0 range:NSMakeRange(0,[url length])];
                if (testRange.length)
                    isComplete = YES;                    

                NSMutableString *realURL = nil;

                if (isComplete) {
                    realURL = [url mutableCopy];
                }
                else {
                    realURL = [[NSString stringWithFormat:@"http://%@", url] mutableCopy];
                }
                
                if ([realURL length]) {
                    unichar testChar = [realURL characterAtIndex:[realURL length] - 1];
                    while ((testChar != '/') && [realURL length] && ![[NSCharacterSet alphanumericCharacterSet] characterIsMember:testChar]) {
                        foundUrlRange.length--;
                        [realURL deleteCharactersInRange:NSMakeRange([realURL length] - 1, 1)];
                        testChar = [realURL characterAtIndex:[realURL length] - 1];
                    }
                }
                
                if (![realURL isEqualToString:@"http://www"])
                    newURL = [NSURL URLWithString:realURL];
                
                if (newURL) {
                    NSURL *appUrl;
                    
                    OSStatus result = LSGetApplicationForURL((CFURLRef)newURL,kLSRolesAll,NULL,(CFURLRef *)&appUrl);
                    
                    if (result != kLSApplicationNotFoundErr) {
                        [finalString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                            newURL,NSLinkAttributeName,
                            [NSCursor pointingHandCursor],NSCursorAttributeName,
                            nil]
                            range:foundUrlRange];                    
                    }
                }
            }
            
        } while (foundUrlRange.length != 0);
        
        [urlTerminatorSet release];

        /* Do tab cleanup, argh */
        NSMutableString *finalTweak = [finalString mutableString];
        
        unsigned int position = 0;
        NSString *tempString;
        NSRange tabRange = [finalTweak rangeOfString:@"\t" options:0 range:NSMakeRange(position,[finalTweak length] - position)];
        while (tabRange.length) {
            int modEight =  8 - (tabRange.location % 8);
            
            tempString = [s_eightSpaces substringWithRange:NSMakeRange(0,modEight)];            
            
            [finalTweak replaceCharactersInRange:tabRange withString:tempString];
            position = tabRange.location + modEight;
            tabRange = [finalTweak rangeOfString:@"\t" options:0 range:NSMakeRange(position,[finalTweak length] - position)];
        }
    }
}

@end
