//
//  RDTelnetFilter.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDAtlantisFilter.h"

@interface TelnetData : NSObject
{
    @public
    unsigned char local[256];
    unsigned char remote[256];
    
    unsigned char localQ[256];
    unsigned char remoteQ[256];
}

- (void) clear;

@end


@interface RDTelnetFilter : RDAtlantisFilter {

    TelnetData *        telnetSessionData;
    NSTimer *           _rdNopTimer;
    BOOL                mudProtocol;
    BOOL                mudPrompted;
    int                 ttypeCycle;

}

@end
