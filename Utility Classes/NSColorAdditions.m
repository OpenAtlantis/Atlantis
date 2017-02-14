//
//  NSColorAdditions.m
//  Atlantis
//
//  Created by Rachel Blackman on 5/31/08.
//  Copyright 2008 Riverdark Studios. All rights reserved.
//

#import "NSColorAdditions.h"
#import "NSStringExtensions.h"

@implementation NSColor (RDColorAdditions)

+ (NSColor *) colorWithWebCode:(NSString *)webCode
{
    unsigned pos = 0;
    
    if ([webCode characterAtIndex:0] == '#') {
        pos = 1;
    }
    
    NSString *red = [[webCode substringWithRange:NSMakeRange(pos,2)] uppercaseString];
    NSString *green = [[webCode substringWithRange:NSMakeRange(pos + 2,2)] uppercaseString];
    NSString *blue = [[webCode substringWithRange:NSMakeRange(pos + 4,2)] uppercaseString];
    
    float redVal = (float)[red intValueFromHex] / 255.0f;
    float greenVal = (float)[green intValueFromHex] / 255.0f;
    float blueVal = (float)[blue intValueFromHex] / 255.0f;
    
    return [NSColor colorWithCalibratedRed:redVal green:greenVal blue:blueVal alpha:1.0f];
}

- (NSString *) webCode
{
    int red = [self redComponent] * 255.0;
    int green = [self greenComponent] * 255.0;
    int blue = [self blueComponent] * 255.0;
    
    if ([self isEqualTo:[NSColor clearColor]]) {
        return [NSString stringWithString:@"ffffff"];
    }
    
    return [NSString stringWithFormat:@"%02X%02X%02X",red,green,blue];
}

@end
