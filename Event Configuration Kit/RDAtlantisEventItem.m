//
//  RDAtlantisEventItem.m
//  Atlantis
//
//  Created by Rachel Blackman on 5/19/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "RDAtlantisEventItem.h"


@implementation RDAtlantisConditionItem

- (id <EventConditionProtocol>) itemCondition
{
    return _rdCondition;
}

- (void) setItemCondition:(id <EventConditionProtocol>)condition
{
    _rdCondition = condition;
}


@end

@implementation RDAtlantisActionItem

- (id <EventActionProtocol>) itemAction
{
    return _rdAction;
}

- (void) setItemAction:(id <EventActionProtocol>)action
{
    _rdAction = action;
}

@end


