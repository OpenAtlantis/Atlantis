//
//  Condition-VariableMatch.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/19/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-VariableMatch.h"
#import "RDStringPattern.h"
#import "AtlantisState.h"
#import "NSStringExtensions.h"
#import "RDAtlantisMainController.h"

@implementation Condition_VariableMatch

#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdPattern = nil;
        _rdVariableName = nil;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdPattern = [[coder decodeObjectForKey:@"variable.pattern"] retain];
        _rdVariableName = [[coder decodeObjectForKey:@"variable.name"] retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    if (_rdPattern)
        [coder encodeObject:_rdPattern forKey:@"variable.pattern"];
    if (_rdVariableName)
        [coder encodeObject:_rdVariableName forKey:@"variable.name"];
}

- (void) dealloc
{
    [_rdVariableName release];
    [_rdPattern release];
    [super dealloc];
}

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Variable: Matches Pattern";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Contents of a given variable match a specific pattern.";
}

- (NSString *) conditionDescription
{
    // TODO: Localize
    NSString *descString = [NSString stringWithFormat:@"The contents of %@ %@.",
                _rdVariableName, [_rdPattern description]];
                
    return descString;
}

#pragma mark Execution

- (BOOL) isTrueForState:(AtlantisState *) state
{
    NSString *string = [state extraDataForKey:_rdVariableName];
    
    if (!string) {
        if ([[_rdVariableName substringWithRange:NSMakeRange(0,8)] isEqualToString:@"command."]) {
            NSDictionary *commandParams = [state extraDataForKey:@"RDCommandParams"];    
            NSString *cmdData = [commandParams objectForKey:@"RDOptsMainData"];                                            
			NSString *cmdFull = [commandParams objectForKey:@"RDOptsFullString"];                                            
            NSString *restOfString = [_rdVariableName substringFromIndex:8];
            
            if ([restOfString isEqualToString:@"data"]) {
                string = cmdData ? cmdData : @"";
            }
			else if ([restOfString isEqualToString:@"fulltext"]) {
				string = cmdFull ? cmdFull : @"";
			}
            else {
                string = [commandParams objectForKey:restOfString];
                if (!string || [[string description] isEqualToString:@""]) {
                    string = @"0";
                }
            }                        
        }
        else if ([[_rdVariableName substringWithRange:NSMakeRange(0,5)] isEqualToString:@"temp."]) {
            NSString *restOfString = [_rdVariableName substringFromIndex:5];
            
            if ([restOfString length]) {
                string = [[RDAtlantisMainController controller] tempStateVarForKey:restOfString];
            }
        }
    }
    
    if (!string)
        return NO;
        
    // Make a pattern, expanding for state data, just in case.
    NSString *realPatternMatch = [[_rdPattern pattern] expandWithDataIn:[state data]];    
    RDStringPattern *tempPattern = [RDStringPattern patternWithString:realPatternMatch type:[_rdPattern type]];
        
    BOOL result = [tempPattern patternMatchesString:string];

    return result;
}

#pragma mark Configuration Goo

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    if ([notification object] == _rdActualText) {
        int patternType = [_rdPattern type];
        
        RDStringPattern *pattern = [RDStringPattern patternWithString:[_rdActualText stringValue] type:patternType];
        
        [_rdPattern release];
        _rdPattern = [pattern retain];
    }
    else if ([notification object] == _rdActualVariable) {
        [_rdVariableName release];
        _rdVariableName = [[_rdActualVariable stringValue] retain];
    }
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
        [NSBundle loadNibNamed:@"CondConf_VariableMatch" owner:self];
    }

    [_rdActualText setDelegate:self];
    [_rdActualVariable setDelegate:self];
    [_rdPatternType setTarget:self];
    [_rdPatternType setAction:@selector(patternTypeChanged:)];
    
    if (_rdPattern) {
        [_rdActualText setStringValue:[_rdPattern pattern]];
        [_rdPatternType selectItemAtIndex:[_rdPattern type]];
    }
    if (_rdVariableName) {
        [_rdActualVariable setStringValue:_rdVariableName];
    }

    return _rdInternalConfigurationView;
}


@end
