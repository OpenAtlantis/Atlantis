//
//  RDCompressionFilter.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/8/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDCompressionFilter.h"
#import <zlib.h>

@interface RDCompressionFilter (Private)
- (void) compressCatchupTimerFired:(NSTimer *)timer;
@end

@implementation RDCompressionFilter

- (id) initWithWorld:(RDAtlantisWorldInstance *)world
{
    self = [super initWithWorld:world];
    if (self) {
        _rdStream = NULL;
        _rdHoldoverBuffer = nil;
        _rdCatchupTimer = nil;
    }    
    return self;
}

- (void) dealloc
{
    if (_rdStream) {
        free(_rdStream);
    }
    [_rdCatchupTimer invalidate];
    [_rdCatchupTimer release];
    [_rdHoldoverBuffer release];
    [super dealloc];
}

void * zlib_calloc(void *opaque, unsigned int items, unsigned int size)
{
    return calloc(items, size);
}

void zlib_free(void *opaque, void *data)
{
    if (data)
        free(data);
}

- (void) compressTimerFired:(NSTimer *)timer
{
    if ([[self world] isConnected]) {
        if ([_rdHoldoverBuffer length]) {
            NSMutableData *tempData = [[NSMutableData alloc] init];
            [self filterInput:tempData];
            [tempData release];
        }
    }
}

- (void) worldWasRefreshed
{
    BOOL oldCompress = _rdCompress;
    _rdCompress = [[self world] isCompressing];
    
    if (oldCompress != _rdCompress) {
        if (_rdCompress) {
            // Initialize
            _rdStream = (z_stream *)malloc(sizeof(z_stream));
            
            _rdStream->opaque = NULL;
            _rdStream->zalloc = zlib_calloc;
            _rdStream->zfree = zlib_free;
            
            if (inflateInit(_rdStream) != Z_OK) {
                [[self world] outputStatus:@"Unable to initialize MCCP decompresser!" toSpawn:@""];
                [[self world] disconnectWithMessage:@"Disconnected due to compression protocol negotiation failure."];                
                _rdCompress = NO;
                return;
            }
            
            _rdCatchupTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(compressTimerFired:) userInfo:nil repeats:YES] retain];
            
            if (!_rdHoldoverBuffer)
                _rdHoldoverBuffer = [[NSMutableData data] retain];
        }
        else {
            // Disable
            free(_rdStream);
            _rdStream = NULL;
            [_rdCatchupTimer invalidate];
            [_rdCatchupTimer release];
            _rdCatchupTimer = nil;
            [_rdHoldoverBuffer release];
            _rdHoldoverBuffer = nil;               
        }
    }
}

- (void) addBytesToHoldover:(NSData *)dataBytes
{
    if (!_rdHoldoverBuffer)
        _rdHoldoverBuffer = [[NSMutableData data] retain];
        
    [_rdHoldoverBuffer appendData:dataBytes];
}

- (void) filterInput:(id) object
{
    if (_rdCompress) {
        if ([object isKindOfClass:[NSMutableData class]]) {
            NSMutableData *mutableData = (NSMutableData *)object;

            [_rdHoldoverBuffer appendData:mutableData];
            unsigned long compressedLength = [_rdHoldoverBuffer length];
            
            if (compressedLength) {
                unsigned char *tempdata = (unsigned char *)malloc(compressedLength * 200);
                unsigned char *indata = (unsigned char *)malloc(compressedLength);
                memcpy(indata,[_rdHoldoverBuffer bytes],compressedLength);
                
                _rdStream->next_in = indata;
                _rdStream->avail_in = compressedLength;
                _rdStream->next_out = tempdata;
                _rdStream->avail_out = compressedLength * 200;
                
                int status = inflate(_rdStream,Z_PARTIAL_FLUSH);
                free(indata);
                
                if ((status == Z_OK) || (status == Z_STREAM_END)) {
                    unsigned long realLength = (compressedLength * 200) - _rdStream->avail_out;
                    [_rdHoldoverBuffer replaceBytesInRange:NSMakeRange(0,compressedLength - _rdStream->avail_in) withBytes:tempdata length:0];
                    [mutableData setLength:0];
                    [mutableData appendBytes:tempdata length:realLength];
                    
                    if (status == Z_STREAM_END) {
                        [mutableData appendData:_rdHoldoverBuffer];
                        inflateEnd(_rdStream);
                        [_rdHoldoverBuffer setLength:0];
                        [[self world] compress:NO];
                    }
                }
                else {
                    inflateEnd(_rdStream);
                    [[self world] outputStatus:@"MCCP decompression error!" toSpawn:@""];
                    [[self world] disconnectWithMessage:@"Disconnected due to error in compressed stream."]; 
                    [[self world] compress:NO];
                }
                
                free(tempdata);
            }
        }
    }
}

@end
