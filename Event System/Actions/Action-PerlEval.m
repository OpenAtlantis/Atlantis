//
//  Action-PerlEval.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/13/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-PerlEval.h"
#import "ScriptingDispatch.h"
#import "ScriptingEngine.h"
#import "RDAtlantisMainController.h"
#import "NSStringExtensions.h"
#import "AtlantisState.h"

@implementation Action_PerlEval


- (id) init
{
    self = [super init];
    if (self) {
        _rdString = nil;
        _rdLanguage = [[NSString alloc] initWithString:@"Perl"];
    }
    return self;
}

- (id) initWithString:(NSString *) string
{
    self = [self init];
    if (self) {
        _rdString = [[string copyWithZone:nil] retain];
        _rdLanguage = [[NSString stringWithString:@"Perl"] retain];
    }
    return self;
}

- (void) dealloc
{
    [_rdLanguage release];
    [_rdString release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdString = [[coder decodeObjectForKey:@"action.perlCode"] retain];
        _rdLanguage = [[coder decodeObjectForKey:@"action.language"] retain];
        if (!_rdLanguage) {
            _rdLanguage = [[NSString stringWithString:@"Perl"] retain];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder;
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_rdString forKey:@"action.perlCode"];
    [coder encodeObject:_rdLanguage forKey:@"action.language"];
}


#pragma mark Action Implementation

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Script: Execute script function.";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Execute a script function.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    return [NSNumber numberWithBool:YES];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    ScriptingDispatch *scriptSystem = [[RDAtlantisMainController controller] scriptDispatch];

    if (scriptSystem && _rdLanguage) {
        NSString *tempString = [_rdString expandWithDataIn:[state data]];
        [scriptSystem executeScript:tempString withState:state inLanguage:_rdLanguage];
    }

    return NO;
}

#pragma mark Configuration Glue

- (void) languageChanged:(id) sender
{
    [_rdLanguage release];
    _rdLanguage = [[_rdScriptLanguages titleOfSelectedItem] copy];
}

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_PerlEval" owner:self];
        [_rdActualText setDelegate:self];
        [_rdScriptLanguages setTarget:self];
        [_rdScriptLanguages setAction:@selector(languageChanged:)];
    }

    ScriptingDispatch *scriptSystem = [[RDAtlantisMainController controller] scriptDispatch];

    [_rdScriptLanguages removeAllItems];
    NSArray *languages = [scriptSystem languages];
    [_rdScriptLanguages addItemsWithTitles:languages];
    
    int index = 0;
    if (_rdLanguage)
        index = [languages indexOfObject:_rdLanguage];
    else {
        _rdLanguage = [[NSString alloc] initWithString:@"Perl"];
        index = [languages indexOfObject:@"Perl"];
    }
    
    [_rdScriptLanguages selectItemAtIndex:index];
        
    if (_rdString)
        [[_rdActualText textStorage] setAttributedString:[[NSAttributedString alloc] initWithString:_rdString]];
    else
        [[_rdActualText textStorage] setAttributedString:[[NSAttributedString alloc] init]];

    [_rdActualText setFont:[NSFont userFixedPitchFontOfSize:9.0f]];
    
    return _rdInternalConfigurationView;
}

- (void) textDidEndEditing:(NSNotification *) notification
{
    [_rdString release];
    _rdString = [[NSString stringWithString:[[_rdActualText textStorage] string]] retain];
}

@end
