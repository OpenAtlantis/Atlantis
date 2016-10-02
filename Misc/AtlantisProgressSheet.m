//
//  AtlantisProgressSheet.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/14/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "AtlantisProgressSheet.h"


@implementation AtlantisProgressSheet

- (id) init
{
    self = [super init];
    if (self) {
        [NSBundle loadNibNamed:@"AtlantisProgressSheet" owner:self];
        _rdOpen = NO;
        _rdCancelled = NO;
        _rdSheetSession = nil;
    }
    return self;
}

- (void) dealloc
{
    if (_rdOpen)
        [self closePanel];
    [super dealloc];
}

- (void) openPanel:(NSString *)label withMaxValue:(double)maxValue
{
    if (maxValue != -1) {
        [_rdProgressBar setMinValue:0];
        [_rdProgressBar setMaxValue:maxValue];
        [_rdProgressBar setIndeterminate:NO];
    }
    else {
        [_rdProgressBar setIndeterminate:YES];
    }
    [_rdProgressLabel setStringValue:label];
 
    _rdSheetSession = [NSApp beginModalSessionForWindow:[NSApp keyWindow]];
 
    [NSApp beginSheet:_rdProgressSheet modalForWindow:[NSApp keyWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    _rdOpen = YES;
}

- (void) setMaxValue:(double) maxValue
{
    if (maxValue != -1) {
        [_rdProgressBar setMinValue:0];
        [_rdProgressBar setMaxValue:maxValue];
        [_rdProgressBar setIndeterminate:NO];
    }
    else {
        [_rdProgressBar setIndeterminate:YES];
    }
}

- (void) setLabel:(NSString *) label
{
    [_rdProgressLabel setStringValue:label];
}

- (void) setProgress:(double) newValue
{
    [_rdProgressBar setDoubleValue:newValue];
}

- (void) closePanel
{
    [NSApp endModalSession:_rdSheetSession];
    [NSApp endSheet:_rdProgressSheet];
    [_rdProgressSheet orderOut:self];
    _rdSheetSession = nil;
    _rdOpen = NO;
}

- (BOOL) modalRun
{
    [NSApp runModalSession:_rdSheetSession];
    return _rdCancelled;
} 

- (IBAction) cancelButton:(id) sender
{
    _rdCancelled = YES;
}

@end
