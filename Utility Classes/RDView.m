//
//  RDView.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDView.h"

@interface RDViewDelegate
- (void) viewMovedToWindow:(NSWindow *) window;
@end

@implementation RDView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _rdDelegate = nil;
    }
    return self;
}

- (id) delegate
{
    return _rdDelegate;
}

- (void) setDelegate:(id) delegate
{
    _rdDelegate = delegate;
}

- (void) changeFont:(id) sender
{
    if ([self delegate]) {
        if ([[self delegate] respondsToSelector:@selector(changeFont:)]) {
            [[self delegate] changeFont:sender];
        }
    }
}

- (void)viewDidMoveToWindow
{
    if ([self delegate]) {
        if ([[self delegate] respondsToSelector:@selector(viewMovedToWindow:)]) {
            [[self delegate] viewMovedToWindow:[self window]];
        }
    }
}
@end
