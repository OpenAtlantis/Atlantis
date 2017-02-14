//
//  Condition-StringMatch.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/6/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-StringMatch.h"
#import "AtlantisState.h"
#import "NSStringExtensions.h"

@implementation Condition_StringMatch

#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdPattern = nil;
    }
    return self;
}

- (id) initWithPattern:(RDStringPattern *) pattern
{
    self = [self init];
    if (self) {
        _rdPattern = [pattern retain];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdPattern = [[coder decodeObjectForKey:@"text.pattern"] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    if (_rdPattern)
        [coder encodeObject:_rdPattern forKey:@"text.pattern"];
}

- (void) dealloc
{
    [_rdPattern release];
    [super dealloc];
}

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Text: Matches Pattern";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Incoming text matches a specific pattern.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeEvent)
        return [NSNumber numberWithBool:YES];

    return [NSNumber numberWithBool:NO];
}


- (NSString *) conditionDescription
{
    // TODO: Localize
    NSString *descString = [NSString stringWithFormat:@"The incoming string %@.",
                [_rdPattern description]];
                
    return descString;
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    NSString *string = [[state stringData] string];
    
    if (!string || ![string length])
        return NO;

    // Make a pattern, expanding for state data, just in case.
    NSString *realPatternMatch = [[_rdPattern pattern] expandWithDataIn:[state data]];    
    RDStringPattern *tempPattern = [RDStringPattern patternWithString:realPatternMatch type:[_rdPattern type]];
        
    BOOL result = [tempPattern patternMatchesString:string];
    
    if (result) {
        [state setExtraData:tempPattern forKey:@"RDLastPatternMatched"];
        
        if ([_rdPattern type] == RDPatternRegexp) {
            OGRegularExpression *regExp = 
                [[OGRegularExpression alloc] initWithString:realPatternMatch options:(OgreCaptureGroupOption|OgreFindLongestOption)];
            
            OGRegularExpressionMatch *regMatch = [regExp matchInString:string];
            
            if ([regMatch count]) {
                NSMutableArray *regArray = [[NSMutableArray alloc] init];
                
                int loop = 0;
                for (loop = 0; loop < [regMatch count]; loop++) {
                    NSRange tempRange = [regMatch rangeOfSubstringAtIndex:loop];
                    if ((tempRange.location != NSNotFound) && (tempRange.length != 0)) {
                        NSString *tempString = [regMatch substringAtIndex:loop];
                        if (tempString)
                            [regArray addObject:tempString];
                        else
                            [regArray addObject:@""];
                    }
                    else
                        [regArray addObject:@""];
                }
                
                [state setExtraData:regArray forKey:@"RDRegexpMatchData"];
                [state setExtraData:regMatch forKey:@"RDRegexpMatchInternalData"];
                [regArray release];
            }
            
            [regExp release];
        } 
    }
    return result;
}

#pragma mark Configuration Goo

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    int patternType = [_rdPattern type];
    
    RDStringPattern *pattern = [RDStringPattern patternWithString:[_rdActualText stringValue] type:patternType];
    
    [_rdPattern release];
    _rdPattern = [pattern retain];
}

- (void) patternTypeChanged:(id) sender
{
    int patternType = [_rdPatternType indexOfItem:[_rdPatternType selectedItem]];
    NSString *patternString = [_rdPattern pattern];
    
    if (!patternString)
        patternString = [NSString string];
    
    RDStringPattern *pattern = [RDStringPattern patternWithString:patternString type:patternType];
    
    [_rdPattern release];
    _rdPattern = [pattern retain];
}

- (NSView *) conditionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"CondConf_StringMatch" owner:self];
    }

    [_rdActualText setDelegate:self];
    [_rdPatternType setTarget:self];
    [_rdPatternType setAction:@selector(patternTypeChanged:)];
    
    if (_rdPattern) {
        [_rdActualText setStringValue:[_rdPattern pattern]];
        [_rdPatternType selectItemAtIndex:[_rdPattern type]];
    }

    return _rdInternalConfigurationView;
}


@end
