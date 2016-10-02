//
//  BaseEvent.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/3/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "BaseEvent.h"
#import <Lemuria/Lemuria.h>
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisSpawn.h"
#import "AtlantisState.h"
#import "NSStringExtensions.h"
#import "BaseAction.h"
#import "BaseCondition.h"

@implementation BaseEvent

#pragma Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdActions = [[NSMutableArray alloc] init];
        _rdConditions = [[NSMutableArray alloc] init];
        _rdEnabled = NO;
        _rdEventName = nil;
        _rdEventDesc = nil;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [self init];
    if (self) {
        [_rdActions release];
        [_rdConditions release];
    
        _rdActions = [[coder decodeObjectForKey:@"event.actions"] mutableCopy];
        _rdConditions = [[coder decodeObjectForKey:@"event.conditions"] mutableCopy];
        _rdEnabled = [coder decodeBoolForKey:@"event.enabled"];
        _rdConditionsAnded = [coder decodeBoolForKey:@"event.conditions.anded"];
        
        _rdEventName = [coder decodeObjectForKey:@"event.name"];
        if (_rdEventName)
            [_rdEventName retain];
        
        _rdEventDesc = [coder decodeObjectForKey:@"event.desc"];
        if (_rdEventDesc)
            [_rdEventDesc retain];
        
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [coder encodeObject:_rdActions forKey:@"event.actions"];
    [coder encodeObject:_rdConditions forKey:@"event.conditions"];
    [coder encodeBool:_rdEnabled forKey:@"event.enabled"];
    [coder encodeBool:_rdConditionsAnded forKey:@"event.conditions.anded"];
    
    if (_rdEventName)
        [coder encodeObject:_rdEventName forKey:@"event.name"];
    if (_rdEventDesc)
        [coder encodeObject:_rdEventDesc forKey:@"event.desc"];
}

- (void) dealloc
{
    [_rdEventName release];
    [_rdEventDesc release];
    [_rdConditions release];
    [_rdActions release];
    [super dealloc];
}

- (BOOL) isEnabled
{
    return _rdEnabled;
}

#pragma Event System Protocol

- (NSString *) eventName
{
    return _rdEventName;
}

- (NSString *) eventDescription
{
    return _rdEventDesc;
}

- (BOOL) eventIsEnabled
{
    return _rdEnabled;
}

- (void) eventSetEnabled:(BOOL) enabled
{
    _rdEnabled = enabled;
}

- (BOOL) eventCanEditName
{
    return YES;
}

- (BOOL) eventCanEditNameSpecial
{
    return NO;
}

- (void) eventEditNameHook
{
    // Do nothing
}

- (void) eventSetName:(NSString *) name
{
    [_rdEventName release];
    _rdEventName = [name retain];
}

- (BOOL) eventCanEditDescription
{
    return YES;
}

- (void) eventSetDescription:(NSString *) desc
{
    [_rdEventDesc release];
    _rdEventDesc = [desc retain];
}

- (BOOL) eventSupportsConditions
{
    return YES;
}

- (NSArray *) eventConditions
{
    return _rdConditions;
}

- (BOOL) eventConditionsAnded
{
    return _rdConditionsAnded;
}

- (void) eventSetConditionsAnded:(BOOL) anded
{
    _rdConditionsAnded = anded;
}

- (void) eventAddCondition:(id <EventConditionProtocol>) condition
{
    if (![_rdConditions containsObject:condition])
        [_rdConditions addObject:condition];
}

- (void) eventRemoveCondition:(id <EventConditionProtocol>) condition
{
    if ([_rdConditions containsObject:condition])
        [_rdConditions removeObject:condition];
}

- (void) eventMoveCondition:(id <EventConditionProtocol>)condition toPosition:(int) index
{
    if ([_rdConditions containsObject:condition]) {
        int oldIndex = [_rdConditions indexOfObject:condition];
        
        if ((oldIndex != index) && (index >= 0) && (index < [_rdConditions count])) {
            [_rdConditions exchangeObjectAtIndex:oldIndex withObjectAtIndex:index];
        }
    }
}


- (NSArray *) eventActions
{
    return _rdActions;
}

- (void) eventAddAction:(id <EventActionProtocol>) action
{
    if (![_rdActions containsObject:action])
        [_rdActions addObject:action];
}

