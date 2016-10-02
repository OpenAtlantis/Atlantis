//
//  NSFileManagerExtensions.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/13/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "NSFileManagerExtensions.h"


@implementation NSFileManager (RDExtensions)

- (BOOL) createDirectoriesToFile:(NSString *) filename
{
    NSArray *pathComponents = [[[filename stringByExpandingTildeInPath] stringByDeletingLastPathComponent] pathComponents];
    
    NSString *currentPath = @"";
    NSFileManager *fileman = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    NSEnumerator *pathEnum = [pathComponents objectEnumerator];
    NSString *pathFragment = @"/";
    
    do {
        currentPath = [currentPath stringByAppendingPathComponent:pathFragment];
        if ([fileman fileExistsAtPath:currentPath isDirectory:&isDirectory]) {
            if (!isDirectory)
                return NO;
        }
        else {
            if (![fileman createDirectoryAtPath:currentPath attributes:nil])
                return NO;
        }
    } while (pathFragment = [pathEnum nextObject]);

    return YES;
}

@end
