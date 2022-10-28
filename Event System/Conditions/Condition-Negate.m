//
//  Condition-Negate.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/18/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-Negate.h"
#import "RDAtlantisMainController.h"
#import "ConditionClasses.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface Condition_Negate (Private)
- (void) resetContentView;
- (void) setChildConditionClass:(int) index;
@end


@implementation Condition_Negate

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Logic: Negated Condition";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Test to see that another condition is NOT true.";
}

- (id) init
{
    self = [super init];
    if (self) {
        _rdChildCondition = nil;
        [self setChildConditionClass:0];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdChildCondition = [coder decodeObjectForKey:@"negatedCondition"];
        if (_rdChildCondition) {
            [_rdChildCondition retain];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_rdChildCondition forKey:@"negatedCondition"];
}

- (void) resetContentView
{
    RDChainedListItem *item = [[RDChainedListItem alloc] initWithFrame:NSMakeRect(0,0,300,200)];
    RDChainedListItem *old = [_rdDisplayView itemAtPosition:0];
    [_rdDisplayView setHidden:YES];

    if (old)
        [_rdDisplayView removeItem:old];

    NSArray *conditionClasses = [[[RDAtlantisMainController controller] eventConditions] conditions];
    int conditionIndex = [conditionClasses indexOfObject:[_rdChildCondition class]];
    if (conditionIndex != NSNotFound) {
        [_rdConditionPicker selectItemAtIndex:conditionIndex];
    }
    
    [item setTitle:[_rdChildCondition conditionName]];
    [item setMainContentView:[_rdChildCondition conditionConfigurationView]];
    [item setAlternateContentView:[_rdChildCondition conditionConfigurationView]];
    [_rdDisplayView addItem:item];
    [item setShowsAlternate:YES];
    [item setShowsAlternate:NO];
    [_rdDisplayView performSelector:@selector(setHidden:) withObject:(id)NO afterDelay:0.1];
    [item release];
}

- (void) setChildConditionClass:(int) index
{
    BaseCondition *newCondition = nil;
    
    NSArray *conditionClasses = [[[RDAtlantisMainController controller] eventConditions] conditions];
    if ((index < 0) || (index >= [conditionClasses count]))
        return;
        
    Class newClass = [conditionClasses objectAtIndex:index];
    if (newClass && ![_rdChildCondition isKindOfClass:newClass]) {    
        newCondition = (id)class_createInstance(newClass,0);
        [newCondition init];
    }
    
    if (newCondition) {
        BaseCondition *oldCondition = _rdChildCondition;
        _rdChildCondition = [newCondition retain];

        if (_rdInternalConfigurationView) {
            [self resetContentView];
        }
        
        [oldCondition release];
    }
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    // Negate!
    return ![_rdChildCondition isTrueForState:state];
}

#pragma mark Configuration

- (void) conditionTypeChanged:(id) sender
{
    int selected = [_rdConditionPicker indexOfSelectedItem];
    
    [self setChildConditionClass:selected];
}

- (NSView *) conditionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"CondConf_Negate" owner:self];
        [_rdConditionPicker removeAllItems];
        NSArray *conditionClasses = [[[RDAtlantisMainController controller] eventConditions] conditions];
        NSEnumerator *classEnum = [conditionClasses objectEnumerator];
        Class classWalk;
        
        NSString* (*SendReturningString)(id, SEL) = (NSString* (*)(id, SEL))objc_msgSend;
        
        while (classWalk = [classEnum nextObject]) {
            NSString *result = SendReturningString(classWalk,@selector(conditionName));
            [_rdConditionPicker addItemWithTitle:result];
        }

        [_rdDisplayView setAutocollapse:YES];

        [self resetContentView];
        
        [_rdInternalConfigurationView setNeedsDisplay:YES];
    }
    
    return _rdInternalConfigurationView;
}

@end
