//
//  TextfileUploader.m
//  Atlantis
//
//  Created by Rachel Blackman on 5/21/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "TextfileUploader.h"
#import "RDAtlantisWorldInstance.h"

@implementation TextfileUploader

+ (NSString *) uploaderName
{
    return @"Textfile";
}


- (id) initWithFile:(NSString *) filename forWorld:(RDAtlantisWorldInstance *)world atInterval:(NSTimeInterval)timerLen withPrefix:(NSString *) prefix suffix:(NSString *) suffix;
{
    self = [super initWithFile:filename forWorld:world atInterval:timerLen withPrefix:prefix suffix:suffix];
    if (self) {
        // Custom initialization
        _rdTextfileHandle = fopen([filename cString],"r");
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
    char lineBuffer[16000];
    
    memset(lineBuffer,0,16000);
    
    if (fgets(&lineBuffer[0],15999,_rdTextfileHandle)) {
        NSString *tempString = [NSString stringWithFormat:@"%@%s%@", [self prefix], lineBuffer, [self suffix]];
        
        [[self world] sendString:tempString];
    }
    else {
        [self finishUpload];
    }
}

- (void) finishUpload
{
    [super finishUpload];
    fclose(_rdTextfileHandle);
}


@end
