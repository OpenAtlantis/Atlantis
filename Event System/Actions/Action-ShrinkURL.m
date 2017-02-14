//
//  Action-ShrinkURL.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/10/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "Action-ShrinkURL.h"
#import "AtlantisState.h"
#import "RDAtlantisSpawn.h"

@implementation Action_ShrinkURL



+ (NSString *) actionName
{
    // TODO: Localize
    return @"Input: Shrink selected URL";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Shrink the selected URL using TinyURL.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

// TinyURL engine guts
- (NSString *) shrinkURL:(NSString *)input
{
    NSString *escaped = [(NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  (CFStringRef)input, NULL,  CFSTR(":/?=&+#"), kCFStringEncodingUTF8) autorelease];	
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@", escaped]];
    NSData *data = [url resourceDataUsingCache:YES];
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    return result;
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSString *inputContents = [[state spawn] stringFromInputSelection];
    if (inputContents && ([inputContents length] > 8)) {
        if ([[[inputContents substringToIndex:7] lowercaseString] isEqualToString:@"http://"] ||
            [[[inputContents substringToIndex:8] lowercaseString] isEqualToString:@"https://"]) {
            NSString *shrinky = [self shrinkURL:inputContents];
            [[state spawn] stringInsertIntoInput:shrinky];
        }
        else {
            NSBeep();
        }
    }
    else {
        NSBeep();
    }
    return NO;
}


@end
