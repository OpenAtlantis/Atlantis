//
//  ToolbarWorldStatus.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ToolbarWorldStatus.h"
#import "AtlantisState.h"
#import "ToolbarWorldStatusController.h"
#import "RDAtlantisSpawn.h"
#import "RDAtlantisWorldInstance.h"
#import <Lemuria/Lemuria.h>

@interface ToolbarWorldStatus (Private)
- (void) updateTimerFired:(NSTimer *) timer;
- (void) selectionChanged:(NSNotification *) notification;
@end

@implementation ToolbarWorldStatus


- (id) init
{
    self = [super init];
    if (self) {
        _rdToolbarItem = nil;
        _rdToolbarItemDict = [[NSMutableDictionary alloc] init];
        _rdToolbarControllerDict = [[NSMutableDictionary alloc] init];
        
        _rdUpdateTimer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:YES] retain];    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:) name:@"RDLemuriaViewSelectionDidChange" object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_rdUpdateTimer invalidate];
    [_rdUpdateTimer release];
    [_rdToolbarControllerDict release];
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
                ToolbarWorldStatusController *controller = [_rdToolbarControllerDict objectForKey:windowUID];
            
                if (controller) {
                    [controller updateForWorld:[spawn world]];
                }
            }            
        }
    }
}

- (BOOL) validForState:(AtlantisState *) state
{
    if (state) {
        NSString *windowUID = [state extraDataForKey:@"toolbar.windowUID"];
        if (windowUID) {
            RDNestedViewWindow *window = [[RDNestedViewManager manager] windowForUID:windowUID];
            if (window) {
                if ([window toolbar] && ([[window toolbar] displayMode] == NSToolbarDisplayModeLabelOnly))
                    return NO;
                    
                ToolbarWorldStatusController *controller = [_rdToolbarControllerDict objectForKey:windowUID];
            
                if (controller) {
                    id <RDNestedViewDescriptor> view = [[window displayView] selectedView];
                    if ([(NSObject *)view isKindOfClass:[RDAtlantisSpawn class]]) { 
                        [controller updateForWorld:[(RDAtlantisSpawn *)view world]];
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
    // Our view delegate handles this stuff, whee
}

- (NSToolbarItem *) toolbarItemForState:(AtlantisState *)state
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
        NSString *windowUID = [state extraDataForKey:@"toolbar.windowUID"];
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
        ToolbarWorldStatusController *controller = [[ToolbarWorldStatusController alloc] init];      
        NSString *windowUID = nil;
        
        if (state)
            windowUID = [state extraDataForKey:@"toolbar.windowUID"];
        
        if (!windowUID)
            windowUID = @"palette";
        
        if (windowUID)
            [_rdToolbarControllerDict setObject:controller forKey:windowUID];  
    
        [item setLabel:@"Status"];
        [item setPaletteLabel:@"Current World Status"];
        [item setView:[controller contentView]];
        
        [item setMinSize:[[controller contentView] frame].size];
        [item setMaxSize:[[controller contentView] frame].size];
        
        [controller release];
    }
    
    return item;
}

- (NSString *) toolbarItemIdentifier
{
    return @"worldStatus";
}

- (void) updateAll
{
    NSArray *windows = [NSApp windows];
    NSEnumerator *windowEnum = [windows objectEnumerator];
    NSWindow *windowWalk = nil;
    
    while (windowWalk = [windowEnum nextObject]) {
        if ([windowWalk isVisible] && [windowWalk isKindOfClass:[RDNestedViewWindow class]]) {
            NSString *windowUID = [(RDNestedViewWindow *)windowWalk windowUID];
            
            ToolbarWorldStatusController *controller = [_rdToolbarControllerDict objectForKey:windowUID];
            if (controller) {
                RDAtlantisWorldInstance *world = nil;
                RDAtlantisSpawn *spawn = nil;
                
                id <RDNestedViewDescriptor> curView = [[(RDNestedViewWindow *)windowWalk displayView] selectedView];
                
                if (curView && [(NSObject *)curView isKindOfClass:[RDAtlantisSpawn class]]) {
                    spawn = (RDAtlantisSpawn *)curView;
                }
                
                if (spawn) {
                    world = [spawn world];
                }

                [controller updateForWorld:world];
            }
        }
    }
}

- (void) updateTimerFired:(NSTimer *) timer
{
    [self updateAll];
}

@end
