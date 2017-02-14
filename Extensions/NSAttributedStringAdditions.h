//
//  NSAttributedStringAdditions.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/25/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RDAtlantisWorldInstance;

@interface NSAttributedString (RDAtlantisMarkup)
- (NSString *) stringAsAML;
- (id) initWithAML:(NSString *)aml forWorld:(RDAtlantisWorldInstance *)world;
- (id) initWithAML:(NSString *)aml forWorld:(RDAtlantisWorldInstance *)world withFont:(NSFont *)defaultFont withDefaultFG:(NSColor *)defaultFG withDefaultBG:(NSColor *)defaultBG;
@end
