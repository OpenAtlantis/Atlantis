//
//  NSFileManagerExtensions.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/13/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileManager (RDExtensions)

- (BOOL) createDirectoriesToFile:(NSString *) filename;

@end
