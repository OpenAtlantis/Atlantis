//
//  ToolbarCollection.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ToolbarCollection.h"
#import "ToolbarUserEvent.h"

@implementation ToolbarCollection

- (NSArray *) identifiers
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSEnumerator *objEnum = [[self events] objectEnumerator];
    
    ToolbarUserEvent *walk;
    
    while (walk = [objEnum nextObject]) {
        if ([walk eventIsEnabled])
            [array addObject:[walk toolbarItemIdentifier]];
    }
    
    NSArray *result = [NSArray arrayWithArray:array];
    [array release];
    return result;
}

- (ToolbarUserEvent *) eventForIdentifier:(NSString *)identifier
{
    ToolbarUserEvent *result = nil;
    
    NSEnumerator *objEnum = [[self events] objectEnumerator];    
    ToolbarUserEvent *walk;
    
    while (!result && (walk = [objEnum nextObject])) {
        if ([[walk toolbarItemIdentifier] isEqualToString:identifier] && [walk eventIsEnabled])
            result = walk;
    }
    
    return result;
} 

@end
