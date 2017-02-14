//
//  RDNestedViewCollection.h
//  RDNestingViewsTest
//
//  Created by Rachel Blackman on 1/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lemuria/RDNestedViewDescriptor.h>

@interface RDNestedViewPlaceholder : NSObject <RDNestedViewDescriptor> {

    NSString                         *_rdViewName;
    NSString                         *_rdViewPath;
    NSString                         *_rdViewUID;
    NSMutableArray                   *_rdSubviews;
    
    unsigned                          _rdWeight;

}

- (id) initWithPath:(NSString *)path forSubviews:(NSArray *)subviews;

@end

@interface RDNestedViewCache : NSObject <NSCopying> {

    NSMutableArray                  *_rdCachedObjects;
    id                               _rdDelegate;

}

- (NSArray *) topLevel;
- (NSArray *) realViewsFlattened;
- (id <RDNestedViewDescriptor>) getViewByPath:(NSString *)path;
- (void) addView:(id <RDNestedViewDescriptor>)newView;
- (void) removeView:(id <RDNestedViewDescriptor>)oldView;
- (void) removeAllViews;
- (void) closeAllViews;
- (void) sortAllViews;

- (unsigned) count;

- (BOOL) isEmpty;

- (id <RDNestedViewDescriptor>) firstRealView;

- (id) delegate;
- (void) setDelegate:(id) delegate;

@end
