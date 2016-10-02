//
//  BaseCommand.h
//  Atlantis
//
//  Created by Rachel Blackman on 4/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AtlantisState;

@interface BaseCommand : NSObject {

}

- (NSString *) checkOptionsForState:(AtlantisState *) state;
- (void) executeForState:(AtlantisState *) state;

@end
