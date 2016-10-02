//
//  RDCompressionFilter.h
//  Atlantis
//
//  Created by Rachel Blackman on 4/8/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDAtlantisFilter.h"
#include <zlib.h>

@interface RDCompressionFilter : RDAtlantisFilter {

    BOOL                _rdCompress;
    z_stream *          _rdStream;
    NSMutableData *     _rdHoldoverBuffer;
    NSTimer *           _rdCatchupTimer;

}

- (void) addBytesToHoldover:(NSData *)dataBytes;

@end
