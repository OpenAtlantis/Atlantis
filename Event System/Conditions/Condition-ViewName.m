//
//  Condition-ViewName.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/6/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-ViewName.h"
#import "AtlantisState.h"
#import "RDAtlantisSpawn.h"

@implementation Condition_ViewName

#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdViewName = nil;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdViewName = [[coder decodeObjectForKey:@"activity.viewName"] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    if (_rdViewName)
        [coder encodeObject:_rdViewName forKey:@"activity.viewName"];
}

- (void) dealloc
{
    [_rdViewName release];
    [super dealloc];
}

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Spawn: Is Specific Spawn";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"The spawn is a specific spawn.";
}

- (NSString *) conditionDescription
{
    // TODO: Localize
    NSString *descString = [NSString stringWithFormat:@"The spawn is %@.",
                _rdViewName];
                
    return descString;
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    return [[[state spawn] viewPath] isEqualToString:_rdViewName];
}

#pragma mark Configuration Goo

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    [_rdViewName release];
    _rdViewName = [[_rdActualText stringValue] retain];
}


- (NSView *) conditionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"CondConf_ViewName" owner:self];
    }

    [_rdActualText setDelegate:self];
    if (_rdViewName)
        [_rdActualText setStringValue:_rdViewName];
    
    return _rdInternalConfigurationView;
}


@end
