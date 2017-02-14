//
//  Action-LineClass.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/11/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-LineClass.h"
#import "AtlantisState.h"
#import "NSStringExtensions.h"

@implementation Action_LineClass

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
        _rdString = [[coder decodeObjectForKey:@"action.lineClass"] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder;
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_rdString forKey:@"action.lineClass"];
}


#pragma mark Action Implementation

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Text: Mark line as a specific class.";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Set a class on a given line, like 'page' or something.  Useful mostly for CSS-styled HTML logfiles.";
}

- (NSString *) actionDescription
{
    // TODO: Localize
    NSString *result = [NSString stringWithFormat:@"Mark the current line as a '%@' line.",
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
    
    NSMutableAttributedString *realString = [state stringData];
    [realString addAttribute:@"RDLineClass" value:newString range:NSMakeRange(0,[realString length])];
    
    return NO;
}

#pragma mark Configuration Glue

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_LineClass" owner:self];
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
