//
//  ToolbarWorldStatusController.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ToolbarWorldStatusController.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisSpawn.h"
#import <Lemuria/Lemuria.h>

@implementation ToolbarWorldStatusController


- (id) init
{
    self = [super init];
    if (self) {
        if ([NSBundle loadNibNamed:@"ToolbarStatus" owner:self]) {
        
        }    
    }
    return self;
}

- (NSView *) contentView
{
    return _rdStatusView;
}

- (void) buttonPushed:(id) sender
{
    RDAtlantisWorldInstance *world = nil;
    RDAtlantisSpawn *spawn = nil;
    
    id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];

    if (curView && [(NSObject *)curView isKindOfClass:[RDAtlantisSpawn class]]) {
        spawn = (RDAtlantisSpawn *)curView;
    }
    
    if (spawn) {
        world = [spawn world];
    }

    if (sender == _rdSSLButton) {
        if (world) {
            if ([world isSSL]) {
                [sender setState:NSOnState];
            }
            else {
                [sender setState:NSOffState];
            }
        }
        else
            [sender setState:NSOffState];
    }

    if (sender == _rdMCCPButton) {
        if (world) {
            if ([world isCompressing]) {
                [sender setState:NSOnState];
            }
            else {
                [sender setState:NSOffState];
            }
        }
        else
            [sender setState:NSOffState];
    }

    if (sender == _rdMCPButton) {
        if (world) {
            if ([world supportsMCP]) {
                [sender setState:NSOnState];
            }
            else {
                [sender setState:NSOffState];
            }
        }
        else
            [sender setState:NSOffState];
    }
}

- (void) updateButton:(id) button forValue:(BOOL) value
{
    if (([button state] == NSOnState) != value) {
        [button setState:(value ? NSOnState : NSOffState)];
    }
}

- (void) updateForWorld:(RDAtlantisWorldInstance *)world
{
    if (world && [world isConnected]) {
        if ([NSApp isActive]) {
            [self updateButton:_rdSSLButton forValue:[world isSSL]];
            [self updateButton:_rdMCCPButton forValue:[world isCompressing]];
            [self updateButton:_rdMCPButton forValue:[world supportsMCP]]; 
        }

        NSDate *now = [NSDate date];
        NSDate *then = [world connectedSince];
        
        NSString *connectString = @"";
        
        if (then) {
            NSTimeInterval connectedFor = [now timeIntervalSinceDate:then];
            unsigned int total = connectedFor;
            unsigned char secs = total % 60;
            total = total / 60;
            unsigned char mins = total % 60;
            total = total / 60;
        
            connectString = [NSString stringWithFormat:@"%02d:%02d:%02d", total, mins, secs];
        }
        else {
            connectString = @"00:00:00";
        }
        
        [_rdConnectedString setStringValue:connectString];         
    }
    else {
        [_rdSSLButton setState:NSOffState];
        [_rdMCCPButton setState:NSOffState];
        [_rdMCPButton setState:NSOffState];
        [_rdConnectedString setStringValue:@"offline"];
    }
}

- (void) updateForState:(AtlantisState *)state
{
    [self updateForWorld:[state world]];
}

@end
