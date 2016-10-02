//
//  Condition-LineClass.m
//  Atlantis
//
//  Created by Rachel Blackman on 6/20/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-LineClass.h"
#import "AtlantisState.h"

@implementation Condition_LineClass

#pragma Event System Protocol

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Text: Line is Class";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"The current line is of a specific class.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeEvent)
        return [NSNumber numberWithBool:YES];

    return [NSNumber numberWithBool:NO];
}


#pragma mark Execution

- (id) init
{
    self = [super init];
    if (self) {
        _rdLineClass = nil;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdLineClass = [[coder decodeObjectForKey:@"line.class"] retain];
        _rdInternalConfigurationView = nil;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    if (_rdLineClass)
        [coder encodeObject:_rdLineClass forKey:@"line.class"];
}


- (BOOL) isTrueForState:(AtlantisState *) state
{
    NSRange effRange;
    NSAttributedString *stringData = [state stringData];
    
    if (!stringData || ![[stringData string] length])
        return NO;
    
    NSDictionary *attrs = [stringData attributesAtIndex:0 effectiveRange:&effRange];
    NSString *customClass = [attrs objectForKey:@"RDLineClass"];

    if (!_rdLineClass || !customClass)
        return NO;
        
    return [customClass isEqualToString:_rdLineClass];
}

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    [_rdLineClass release];
    _rdLineClass = [[_rdLineClassField stringValue] retain];
}

- (NSView *) conditionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"CondConf_LineClass" owner:self];
    }

    [_rdLineClassField setDelegate:self];
    if (_rdLineClass) 
        [_rdLineClassField setStringValue:_rdLineClass];
    
    return _rdInternalConfigurationView;
}


@end
