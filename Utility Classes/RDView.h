//
//  RDView.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RDView : NSView {

    id              _rdDelegate;

}

- (id) delegate;
- (void) setDelegate:(id) delegate;

@end
