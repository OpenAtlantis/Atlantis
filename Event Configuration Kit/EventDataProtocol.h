//
//  EventDataProtocol.h
//  LemuriaTestbed
//
//  Created by Rachel Blackman on 2/25/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol EventActionProtocol;
@protocol EventConditionProtocol;

@protocol EventDataProtocol

- (NSString *) eventName;
- (NSString *) eventDescription;

- (BOOL) eventIsEnabled;
- (void) eventSetEnabled:(BOOL) enabled;

- (BOOL) eventCanEditName;
- (BOOL) eventCanEditNameSpecial;
- (void) eventEditNameHook;
- (void) eventSetName:(NSString *) name;

- (BOOL) eventCanEditDescription;
- (void) eventSetDescription:(NSString *) name;

- (BOOL) eventSupportsConditions;
- (NSArray *) eventConditions;
- (BOOL) eventConditionsAnded;
- (void) eventSetConditionsAnded:(BOOL) anded;
- (void) eventAddCondition:(id <EventConditionProtocol>) condition;
- (void) eventRemoveCondition:(id <EventConditionProtocol>) condition;
- (void) eventMoveCondition:(id <EventConditionProtocol>) condition toPosition:(int) index;

- (NSArray *) eventActions;
- (void) eventAddAction:(id <EventActionProtocol>) action;
- (void) eventRemoveAction:(id <EventActionProtocol>) action;
- (void) eventMoveAction:(id <EventActionProtocol>) action toPosition:(int) index;

- (id) eventExtraData:(NSString *) dataName;
- (void) eventSetExtraData:(id) data forName:(NSString *) dataName;

- (BOOL) eventCanEditExtraDataSpecial;
- (void) eventEditExtraDataHook:(NSString *)dataName;

@end
