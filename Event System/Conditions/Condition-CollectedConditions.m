//
//  Condition-CollectedConditions.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/6/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-CollectedConditions.h"
#import "ConditionPicker.h"
#import "ConditionClasses.h"
#import "RDAtlantisMainController.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation Condition_CollectedConditions

#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdConditions = [[NSMutableArray alloc] init];
        _rdConditionsAnded = NO;
    }
    return self;
}

- (id) initWithConditions:(NSArray *) conditions anded:(BOOL) anded
{
    self = [self init];
    if (self) {
        [_rdConditions addObjectsFromArray:conditions];
        _rdConditionsAnded = anded;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdConditions = [coder decodeObjectForKey:@"collection.conditions"];
        
        if (_rdConditions) {
            _rdConditions = [_rdConditions mutableCopy];
        }
        else {
            _rdConditions = [[NSArray array] mutableCopy];
        }
        _rdConditionsAnded = [coder decodeBoolForKey:@"collection.anded"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    if (_rdConditions)
        [coder encodeObject:_rdConditions forKey:@"collection.conditions"];
    [coder encodeBool:_rdConditionsAnded forKey:@"collection.anded"];
}

- (void) dealloc
{
    [_rdConditions release];
    [super dealloc];
}

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Logic: Complex Condition";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Additional conditions are met.";
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    if (!_rdConditions)
        return NO;
    
    BOOL result;
    
    if (_rdConditionsAnded)
        result = YES;
    else
        result = NO;
    
    BaseCondition *conditionWalk;
    
    BOOL done = NO;
    
    NSEnumerator *conditionEnum = [_rdConditions objectEnumerator];
    while (!done && (conditionWalk = [conditionEnum nextObject])) {
        if (_rdConditionsAnded) {
            result = result & [conditionWalk isTrueForState:state];
            
            if (!result)
                done = YES;
        }
        else {
            result = result | [conditionWalk isTrueForState:state];
            
            if (result)
                done = YES;
        }
    }
    
    return result;
}

#pragma mark Configuration Goo

- (void) chainedListViewSelectionDidChange:(RDChainedListView *) chainView
{
    RDChainedListItem *item = [chainView currentActiveItem];
    
    if (!item) {
        [_rdRemoveConditionButton setEnabled:NO];
    }
    else {
        [_rdRemoveConditionButton setEnabled:YES];        
    }
}

- (void) conditionAndedChanged:(id) sender
{
    unsigned position = [_rdConditionsAndedPicker indexOfItem:[_rdConditionsAndedPicker selectedItem]];
    
    if (position) {
        _rdConditionsAnded = YES;
    }
    else {
        _rdConditionsAnded = NO;
    }
}

- (void) newConditionPicked:(BaseCondition *)condition context:(void *)context
{
    [_rdConditions addObject:condition];
    
    RDChainedListItem *item = [[RDChainedListItem alloc] initWithFrame:NSMakeRect(0,0,300,200)];
    [item setTitle:[condition conditionName]];
    [item setMainContentView:[condition conditionConfigurationView]];
    [item setAlternateContentView:[condition conditionConfigurationView]];
    [item setShowsAlternate:YES];
    [_rdConditionsChain addItem:item];
    [item release];
}

- (void) addCondition:(id) sender
{
    BaseCondition *condition = nil;
    
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        Class aClass = [(NSMenuItem*)sender representedObject];            
        condition = (BaseCondition *)class_createInstance(aClass,0);
    }        
    
    [_rdConditions addObject:condition];
    
    RDChainedListItem *item = [[RDChainedListItem alloc] initWithFrame:NSMakeRect(0,0,300,200)];
    [item setTitle:[condition conditionName]];
    [item setMainContentView:[condition conditionConfigurationView]];
    [item setAlternateContentView:[condition conditionConfigurationView]];
    [item setShowsAlternate:YES];
    [_rdConditionsChain addItem:item];
    [item release];
}

- (void) removeSubCondition:(id) sender
{
    RDChainedListItem *item = [_rdConditionsChain currentActiveItem];
    
    if (item) {
        unsigned position = [_rdConditionsChain positionOfItem:item];
        if (position != NSNotFound) {
            [_rdConditions removeObjectAtIndex:position];
            [_rdConditionsChain removeItem:item];
        }
    }
}

- (NSView *) conditionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"CondConf_Collection" owner:self];

        [_rdConditionsAndedPicker setTarget:self];
        [_rdConditionsAndedPicker setAction:@selector(conditionAndedChanged:)];
        
        if (_rdConditionsAnded) {
            [_rdConditionsAndedPicker selectItemAtIndex:1];
        }
        else {
            [_rdConditionsAndedPicker selectItemAtIndex:0];
        }
        
        [_rdConditionsChain setAutocollapse:YES];
        
        [_rdAddConditionButton setMenu:[[ConditionPicker sharedPanel] menuForConditions:[[[RDAtlantisMainController controller] eventConditions] conditions] withTarget:self] forSegment:0];
        
        NSEnumerator *conditionEnum = [_rdConditions objectEnumerator];
        BaseCondition *conditionWalk;
        
        while (conditionWalk = [conditionEnum nextObject]) {
            RDChainedListItem *item = [[RDChainedListItem alloc] initWithFrame:NSMakeRect(0,0,300,200)];
            
            [item setTitle:[conditionWalk conditionName]];
            [item setMainContentView:[conditionWalk conditionConfigurationView]];
            [item setAlternateContentView:[conditionWalk conditionConfigurationView]];
            [item setShowsAlternate:YES];
            [_rdConditionsChain addItem:item];
            [item release];
        }
    }

    return _rdInternalConfigurationView;
}


@end
