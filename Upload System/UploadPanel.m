//
//  UploadPanel.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/28/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "UploadPanel.h"
#import "AtlantisState.h"
#import "CodeUploader.h"
#import "TextfileUploader.h"
#import "RDAtlantisWorldInstance.h"

@implementation UploadPanel

- (id) initWithState:(AtlantisState *)state
{
    self = [super init];
    if (self) {
        _rdState = [state retain];
        _rdPanel = nil;
    }
    return self;
}

- (void) dealloc
{
    [_rdState release];
    [super dealloc];
}

- (void) codeToggled:(id) sender
{
    BOOL enabled = YES;
    
    if ([_rdCodeButton state] == NSOnState) {
        enabled = NO;
    }
    
    [_rdDelayField setEnabled:enabled];
    [_rdPrefixField setEnabled:enabled];
    [_rdSuffixField setEnabled:enabled];
}

- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
    if (returnCode == NSOKButton) {
        NSString *filename = [sheet filename];
        if (!filename) {
            return;
        }
        [[NSUserDefaults standardUserDefaults] setObject:[sheet directory] forKey:@"atlantis.upload.directory"];
        if ([_rdCodeButton state] == NSOnState) {
            CodeUploader *uploader = [[CodeUploader alloc] initWithFile:filename forWorld:[_rdState world] atInterval:1 withPrefix:nil suffix:nil];

            if (uploader)    
                [[_rdState world] outputStatus:[NSString stringWithFormat:@"Uploading '%@'", filename] toSpawn:[_rdState spawnPath]];
            else
                [[_rdState world] outputStatus:@"Error in upload engine!" toSpawn:[_rdState spawnPath]];        
        }
        else {
            unsigned int delay = [_rdDelayField intValue];
            NSString *prefix = [_rdPrefixField stringValue];
            NSString *suffix = [_rdSuffixField stringValue];
            
            TextfileUploader *uploader = [[TextfileUploader alloc] initWithFile:filename forWorld:[_rdState world] atInterval:delay withPrefix:prefix suffix:suffix];

            if (uploader)    
                [[_rdState world] outputStatus:[NSString stringWithFormat:@"Uploading '%@'", filename] toSpawn:[_rdState spawnPath]];
            else
                [[_rdState world] outputStatus:@"Error in upload engine!" toSpawn:[_rdState spawnPath]];        
        }
    }
}

- (BOOL) openPanel
{
    if (!_rdState)
        return NO;
    
    if (![_rdState world])
        return NO;
        
    if (![[_rdState world] isConnected])
        return NO;
        
    if ([NSBundle loadNibNamed:@"UploadPanel" owner:self]) {
        [_rdPrefixField setStringValue:@""];
        [_rdSuffixField setStringValue:@""];
        [_rdDelayField setStringValue:@"1"];
        [_rdCodeButton setState:NSOffState];
    }
    
    _rdPanel = [NSOpenPanel openPanel];
    [_rdPanel setAccessoryView:_rdOptionsView];
    [_rdPanel setDelegate:self];

    NSString *lastDirectory = [[NSUserDefaults standardUserDefaults] objectForKey:@"atlantis.upload.directory"];
    if (!lastDirectory)
        lastDirectory = @"~/Documents";

    [_rdPanel beginSheetForDirectory:lastDirectory file:@"" modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
    return YES;
}

@end
