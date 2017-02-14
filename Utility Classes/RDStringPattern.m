//
//  RDStringPattern.m
//  Atlantis
//
//  Created by Rachel Blackman on Thu Jul 08 2004.
//  Copyright (c) 2004 Riverdark Studios. All rights reserved.
//

#import "RDStringPattern.h"
#import <OgreKit/OgreKit.h>


@implementation RDStringPattern

+ (RDStringPattern *) patternWithString:(NSString *)pattern type:(int)type
{
    RDStringPattern *result = [[RDStringPattern alloc] init];
    
    if (!pattern) {
        NSLog(@"nil string error #003");
    }
    result->_rdPattern = [[NSString stringWithString:pattern] retain];
    result->_rdPatternType = type;
    result->_rdMatchMe = nil;
    
    [result autorelease];
    
    return result;
}

- (int) type
{
    return _rdPatternType;
}

- (NSString *) pattern
{
    return _rdPattern;
}

- (BOOL) patternMatchesString:(NSString *)match
{
    NSRange result = NSMakeRange(0,0);
    
    switch (_rdPatternType)
    {
        case RDPatternBeginsWith:
        {
            if ([match length] >= [_rdPattern length]) {
                if ([[match substringToIndex:[_rdPattern length]] isEqualToString:_rdPattern]) {
                    result.location = 0;
                    result.length = [_rdPattern length];
                }
            }
        }
            break;
            
        case RDPatternIs:
        {
            if ([match isEqualToString:_rdPattern])
                return YES;
        }
            break;
        
        case RDPatternContains:
        {
            result = [match rangeOfString:_rdPattern];
        }
            break;
            
        case RDPatternRegexp:
        {
            @try {
                result = [match rangeOfRegularExpressionString:_rdPattern];
            }
            @catch (NSException *e) {
                return NO;
            }
        }
            break;
    }
    
    return (result.length != 0);
}

- (BOOL) stringContainsPattern:(NSString *)match
{
    NSRange result = NSMakeRange(0,0);
    
    switch (_rdPatternType)
    {
        case RDPatternBeginsWith:
        {
            if ([match length] >= [_rdPattern length]) {
                if ([[match substringToIndex:[_rdPattern length]] isEqualToString:_rdPattern]) {
                    result.location = 0;
                    result.length = [_rdPattern length];
                }
            }
        }
            break;
            
        case RDPatternIs:
        case RDPatternContains:
        {
            result = [match rangeOfString:_rdPattern];
        }
            break;
            
        case RDPatternRegexp:
        {
            @try {
                result = [match rangeOfRegularExpressionString:_rdPattern];
            }
            @catch (NSException *e) {
                return NO;
            }
        }
            break;
    }
    
    return (result.length != 0);
}


- (NSRange) stringMatch:(NSString *)match
{
    if (match) {
        if (_rdMatchMe) {
            [_rdMatchMe release];
            _rdMatchMe = nil;
        }
        
        _rdMatchMe = [[NSString stringWithString:match] retain];
        _rdMatchPosition = 0;
    }

    if (!_rdMatchMe) {
        return NSMakeRange(0,0);
    }
    
    NSRange result = NSMakeRange(0,0);
    
    switch (_rdPatternType)
    {
        case RDPatternBeginsWith:
        {
            if (_rdMatchPosition == 0) {
                if ([_rdMatchMe length] >= [_rdPattern length]) {
                    if ([[_rdMatchMe substringToIndex:[_rdPattern length]] isEqualToString:_rdPattern]) {
                        result.location = 0;
                        result.length = [_rdMatchMe length];
                        _rdMatchPosition = result.length;
                    }
                }
            }
        }
            break;
            
        case RDPatternContains:
        {
            if (_rdMatchPosition == 0) {
                result = [_rdMatchMe rangeOfString:_rdPattern];
                if (result.length) {
                    result = NSMakeRange(0,[match length]);
                    _rdMatchPosition = result.length;
                }
            }
        }
            break;
            
        case RDPatternIs:
        {
            NSRange checkRange = NSMakeRange(_rdMatchPosition,[_rdMatchMe length] - _rdMatchPosition);
            result = [_rdMatchMe rangeOfString:_rdPattern options:0 range:checkRange];
            if (result.length) {
                _rdMatchPosition = result.location + result.length;
            }
        }
            break;
            
        case RDPatternRegexp:
        {
            @try {
                NSRange checkRange = NSMakeRange(_rdMatchPosition,[_rdMatchMe length] - _rdMatchPosition);
                result = [_rdMatchMe rangeOfRegularExpressionString:_rdPattern options:0 range:checkRange];
                if (result.length) {
                    _rdMatchPosition = result.location + result.length;
                }
            }
            @catch (NSException *e) {
                NSLog([NSString stringWithFormat:@"Ignoring invalid regexp: %@", _rdPattern]);
                return NSMakeRange(0,0);
            }

        }
            break;
    }
    
    return result;
}

- (NSString *) description
{
    NSString *type = nil;
    
    switch (_rdPatternType)
    {
        case RDPatternBeginsWith:
            type = @"beginning with";
            break;
            
        case RDPatternIs:
            type = @"exactly matching";
            break;
            
        case RDPatternContains:
            type = @"containing";
            break;
            
        case RDPatternRegexp:
            type = @"matching regexp";
            break;
    }
    
    NSString *result = [NSString stringWithFormat:@"Strings %@ '%@'",
        type, _rdPattern];
    
    return result;
}

- (id) copyWithZone:(NSZone *)zone
{
    RDStringPattern *result = [[RDStringPattern allocWithZone:zone] init];
    
    result->_rdPattern = [[_rdPattern copyWithZone:zone] retain];
    result->_rdPatternType = _rdPatternType;
    
    return result;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:_rdPattern forKey:@"pattern"];
        [coder encodeInt:_rdPatternType forKey:@"type"];
    }
    else {
        [coder encodeValueOfObjCType:@encode(int) at:&_rdPatternType];
        [coder encodeObject:_rdPattern];
    }
}

- (id) initWithCoder:(NSCoder *)coder
{
    _rdMatchMe = nil;
    _rdMatchPosition = 0;
    
    if ([coder allowsKeyedCoding]) {
        _rdPattern = [[coder decodeObjectForKey:@"pattern"] retain];
        _rdPatternType = [coder decodeIntForKey:@"type"];
    }
    else {
        _rdPattern = [[coder decodeObject] retain];
        [coder decodeValueOfObjCType:@encode(int) at:&_rdPatternType];
    }
    
    return self;
}

@end
