//
//  UploadEngine.m
//  Atlantis
//
//  Created by Rachel Blackman on 5/20/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "UploadEngine.h"
#import "RDAtlantisWorldInstance.h"

@implementation UploadEngine

+ (NSString *) uploaderName
{
    return @"Base Uploader";
}

- (id) initWithFile:(NSString *) filename forWorld:(RDAtlantisWorldInstance *)world atInterval:(NSTimeInterval)timerLen withPrefix:(NSString *) prefix suffix:(NSString *) suffix;
{
    if (self) {
        if (prefix)
            _rdPrefix = [prefix retain];
        else
            _rdPrefix = [[NSString string] retain];
            
        if (suffix)
            _rdSuffix = [suffix retain];
        else
            _rdSuffix = [[NSString string] retain];

        _rdWorld = [world retain];
        [_rdWorld addUploader:self];
        
        _rdFilename = [filename retain];

        _rdTimer = [[NSTimer scheduledTimerWithTimeInterval:timerLen target:self selector:@selector(fireTimer) userInfo:nil repeats:YES] retain];    
    }
    return self;
}

- (void) dealloc
{
    [_rdTimer invalidate];
    [_rdPrefix release];
    [_rdSuffix release];
    [_rdWorld release];
    [_rdTimer release];
    [_rdFilename release];
    [super dealloc];
}

- (void) fireTimer
{

}

- (void) finishUpload
{
    [_rdTimer invalidate];
    [_rdWorld handleStatusOutput:[NSString stringWithFormat:@"Finished uploading %@\n", _rdFilename]]; 
    [_rdWorld removeUploader:self];
}

- (RDAtlantisWorldInstance *) world
{
    return _rdWorld;
}

- (NSString *) prefix
{
    return _rdPrefix;
}

- (NSString *) suffix
{
    return _rdSuffix;
}

/* Template

- (id) initWithFile:(NSString *) filename forWorld:(RDAtlantisWorldInstance *)world atInterval:(NSTimeInterval)timerLen withPrefix:(NSString *) prefix suffix:(NSString *) suffix;
{
    self = [super initWithFile:filename forWorld:world atInterval:timerLen withPrefix:prefix suffix:suffix];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    // Custom deallocation
    [super dealloc];
}

- (void) fireTimer
{

}

- (void) finishUpload
{
    [super finishUpload];
    // Close file, et al
}

*/

@end
