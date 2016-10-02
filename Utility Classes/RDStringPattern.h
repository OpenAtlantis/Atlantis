//
//  RDStringPattern.h
//  Atlantis
//
//  Created by Rachel Blackman on Thu Jul 08 2004.
//  Copyright (c) 2004 Riverdark Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OgreKit/OgreKit.h>

enum {
    RDPatternBeginsWith,
    RDPatternIs,
    RDPatternContains,
    RDPatternRegexp
};

@interface RDStringPattern : NSObject <NSCopying, NSCoding> {

    int             _rdPatternType;
    NSString *      _rdPattern;
    
    NSString *      _rdMatchMe;
    int             _rdMatchPosition;
    
}

+ (RDStringPattern *) patternWithString:(NSString *)pattern type:(int)type;

- (BOOL) patternMatchesString:(NSString *)match;
- (BOOL) stringContainsPattern:(NSString *)match;
- (NSRange) stringMatch:(NSString *)match;

- (int) type;
- (NSString *) pattern;

- (id) copyWithZone:(NSZone *)zone;

- (void) encodeWithCoder:(NSCoder *)coder;
- (id) initWithCoder:(NSCoder *)coder;

@end
