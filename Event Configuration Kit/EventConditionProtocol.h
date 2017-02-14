//
//  EventConditionProtocol.h
//  LemuriaTestbed
//
//  Created by Rachel Blackman on 2/25/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol EventConditionProtocol

+ (NSString *) conditionName;
+ (NSString *) conditionDescription;

- (NSString *) conditionName;
- (NSString *) conditionDescription;

- (NSView *) conditionConfigurationView;

@end
