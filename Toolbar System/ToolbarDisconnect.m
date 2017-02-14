//
//  ToolbarDisconnect.m
//  Atlantis
//
//  Created by Rachel Blackman on 5/26/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ToolbarDisconnect.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation ToolbarDisconnect

- (id) init
{
    self = [super init];
    if (self) {
        _rdToolbarItem = nil;
        _rdToolbarItemDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [_rdToolbarItemDict release];
    [_rdToolbarItem release];
    [super dealloc];
}

- (BOOL) validForState:(AtlantisState *) state
{
    if ([state world] && [[state world] isConnected])
        return YES;
        
    return NO;
}

- (void) activateWithState:(AtlantisState *) state
{
    if ([state world] && [[state world] isConnected])
        [[state world] disconnectWithMessage:@"User disconnected."];        
    
}

- (NSToolbarItem *) toolbarItemForState:(AtlantisState *) state
{
    NSToolbarItem *item = nil;
    BOOL needsInit = NO;
    
    if (!state) {
        if (!_rdToolbarItem) {
            _rdToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:[self toolbarItemIdentifier]];
            needsInit = YES;
        }
        item = _rdToolbarItem;
    }
    else {
        NSString *windowUID = [state extraDataForKey:@"application.windowUID"];
        if (windowUID) {
            item = [_rdToolbarItemDict objectForKey:windowUID];
            if (!item) {
                item = [[NSToolbarItem alloc] initWithItemIdentifier:[self toolbarItemIdentifier]];
                needsInit = YES;
                [_rdToolbarItemDict setObject:item forKey:windowUID];
//                [item autorelease];
            }
        }
    }

    if (needsInit) {
        [item setLabel:@"Disconnect"];
        [item setPaletteLabel:@"Disconnect World"];
        [item setImage:[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"DeleteTBIcon"]]];
    }

    return item;
}

- (NSString *) toolbarItemIdentifier
{
    return @"worldDisconnect";
}



@end
