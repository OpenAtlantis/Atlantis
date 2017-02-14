//
//  ToolbarConnection.m
//  Atlantis
//
//  Created by Rachel Blackman on 5/23/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "ToolbarConnection.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisSpawn.h"
#import <Lemuria/Lemuria.h>

@implementation ToolbarConnection

static NSImage *s_connectedImage = nil;
static NSImage *s_disconnectedImage = nil;

- (id) init
{
    self = [super init];
    if (self) {
        _rdToolbarItem = nil;
        _rdToolbarItemDict = [[NSMutableDictionary alloc] init];
        
        if (!s_connectedImage)
            s_connectedImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"Network"]];
        if (!s_disconnectedImage)
            s_disconnectedImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"stop"]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:) name:@"RDLemuriaViewSelectionDidChange" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(worldStatusChanged:) name:@"RDAtlantisConnectionDidConnectNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(worldStatusChanged:) name:@"RDAtlantisConnectionDidDisconnectNotification" object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_rdToolbarItemDict release];
    [_rdToolbarItem release];
    [super dealloc];
}

- (void) selectionChanged:(NSNotification *)notification
{
    NSObject *object = [notification object];
    if ([object isKindOfClass:[RDAtlantisSpawn class]]) {
        RDAtlantisSpawn *spawn = (RDAtlantisSpawn *)object;
        
        NSWindow *window = [[spawn view] window];
        if (window && [window isKindOfClass:[RDNestedViewWindow class]]) {
            RDNestedViewWindow *nestedWindow = (RDNestedViewWindow *)window;
            
            NSString *windowUID = [nestedWindow windowUID];
            if (windowUID) {
                NSToolbarItem *item = [_rdToolbarItemDict objectForKey:windowUID];

                if (item) {
                    if ([[spawn world] isConnected]) {
                        [item setImage:s_disconnectedImage];
                        [item setLabel:@"Disconnect"];
                    }
                    else {
                        [item setImage:s_connectedImage];
                        [item setLabel:@" Connect "];
                    }
                }
            }            
        }
    }
}

- (void) worldStatusChanged:(NSNotification *)notification
{    
    id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];
    
    if (curView && [(NSObject *)curView isKindOfClass:[RDAtlantisSpawn class]]) {
        RDAtlantisSpawn *spawn = (RDAtlantisSpawn *)curView;
        
        NSWindow *window = [[spawn view] window];
        if (window && [window isKindOfClass:[RDNestedViewWindow class]]) {
            RDNestedViewWindow *nestedWindow = (RDNestedViewWindow *)window;
            
            NSString *windowUID = [nestedWindow windowUID];
            if (windowUID) {
                NSToolbarItem *item = [_rdToolbarItemDict objectForKey:windowUID];
                
                if (item) {
                    if ([[spawn world] isConnected]) {
                        [item setImage:s_disconnectedImage];
                        [item setLabel:@"Disconnect"];
                    }
                    else {
                        [item setImage:s_connectedImage];
                        [item setLabel:@" Connect "];
                    }
                }
            }
        }            
    }
}


- (BOOL) validForState:(AtlantisState *) state
{
    if (state && [state world]) {
        NSString *windowUID = [state extraDataForKey:@"toolbar.windowUID"];
        if (windowUID) {
            RDNestedViewWindow *window = [[RDNestedViewManager manager] windowForUID:windowUID];
            if (window) {
                if ([window toolbar] && ([[window toolbar] displayMode] == NSToolbarDisplayModeLabelOnly))
                    return NO;
                    
                NSToolbarItem *item = [_rdToolbarItemDict objectForKey:windowUID];

                if (item) {
                    if ([[state world] isConnected]) {
                        [item setImage:s_disconnectedImage];
                        [item setLabel:@"Disconnect"];
                    }
                    else {
                        [item setImage:s_connectedImage];
                        [item setLabel:@" Connect "];
                    }
                }
            }
        }
        return YES;
    }
        
    return NO;
}

- (void) activateWithState:(AtlantisState *) state
{
    if ([state world] && ![[state world] isConnected]) {
        [[state world] connect];        
    }
    else if ([state world] && [[state world] isConnected]) {
        [[state world] disconnect];
    }    
}

- (NSToolbarItem *) toolbarItemForState:(AtlantisState *) state
{
    NSToolbarItem *item = nil;
    
    if (!state) {
        if (!_rdToolbarItem) {
            _rdToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:[self toolbarItemIdentifier]];
            [_rdToolbarItem setLabel:@" Connect "];
            [_rdToolbarItem setPaletteLabel:@"Connect/Disconnect"];
            [_rdToolbarItem setImage:s_connectedImage];
        }
        item = _rdToolbarItem;
    }
    else {
        NSString *windowUID = [state extraDataForKey:@"application.windowUID"];
        if (windowUID) {
            item = [_rdToolbarItemDict objectForKey:windowUID];
            if (!item) {
                item = [[NSToolbarItem alloc] initWithItemIdentifier:[self toolbarItemIdentifier]];
                [item setPaletteLabel:@"Connect/Disconnect"];

                [_rdToolbarItemDict setObject:item forKey:windowUID];
//                [item autorelease];
            }
            
            if (item) {
                if ([[state world] isConnected]) {
                    [item setImage:s_disconnectedImage];
                    [item setLabel:@"Disconnect"];
                }
                else {
                    [item setImage:s_connectedImage];                
                    [item setLabel:@" Connect "];
                }
            }
        }
    }

    return item;
}

- (NSString *) toolbarItemIdentifier
{
    return @"worldConnection";
}


@end
