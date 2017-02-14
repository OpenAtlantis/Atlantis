//
//  RDAtlantisEventItem.h
//  Atlantis
//
//  Created by Rachel Blackman on 5/19/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lemuria/Lemuria.h>
#import "BaseCondition.h"
#import "BaseAction.h"

@interface RDAtlantisConditionItem : RDChainedListItem {

    id <EventConditionProtocol>      _rdCondition;

}

- (id <EventConditionProtocol>) itemCondition;
- (void) setItemCondition:(id <EventConditionProtocol>)condition;

@end

@interface RDAtlantisActionItem : RDChainedListItem {

    id <EventActionProtocol>         _rdAction;

}

- (id <EventActionProtocol>) itemAction;
- (void) setItemAction:(id <EventActionProtocol>)action;

@end
