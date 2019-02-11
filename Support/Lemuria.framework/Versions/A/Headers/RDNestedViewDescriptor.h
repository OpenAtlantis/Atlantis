//
//  RDNestedViewDescriptor.h
//  RDNestingViewsTest
//
//  Created by Rachel Blackman on 1/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol RDNestedViewDescriptor 

- (BOOL) isFolder;
- (NSArray *) subviewDescriptors;

- (NSString *) viewUID;
- (NSString *) viewPath;
- (NSString *) viewName;
- (NSUInteger)   viewWeight;
- (NSImage *)  viewIcon;

- (NSView *) view;

- (void) viewWasFocused;
- (void) viewWasUnfocused;

- (void) close;

- (BOOL) addSubview:(id <RDNestedViewDescriptor>)newView;
- (BOOL) removeSubview:(id <RDNestedViewDescriptor>)oldView;
- (void) sortSubviews;

- (BOOL) isLive;
- (BOOL) isLiveSelf;

- (NSString *) closeInfoString;

@end
