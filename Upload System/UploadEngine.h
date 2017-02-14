//
//  UploadEngine.h
//  Atlantis
//
//  Created by Rachel Blackman on 5/20/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RDAtlantisWorldInstance;

@interface UploadEngine : NSObject {

    NSTimer                 *_rdTimer;
    NSString                *_rdPrefix;
    NSString                *_rdSuffix;
    
    NSString                *_rdFilename;
    
    RDAtlantisWorldInstance *_rdWorld;

}

+ (NSString *) uploaderName;

- (id) initWithFile:(NSString *) filename forWorld:(RDAtlantisWorldInstance *)world atInterval:(NSTimeInterval)timerLen withPrefix:(NSString *) prefix suffix:(NSString *) suffix;
- (void) fireTimer;
- (void) finishUpload;

- (RDAtlantisWorldInstance *) world;
- (NSString *) prefix;
- (NSString *) suffix;


@end
