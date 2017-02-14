//
//  CodeUploader.m
//  Atlantis
//
//  Created by Rachel Blackman on 5/21/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "CodeUploader.h"
#import "RDAtlantisWorldInstance.h"

@implementation CodeUploader

+ (NSString *) uploaderName
{
    return @"Formatted Code";
}


- (id) initWithFile:(NSString *) filename forWorld:(RDAtlantisWorldInstance *)world atInterval:(NSTimeInterval)timerLen withPrefix:(NSString *) prefix suffix:(NSString *) suffix;
{
    self = [super initWithFile:filename forWorld:world atInterval:timerLen withPrefix:prefix suffix:suffix];
    if (self) {
        // Custom initialization
        _rdCodefileHandle = fopen([filename cString],"r");
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
    
    BOOL done = NO;
    BOOL fileDone = NO;
    
    NSMutableString *outputString = [[self prefix] mutableCopy];
    
    
    while (!done) {
        if (fgets(&lineBuffer[0],15999,_rdCodefileHandle)) {
            if (strlen(lineBuffer)) {
                while ((lineBuffer[strlen(lineBuffer) - 1] == '\n') || (lineBuffer[strlen(lineBuffer) - 1] == '\r')) {
                    lineBuffer[strlen(lineBuffer) - 1] = 0;
                }
            }
            
            if ((strlen(lineBuffer) == 1) && (lineBuffer[0] == '-')) {
                done = YES;
            }
            else if (lineBuffer[0] != '#') {
                char *ptr = &lineBuffer[0];
                
                while (*ptr && isspace(*ptr))
                    ptr++;
                
                [outputString appendString:[NSString stringWithCString:ptr]];
            }
        }
        else {
            done = YES;
            fileDone = YES;
        }
    }
    [outputString appendString:[self suffix]];
    
    [[self world] sendString:outputString];
    [outputString release];
    
    if (fileDone) {
        [self finishUpload];
    }
}

- (void) finishUpload
{
    [super finishUpload];
    fclose(_rdCodefileHandle);
}

@end
