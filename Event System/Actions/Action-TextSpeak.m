//
//  Action-TextSpeak.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/29/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-TextSpeak.h"
#import "NSStringExtensions.h"
#import "AtlantisState.h"


@implementation Action_TextSpeak


- (id) init
{
    self = [super init];
    if (self) {
        _rdString = nil;        
        _rdSpeaker = [[NSSpeechSynthesizer alloc] initWithVoice:nil];
    }
    return self;
}

- (id) initWithString:(NSString *) string
{
    self = [self init];
    if (self) {
        _rdString = [[string copyWithZone:nil] retain];
        _rdSpeaker = [[NSSpeechSynthesizer alloc] initWithVoice:nil];
    }
    return self;
}

- (void) dealloc
{
    [_rdSpeaker release];
    [_rdString release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdString = [[coder decodeObjectForKey:@"action.speechString"] retain];
        _rdSpeaker = [[NSSpeechSynthesizer alloc] initWithVoice:nil];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder;
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_rdString forKey:@"action.speechString"];
}


#pragma mark Action Implementation

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Speech: Speak a given string";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Speak a specific string aloud";
}

- (NSString *) actionDescription
{
    // TODO: Localize
    NSString *result = [NSString stringWithFormat:@"Speak '%@' aloud.",
                        _rdString ? _rdString : @""];
                        
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
    NSString *newString = [_rdString expandWithDataIn:[state data]];

    [_rdSpeaker stopSpeaking];
    [_rdSpeaker release];
    _rdSpeaker = [[NSSpeechSynthesizer alloc] initWithVoice:nil];

    [_rdSpeaker startSpeakingString:newString];
    
    return NO;
}

#pragma mark Configuration Glue

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_TextSpeak" owner:self];
    }
    
    [_rdActualText setDelegate:self];
    
    if (_rdString)
        [_rdActualText setStringValue:_rdString];
    else
        [_rdActualText setStringValue:@""];
    
    return _rdInternalConfigurationView;
}

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    [_rdString release];
    _rdString = [[_rdActualText stringValue] retain];
}



@end
