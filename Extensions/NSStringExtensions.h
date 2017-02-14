//
//  NSStringExtensions.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/14/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (RDStringSubstitution) 

- (NSDictionary *) optionsFromString;

- (unsigned) lineCount;
- (NSString *) expandWithDataIn:(NSDictionary *) data;

- (NSString *) string;

- (int) intValueFromHex;

@end
