//
//  RDAtlantisFilter.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDAtlantisWorldInstance.h"

@interface RDAtlantisFilter : NSObject {

    RDAtlantisWorldInstance             *_rdWorld;

}

- (id) initWithWorld:(RDAtlantisWorldInstance *) world;
- (RDAtlantisWorldInstance *) world;
- (void) worldWasRefreshed;

- (void) filterInput:(id) input;
- (void) filterOutput:(id) output;

@end
