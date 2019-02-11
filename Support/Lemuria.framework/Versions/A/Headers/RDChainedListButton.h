//
//  RDChainedListButton.h
//  CLVTest
//
//  Created by Rachel Blackman on 2/23/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RDChainedListButton : NSObject {

    NSImage                     *_rdButtonImage;
    
    SEL                          _rdAction;
    id                           _rdTarget;

}

- (id) initWithImage:(NSImage *)image action:(SEL) selector target:(id) target;

- (id) target;
- (SEL) action;
- (NSImage *) image;

@end
