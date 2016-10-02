//
//  RenameWindowPanel.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/14/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RenameWindowPanel.h"

static RenameWindowPanel        *s_rdRenameWindowPanel = nil;

@implementation RenameWindowPanel

+ (RenameWindowPanel *) sharedPanel
{
    if (!s_rdRenameWindowPanel) {
        s_rdRenameWindowPanel = [[RenameWindowPanel alloc] init];
    }
    return s_rdRenameWindowPanel;
}

- (id) init
{
    self = [super init];
    if (self) {
        [NSBundle loadNibNamed:@"RenameWindowPicker" owner:self];
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void)_sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton) {
        NSString *result = [_rdRenameText stringValue];
        RDNestedViewWindow *window = (RDNestedViewWindow *)contextInfo;
        if (result && window) {
            [[RDNestedViewManager manager] renameWindow:window withTitle:result];
        }
    }
    [_rdRenamePanel orderOut:self];
}

- (void) renameForWindow:(RDNestedViewWindow *) window
{
    NSString *windowTitle = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"lemuria.windowName.%@", [window windowUID]]];
    
    if (!windowTitle)
        windowTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];

    [_rdRenameText setStringValue:windowTitle];
    [NSApp beginSheet:_rdRenamePanel modalForWindow:window modalDelegate:self didEndSelector:@selector(_sheetDidEnd:returnCode:contextInfo:) contextInfo:window];
}

- (void) rename:(id) sender
{
    [NSApp endSheet:_rdRenamePanel returnCode:NSOKButton];
}

- (void) cancel:(id) sender
{
    [NSApp endSheet:_rdRenamePanel returnCode:NSCancelButton];
}   

@end
