//
//  EventActionProtocol.h
//  LemuriaTestbed
//
//  Created by Rachel Blackman on 2/25/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol EventActionProtocol 

+ (NSString *) actionName;
+ (NSString *) actionDescription;

- (NSString *) actionName;
- (NSString *) actionDescription;


- (NSView *) actionConfigurationView;


@end
