//
//  Action-WorldSend.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-WorldSend.h"
#import "RDAtlantisWorldInstance.h"
#import "AtlantisState.h"
#import "NSStringExtensions.h"

@implementation Action_WorldSend

#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdString = nil;
    }
    return self;
}

- (id) initWithString:(NSString *) string
{
    self = [self init];
    if (self) {
        _rdString = [[string copyWithZone:nil] retain];
    }
    return self;
}

- (void) dealloc
{
    [_rdString release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdString = [[coder decodeObjectForKey:@"action.text"] retain];
        if ([coder containsValueForKey:@"action.splitline"]) {
            _rdSplitLines = [coder decodeBoolForKey:@"action.splitline"];
        }
        else {
            _rdSplitLines = YES;
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder;
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_rdString forKey:@"action.text"];
    [coder encodeBool:_rdSplitLines forKey:@"action.splitline"];
}


#pragma mark Action Implementation

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Connection: Send Text";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Send specific text to the active connection.";
}

- (NSString *) actionDescription
{
    // TODO: Localize
    NSString *result = [NSString stringWithFormat:@"Send '%@' to the active connection.",
                        _rdString ? _rdString : @""];
                        
    return result;
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeEvent) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    if (![[state world] isConnected])
        return NO;

    NSString *newString = [_rdString expandWithDataIn:[state data]];

    if (_rdSplitLines) {
        NSArray *newCommand = [newString componentsSeparatedByString:@";"];
        NSEnumerator *commandEnum = [newCommand objectEnumerator];
        NSString *walk;
        
        while (walk = [commandEnum nextObject]) {
            [state textToWorld:walk];
        }
    }
    else {
        [state textToWorld:newString];
    }
    
    return NO;
}

#pragma mark Configuration Glue

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [[NSBundle mainBundle] loadNibNamed:@"ActionConf_SendText" owner:self topLevelObjects:nil];
    }
    
    [_rdActualText setDelegate:self];
    
    if (_rdString)
        [_rdActualText setStringValue:_rdString];
    else
        [_rdActualText setStringValue:@""];
    
    _rdSplitLineToggle.state = _rdSplitLines ? NSControlStateValueOn : NSControlStateValueOff;
    
    return _rdInternalConfigurationView;
}

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    [_rdString release];
    _rdString = [[_rdActualText stringValue] retain];
}

- (void) lineSplitToggled:(id)sender
{
    _rdSplitLines = (_rdSplitLineToggle.state == NSControlStateValueOn);
}


@end
