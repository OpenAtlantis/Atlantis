//
//  WorldDefaults.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldDefaults.h"

static NSImage *s_rdGlobe = nil;

@implementation WorldDefaults

- (id) init
{
    self = [super init];
    if (self) {
        _rdEditor = [[WorldConfigurationEditor alloc] initWithGlobalWorld];
        [[_rdEditor configView] setFrame:NSMakeRect(0,0,900,700)];
    }
    return self;
}

- (void) dealloc
{
    [_rdEditor release];
    [super dealloc];
}   

- (NSString *) preferencePaneName
{
    return @"World Defaults";
}

- (NSView *) preferencePaneView
{
    return [_rdEditor configView];
}

- (NSImage *) preferencePaneImage
{
    if (!s_rdGlobe)
        s_rdGlobe = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"connect"]];
    
    return s_rdGlobe;
}

- (void) preferencePaneCommit
{
    [_rdEditor commitAll];
}

@end
