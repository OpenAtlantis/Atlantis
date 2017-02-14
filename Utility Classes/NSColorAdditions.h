//
//  NSColorAdditions.h
//  Atlantis
//
//  Created by Rachel Blackman on 5/31/08.
//  Copyright 2008 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSColor (RDColorAdditions)

+ (NSColor *) colorWithWebCode:(NSString *)webCode;
- (NSString *) webCode;

@end
