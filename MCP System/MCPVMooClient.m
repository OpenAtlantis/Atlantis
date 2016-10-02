//
//  MCPVMooClient.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/11/08.
//  Copyright 2008 Riverdark Studios. All rights reserved.
//

#import "MCPVMooClient.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"
#import "MCPMessage.h"

@interface MCPVMooClient (Private)
- (void) screenUpdated:(NSNotification *)notification;
@end

@implementation MCPVMooClient

- (id) init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenUpdated:) name:@"RDAtlantisMainScreenDidChangeNotification" object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (float) minVersion:(NSString *)namespace
{
    return 1.0;
}

- (float) maxVersion:(NSString *)namespace
{
    return 1.0;
}

- (void) handleMessage:(MCPMessage *)message withState:(AtlantisState *)state
{
    if ([[message command] isEqualToString:@"disconnect"]) {
        NSString *reason = [message attributeText:@"reason"];
        
        if ([[state world] isConnected]) {
            if (reason)
                [[state world] disconnectWithMessage:reason];
            else
                [[state world] disconnect];
        }
    }
}

- (void) sendScreenSize:(RDAtlantisWorldInstance *)world
{
    NSString *mcpKey = [world mcpSessionKey];
    int width = [world mainScreenWidth];
    int height = [world mainScreenHeight];

    NSString *namespace = nil;
    if ([world supportsMcpPackage:@"dns-com-vmoo-client" version:1.0]) {
        namespace = @"dns-com-vmoo-client";
    }
    else if ([world supportsMcpPackage:@"dns-nl-vgmoo-client" version:1.0]) {
        namespace = @"dns-nl-vgmoo-client";
    }
    else if ([world supportsMcpPackage:@"dns-nl-vmoo-client" version:1.0]) {
        namespace = @"dns-nl-vmoo-client";
    }


    if (namespace) {
        MCPMessage *message = [[MCPMessage alloc] initWithNamespace:namespace command:@"screensize"];
        [message setSessionKey:mcpKey];
        
        [message addText:[NSString stringWithFormat:@"%d", width] toAttribute:@"cols"];
        [message addText:[NSString stringWithFormat:@"%d", height] toAttribute:@"rows"];        
        
        NSString *messageString = [message messageString];
        [world sendString:messageString];
        [message release];        
    }
}

- (void) screenUpdated:(NSNotification *)notification
{
    [self sendScreenSize:(RDAtlantisWorldInstance *)[notification object]];
}


- (void) negotiated:(AtlantisState *)state
{
    NSString *mcpKey = [[state world] mcpSessionKey];
    NSString *version = [[NSBundle mainBundle] localizedStringForKey:@"CFBundleShortVersionString" value:@"" table:@"InfoPlist"];
    NSString *releaseNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

    NSString *namespace = nil;
    if ([[state world] supportsMcpPackage:@"dns-com-vmoo-client" version:1.0]) {
        namespace = @"dns-com-vmoo-client";
    }
    else if ([[state world] supportsMcpPackage:@"dns-nl-vgmoo-client" version:1.0]) {
        namespace = @"dms-nl-vgmoo-client";
    }
    else if ([[state world] supportsMcpPackage:@"dns-nl-vmoo-client" version:1.0]) {
        namespace = @"dns-nl-vmoo-client";
    }

    if (namespace) {
        MCPMessage *message = [[MCPMessage alloc] initWithNamespace:namespace command:@"info"];
        [message setSessionKey:mcpKey];
        [message addText:@"Atlantis" toAttribute:@"name"];
        [message addText:version toAttribute:@"text-version"];
        [message addText:releaseNum toAttribute:@"internal-version"];
        NSString *messageString = [message messageString];
        [[state world] sendString:messageString];
        [message release];
    }
    
    [self sendScreenSize:[state world]];
}


@end
