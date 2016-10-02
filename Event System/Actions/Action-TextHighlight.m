//
//  Action-TextHighlight.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-TextHighlight.h"
#import "RDStringPattern.h"
#import "AtlantisState.h"

@implementation Action_TextHighlight

#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdFgColor = nil;
        _rdBgColor = nil;
    }
    return self;
}

- (id) initWithFgColor:(NSColor *)fgColor bgColor:(NSColor *)bgColor
{
    self = [self init];
    if (self) {
        if (fgColor)
            _rdFgColor = [fgColor retain];
        if (bgColor)
            _rdBgColor = [bgColor retain];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSColor *fg = [coder decodeObjectForKey:@"highlight.foreground"];
        NSColor *bg = [coder decodeObjectForKey:@"highlight.background"];
        
        if (fg)
            _rdFgColor = [fg retain];
        else
            _rdFgColor = nil;
        
        if (bg)
            _rdBgColor = [bg retain];
        else
            _rdBgColor = nil;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    if (_rdFgColor)
        [coder encodeObject:_rdFgColor forKey:@"highlight.foreground"];
    if (_rdBgColor)
        [coder encodeObject:_rdBgColor forKey:@"highlight.background"];
}

- (void) dealloc
{
    [_rdFgColor release];
    [_rdBgColor release];
    [super dealloc];
}

#pragma mark Configuration Glue

- (void) fgColorActive:(id) sender
{
    if ([_rdFgColorActive state] == NSOnState) {
        [_rdFgColorPicker setEnabled:YES];    
        _rdFgColor = [[_rdFgColorPicker color] retain];
    }
    else {
        [_rdFgColorPicker setEnabled:NO];
        _rdFgColor = nil;
    }
}

- (void) bgColorActive:(id) sender
{
    if ([_rdBgColorActive state] == NSOnState) {
        [_rdBgColorPicker setEnabled:YES];    
        _rdBgColor = [[_rdBgColorPicker color] retain];
    }
    else {
        [_rdBgColorPicker setEnabled:NO];
        _rdBgColor = nil;
    }
}

- (void) fgColorChanged:(id) sender
{
    if ([_rdFgColorActive state] == NSOnState) {
        _rdFgColor = [[_rdFgColorPicker color] retain];
    }
}

- (void) bgColorChanged:(id) sender
{
    if ([_rdBgColorActive state] == NSOnState) {
        _rdBgColor = [[_rdBgColorPicker color] retain];
    }
}

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_HighlightText" owner:self];
    }

    if (_rdFgColor) {
        [_rdFgColorActive setState:NSOnState];
        [_rdFgColorPicker setEnabled:YES];
        [_rdFgColorPicker setColor:_rdFgColor];
    }
    else {
        [_rdFgColorActive setState:NSOffState];
        [_rdFgColorPicker setEnabled:NO];
    }
    
    if (_rdBgColor) {
        [_rdBgColorActive setState:NSOnState];
        [_rdBgColorPicker setEnabled:YES];
        [_rdBgColorPicker setColor:_rdBgColor];
    }
    else {
        [_rdBgColorActive setState:NSOffState];
        [_rdBgColorPicker setEnabled:NO];
    }
    
    /*    
    [_rdBgColorPicker setTarget:self];
    [_rdFgColorPicker setTarget:self];
    [_rdBgColorActive setTarget:self];
    [_rdFgColorActive setTarget:self];
    
    [_rdBgColorPicker setAction:@selector(bgColorChanged:)];
    [_rdFgColorPicker setAction:@selector(fgColorChanged:)];
    [_rdBgColorActive setAction:@selector(bgColorActive:)];
    [_rdFgColorActive setAction:@selector(fgColorActive:)];    
    */
    
    return _rdInternalConfigurationView;
}



#pragma mark Action Implementation

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Text: Highlight Last Matched";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Highlight matched text in specific colors.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeEvent)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *)state
{
    NSRange resultRange;
    
    RDStringPattern *pattern = [state extraDataForKey:@"RDLastPatternMatched"];
    NSMutableAttributedString *string = [state stringData];
    
    if (!string)
        return NO;
    
    if (pattern) {    
        resultRange = [pattern stringMatch:[string string]];
    }
    else {
        resultRange = NSMakeRange(0,[string length]);
    }
    
    while (resultRange.length) {
        
        if (_rdFgColor) {
            [string addAttribute:NSForegroundColorAttributeName value:_rdFgColor range:resultRange];
        }
        
        if (_rdBgColor) {
            [string addAttribute:NSBackgroundColorAttributeName value:_rdBgColor range:resultRange];
        }                

        if (pattern)
            resultRange = [pattern stringMatch:nil];
        else
            resultRange = NSMakeRange(0,0);
    }
    
    return NO;
}

@end
