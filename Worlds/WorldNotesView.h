//
//  WorldNotesView.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/3/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lemuria/Lemuria.h>
#import "RDAtlantisWorldInstance.h"

@interface WorldNotesView : NSObject <RDNestedViewDescriptor, NSTextViewDelegate> {

    RDAtlantisWorldInstance             *_rdWorld;
    NSString                            *_rdUID;
    NSString                            *_rdPath;

    IBOutlet NSView                     *_rdNotesView;
    IBOutlet NSTextView                 *_rdNotesText;

}

- (id) initForWorld:(RDAtlantisWorldInstance *)world;


@end