- (void) eventRemoveAction:(id <EventActionProtocol>) action
{
    if ([_rdActions containsObject:action])
        [_rdActions removeObject:action];
}

- (void) eventMoveAction:(id <EventActionProtocol>)action toPosition:(int) index
{
    if ([_rdActions containsObject:action]) {
        int oldIndex = [_rdActions indexOfObject:action];
        
        if ((oldIndex != index) && (index >= 0) && (index < [_rdActions count])) {
            [_rdActions exchangeObjectAtIndex:oldIndex withObjectAtIndex:index];
        }
    }
}


- (id) eventExtraData:(NSString *) dataName
{
    // Subclasses override this
    return nil;
}

- (void) eventSetExtraData:(id) data forName:(NSString *) dataName
{
    // Subclasses override this
}

- (BOOL) eventCanEditExtraDataSpecial
{
    return NO;
}

- (void) eventEditExtraDataHook:(NSString *)name
{
    // Do nothing
}

#pragma mark Atlantis Event Execution

- (BOOL) shouldExecuteForCause:(NSString *) cause subCause:(id) subcause;
{
    RDAtlantisWorldInstance *world = nil;
    RDAtlantisSpawn *spawn = nil;
    
    id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];

    if (curView && [(NSObject *)curView isKindOfClass:[RDAtlantisSpawn class]]) {
        spawn = (RDAtlantisSpawn *)curView;
    }
    
    if (spawn) {
        world = [spawn world];
    }
    
    AtlantisState *state;
    
    state = [[AtlantisState alloc] initWithString:(NSMutableAttributedString*)subcause inWorld:world forSpawn:spawn];
    
    [state setExtraData:[NSString stringWithString:cause] forKey:@"event.cause"];
    if ([cause isEqualToString:@"statechange"]) {
        [state setExtraData:[NSString stringWithString:[subcause string]] forKey:@"event.statechange"];
    }
    
    BOOL result = [self shouldExecute:state];    
    [state release];
    
    return result;
}

- (BOOL) shouldExecute:(AtlantisState *) state
{
    BOOL result;
    
    if (![self isEnabled])
        return NO;
    
    if (![self eventConditions] || ![[self eventConditions] count])
        return NO;
        
    if ([self eventConditionsAnded])
        result = YES;
    else
        result = NO;
        
    NSEnumerator *conditionEnum = [[self eventConditions] objectEnumerator];
    
    BaseCondition *conditionWalk;
    
    while (conditionWalk = [conditionEnum nextObject]) {
        if ([self eventConditionsAnded]) {
            result = result & [conditionWalk isTrueForState:state];
        }
        else {
            result = result | [conditionWalk isTrueForState:state];
        }
    }
    
    return result;
}

- (void) executeWithCause:(NSString *) cause subCause:(id) subcause
{
    RDAtlantisWorldInstance *world = nil;
    RDAtlantisSpawn *spawn = nil;
    
    id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];

    if (curView && [(NSObject *)curView isKindOfClass:[RDAtlantisSpawn class]]) {
        spawn = (RDAtlantisSpawn *)curView;
    }
    
    if (spawn) {
        world = [spawn world];
    }
    
    AtlantisState *state;
    
    state = [[AtlantisState alloc] initWithString:(NSMutableAttributedString*)subcause inWorld:world forSpawn:spawn];
    
    [state setExtraData:[NSString stringWithString:cause] forKey:@"event.cause"];
    if ([cause isEqualToString:@"line"]) {
        [state setExtraData:[NSString stringWithString:[subcause string]] forKey:@"event.line"];
    }
    else if ([cause isEqualToString:@"statechange"]) {
        [state setExtraData:[NSString stringWithString:[subcause string]] forKey:@"event.statechange"];
    }
    else if ([cause isEqualToString:@"toolbar"]) {
        [state setExtraData:[NSString stringWithString:[subcause string]] forKey:@"toolbar.windowUID"];
    }
    [self executeForState:state];
    [state release];
}

- (void) executeForState:(AtlantisState *) state
{
    NSEnumerator *actionEnum = [[self eventActions] objectEnumerator];
    
    BaseAction *actionWalk;
    
    BOOL done = NO;
    
    while (!done && (actionWalk = [actionEnum nextObject])) {
        if ([actionWalk executeForState:state])
            done = YES;
    }        
}

@end
