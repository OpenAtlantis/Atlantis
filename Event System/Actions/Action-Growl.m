//
//  Action-Growl.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-Growl.h"
#import <Growl/Growl.h>
#import "NSStringExtensions.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisSpawn.h"

@implementation Action_Growl

#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdGrowlString = nil;
        _rdGrowlTitle = nil;
    }
    return self;
}

- (id) initWithString:(NSString *) string title:(NSString *)title;
{
    self = [self init];
    if (self) {
        _rdGrowlString = [[string copyWithZone:nil] retain];
        _rdGrowlTitle = [[title copyWithZone:nil] retain];
    }
    return self;
}

- (void) dealloc
{
    [_rdGrowlString release];
    [_rdGrowlTitle release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdGrowlString = [[coder decodeObjectForKey:@"action.growlText"] retain];
        _rdGrowlTitle = [[coder decodeObjectForKey:@"action.growlTitle"] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder;
{
    [super encodeWithCoder:coder];
    if (_rdGrowlString)
        [coder encodeObject:_rdGrowlString forKey:@"action.growlText"];
    if (_rdGrowlTitle)
        [coder encodeObject:_rdGrowlTitle forKey:@"action.growlTitle"];
}


#pragma mark Action Implementation

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Growl: Display Growl Notification";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Display text to the user using Growl.";
}

- (NSString *) actionDescription
{
    // TODO: Localize
    NSString *result = [NSString stringWithFormat:@"Display '%@' via Growl.",
                        _rdGrowlString ? _rdGrowlString : @""];
                        
    return result;
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeEvent)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    NSString *realTitle = [_rdGrowlTitle expandWithDataIn:[state data]];
    NSString *realText = [_rdGrowlString expandWithDataIn:[state data]];

    NSImage *growlIcon = [[state world] preferenceForKey:@"atlantis.info.icon"];
    NSData *iconData = nil;
    if (growlIcon) {
        iconData = [growlIcon TIFFRepresentation];
    }
        
    [GrowlApplicationBridge
        notifyWithTitle:realTitle 
            description:realText 
       notificationName:@"User Defined" 
               iconData:iconData
               priority:0 
               isSticky:NO 
           clickContext:[NSDictionary dictionaryWithObject:[[state spawn] viewPath] forKey:@"spawn"]];
           
    return NO;
}

#pragma mark Configuration Glue

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_Growl" owner:self];
    }
    
    [_rdActualText setDelegate:self];
    [_rdTitleText setDelegate:self];
    
    if (_rdGrowlString)
        [_rdActualText setStringValue:_rdGrowlString];
    else
        [_rdActualText setStringValue:@""];

    if (_rdGrowlTitle)
        [_rdTitleText setStringValue:_rdGrowlTitle];
    else
        [_rdTitleText setStringValue:@""];

    
    return _rdInternalConfigurationView;
}

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    if ([notification object] == _rdActualText) {
        [_rdGrowlString release];
        _rdGrowlString = [[_rdActualText stringValue] retain];
    }
    else if ([notification object] == _rdTitleText) {
        [_rdGrowlTitle release];
        _rdGrowlTitle = [[_rdTitleText stringValue] retain];
    }
}

@end
