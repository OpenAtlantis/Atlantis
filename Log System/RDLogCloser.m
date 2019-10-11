//
//  RDLogCloser.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/15/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDLogCloser.h"
#import "RDLogType.h"

@implementation RDLogCloser

- (id) initWithState:(AtlantisState *)state
{
    self = [super init];
    if (self) {
        _rdState = [state retain];
    }
    return self;
}

- (id) initWithHotkeyState:(RDHotkeyState *)state
{
    NSLog(@"Eek!");
    return nil;
}

- (void) dealloc
{
    [_rdState release];
    [super dealloc];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
    // TODO: Unload Bundle?
    [_rdTableView setDataSource:nil];
}

- (void) openPanel
{
    if ([NSBundle loadNibNamed:@"LogClosePanel" owner:self])
    {
        _rdLogfiles = [[_rdState world] logfiles];
        [_rdTableView setDataSource:self];
        [NSApp beginSheet:_rdCloserView modalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (void) closeLogs:(id) sender
{
    NSIndexSet *logsToClose = [_rdTableView selectedRowIndexes];
    
    NSUInteger nextToClose = [logsToClose firstIndex];

    NSMutableArray *closers = [[NSMutableArray alloc] init];
    
    while (nextToClose != NSNotFound) {
        RDLogType *log = [_rdLogfiles objectAtIndex:nextToClose];
        [closers addObject:log];
        nextToClose = [logsToClose indexGreaterThanIndex:nextToClose];
    }
    
    NSEnumerator *logEnum = [closers objectEnumerator];
    RDLogType *logWalk;
    
    while (logWalk = [logEnum nextObject]) {
        [logWalk closeFile];
        [[_rdState world] removeLogfile:logWalk];
    }

    [_rdCloserView orderOut:nil];
    [NSApp endSheet:_rdCloserView];
    [closers release];
}

- (void) cancelLogs:(id) sender
{
    // Nothing of interest, la.
    [_rdCloserView orderOut:nil];
    [NSApp endSheet:_rdCloserView];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_rdLogfiles count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if ([[aTableColumn identifier] isEqualToString:@"logNum"]) {
        return [NSString stringWithFormat:@"%d", rowIndex];
    }
    else if ([[aTableColumn identifier] isEqualToString:@"logName"]) {
        RDLogType *logObj = [_rdLogfiles objectAtIndex:rowIndex];
        
        return [[logObj filename] lastPathComponent];
    }
    else if ([[aTableColumn identifier] isEqualToString:@"logType"]) {
        RDLogType *logObj = [_rdLogfiles objectAtIndex:rowIndex];
        
        return [logObj shortTypeName];    
    }
    else if ([[aTableColumn identifier] isEqualToString:@"logSpawn"]) {
        RDLogType *logObj = [_rdLogfiles objectAtIndex:rowIndex];

        NSString *spawnName = [logObj spawnPath];
        if (!spawnName)
            spawnName = @"";
        
        return spawnName;            
    }
    
    return @"<unknown error!>";
}


@end
