//
//  NetworkPreferences.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/20/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "NetworkPreferences.h"

static NSImage *s_rdNetworkImage = nil;

@implementation NetworkPreferences

- (id) init
{
    self = [super init];
    return self;
}

- (NSString *) preferencePaneName
{
    return @"Networking";
}

- (void) controlTextDidEndEditing:(NSNotification *)notification
{
    NSTextField *field = [notification object];
    
    NSString *value = [field stringValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (field == _rdProxyHost) {
        [defaults setObject:value forKey:@"atlantis.network.proxyHost"];
    }
    else if (field == _rdProxyUser) {
        [defaults setObject:value forKey:@"atlantis.network.proxyUser"];
    }
    else if (field == _rdProxyPass) {
        [defaults setObject:value forKey:@"atlantis.network.proxyPass"];
    }
    else if (field == _rdProxyPort) {
        [defaults setInteger:[value intValue] forKey:@"atlantis.network.proxyPort"];
    }
}

- (void) proxyTypeChanged:(id) sender
{
    int proxyType = [_rdProxyType indexOfItem:[_rdProxyType selectedItem]];
    
    switch (proxyType) {
        case 0:
            [_rdProxyHost setEnabled:NO];
            [_rdProxyPort setEnabled:NO];
            [_rdProxyUser setEnabled:NO];
            [_rdProxyPass setEnabled:NO];
            break;
            
        case 1:
        case 2:
            [_rdProxyHost setEnabled:YES];
            [_rdProxyPort setEnabled:YES];
            [_rdProxyUser setEnabled:YES];
            [_rdProxyPass setEnabled:YES];
            break;
            
        case 3:
            [_rdProxyHost setEnabled:YES];
            [_rdProxyPort setEnabled:YES];
            [_rdProxyUser setEnabled:NO];
            [_rdProxyPass setEnabled:NO];
            break;
    }

    [[NSUserDefaults standardUserDefaults] setInteger:proxyType forKey:@"atlantis.network.proxyType"];
}

- (void) networkDropChanged:(id) sender
{
    BOOL result = NO;
    
    if ([_rdDropNetOnLoss state] == NSOnState) {
        result = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:@"atlantis.network.drop"];
}

- (void) networkCompressChanged:(id) sender
{
    BOOL result = NO;
    
    if ([_rdCompressNet state] == NSOnState) {
        result = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:result forKey:@"atlantis.network.compress"];
}

- (NSView *) preferencePaneView
{
    if (!_rdConfigView) {
        [NSBundle loadNibNamed:@"NetworkPreferences" owner:self];
        
        [_rdProxyHost setDelegate:self];
        [_rdProxyPort setDelegate:self];
        [_rdProxyUser setDelegate:self];
        [_rdProxyPass setDelegate:self];
        [_rdProxyType setTarget:self];
        [_rdProxyType setAction:@selector(proxyTypeChanged:)];

        [_rdDropNetOnLoss setTarget:self];
        [_rdDropNetOnLoss setAction:@selector(networkDropChanged:)];
        [_rdCompressNet setTarget:self];
        [_rdCompressNet setAction:@selector(networkCompressChanged:)];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int proxyType = [defaults integerForKey:@"atlantis.network.proxyType"];
    NSString *proxyHost = [defaults stringForKey:@"atlantis.network.proxyHost"];
    int proxyPort = [defaults integerForKey:@"atlantis.network.proxyPort"];
    NSString *proxyUser = [defaults stringForKey:@"atlantis.network.proxyUser"];
    NSString *proxyPass = [defaults stringForKey:@"atlantis.network.proxyPass"];
    
    [_rdProxyType selectItemAtIndex:proxyType];

    if (proxyPort) {
        [_rdProxyPort setIntValue:proxyPort];
    }
    else {
        [_rdProxyPort setStringValue:@""];
    }
    
    if (proxyHost) {
        [_rdProxyHost setStringValue:proxyHost];
    }
    else {
        [_rdProxyHost setStringValue:@""];
    }
    
    if (proxyUser) {
        [_rdProxyUser setStringValue:proxyUser];
    }
    else {
        [_rdProxyUser setStringValue:@""];
    }
    
    if (proxyPass) {
        [_rdProxyPass setStringValue:proxyPass];
    }
    else {
        [_rdProxyPass setStringValue:@""];
    }
    
    switch (proxyType) {
        case 0:
            [_rdProxyHost setEnabled:NO];
            [_rdProxyPort setEnabled:NO];
            [_rdProxyUser setEnabled:NO];
            [_rdProxyPass setEnabled:NO];
            break;
            
        case 1:
        case 2:
            [_rdProxyHost setEnabled:YES];
            [_rdProxyPort setEnabled:YES];
            [_rdProxyUser setEnabled:YES];
            [_rdProxyPass setEnabled:YES];
            break;
            
        case 3:
            [_rdProxyHost setEnabled:YES];
            [_rdProxyPort setEnabled:YES];
            [_rdProxyUser setEnabled:NO];
            [_rdProxyPass setEnabled:NO];
            break;
    }
    
    BOOL netDrop = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.network.drop"];
    if (netDrop)
        [_rdDropNetOnLoss setState:NSOnState];
    else
        [_rdDropNetOnLoss setState:NSOffState];

    BOOL netMCCP = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.network.compress"];
    if (netMCCP)
        [_rdCompressNet setState:NSOnState];
    else
        [_rdCompressNet setState:NSOffState];    
    
    [[_rdConfigView window] performSelector:@selector(makeFirstResponder:) withObject:_rdProxyType afterDelay:0.2];

    return _rdConfigView;
}

- (NSImage *) preferencePaneImage
{
    if (!s_rdNetworkImage)
        s_rdNetworkImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"Network"]];
    
    return s_rdNetworkImage;
}

- (void) preferencePaneCommit
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
