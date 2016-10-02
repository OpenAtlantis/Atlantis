//
//  Action-Substitute.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-Substitute.h"
#import <OgreKit/OgreKit.h>
#import "NSStringExtensions.h"
#import "AtlantisState.h"


@implementation Action_Substitute


#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdReplaceWith = nil;
        _rdRegister = 0;
    }
    return self;
}

- (void) dealloc
{
    [_rdReplaceWith release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdReplaceWith = [[coder decodeObjectForKey:@"action.substitution"] retain];
        _rdRegister = [coder decodeIntForKey:@"action.register"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder;
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_rdReplaceWith forKey:@"action.substitution"];
    [coder encodeInt:_rdRegister forKey:@"action.register"];
}

#pragma mark Action Implementation

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Text: Replace Regexp Register With";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Replace the contents of a register in the last Regexp match with a given string.";
}

- (NSString *) actionDescription
{
    // TODO: Localize
    NSString *result = [NSString stringWithFormat:@"Replace register '%d' with '%@'.",
                        _rdRegister, _rdReplaceWith ? _rdReplaceWith : @""];
                        
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
    NSString *newString = [_rdReplaceWith expandWithDataIn:[state data]];

    OGRegularExpressionMatch *regMatch = [state extraDataForKey:@"RDRegexpMatchInternalData"];
    if (regMatch) {
        NSRange matchRange = [regMatch rangeOfSubstringAtIndex:_rdRegister];
        if (matchRange.location != NSNotFound) {
            [[state stringData] replaceCharactersInRange:matchRange withString:newString];
        }
    }

    return NO;
}

#pragma mark Configuration Glue

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_Substitution" owner:self];
    }
    
    [_rdRegisterField setDelegate:self];
    [_rdSubstitutionField setDelegate:self];
    
    if (_rdReplaceWith)
        [_rdSubstitutionField setStringValue:_rdReplaceWith];
    else
        [_rdSubstitutionField setStringValue:@""];

    [_rdRegisterField setIntValue:_rdRegister];
    
    return _rdInternalConfigurationView;
}

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    if ([notification object] == _rdRegisterField) {
        _rdRegister = [_rdRegisterField intValue];
    }
    else if ([notification object] == _rdSubstitutionField) {
        [_rdReplaceWith release];
        _rdReplaceWith = [[_rdSubstitutionField stringValue] copy];
    }
}


@end
