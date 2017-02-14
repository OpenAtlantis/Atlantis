//
//  RDEmailFilter.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDEmailFilter.h"
#import <OgreKit/OgreKit.h>


@implementation RDEmailFilter

- (void) filterInput:(id) input
{
    if ([input isKindOfClass:[NSMutableAttributedString class]]) {

        NSMutableAttributedString *finalString = (NSMutableAttributedString *)input;
        
        NSRange foundUrlRange;
        NSRange searchRange;
        NSString *searchString = [finalString string];
        unsigned searchLength = [searchString length];
        searchRange = NSMakeRange(0,searchLength);
        do 
        {
            foundUrlRange.length = 0;
            foundUrlRange.location = searchLength;

            foundUrlRange = [searchString rangeOfRegularExpressionString:@"[^ \\\\/\\\"\\'\\@\\<\\>]*\\@[a-zA-Z0-9_\\-]*\\.[a-zA-Z0-9_\\-\\.]+[a-zA-Z]+" options:0 range:searchRange];

            if (foundUrlRange.location != NSNotFound) {
                NSRange effRange;
                NSDictionary *attrs;
                
                attrs = [finalString attributesAtIndex:foundUrlRange.location effectiveRange:&effRange];
                
                if (![attrs objectForKey:NSLinkAttributeName]) {
                    NSURL *newURL;
                    
                    NSString *url = [searchString substringWithRange:foundUrlRange];
                    NSString *tempUrl = [NSString stringWithFormat:@"mailto:%@", url];                    
                    newURL = [NSURL URLWithString:tempUrl];
                    
                    if (newURL) {
                        [finalString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                            newURL,NSLinkAttributeName,
                            nil]
                                             range:foundUrlRange];                    
                    }
                }
                
                unsigned newPos = foundUrlRange.location + foundUrlRange.length;
                
                searchRange = NSMakeRange(newPos,searchLength - newPos);
            }
            
        } while ((foundUrlRange.location != NSNotFound) && (searchRange.location < [searchString length]));
    }
}


@end
