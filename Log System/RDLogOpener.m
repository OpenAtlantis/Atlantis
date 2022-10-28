//
//  RDLogOpener.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/15/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDLogOpener.h"
#import "RDAtlantisMainController.h"
#import "RDLogType.h"
#import "RDAtlantisSpawn.h"
#import "AtlantisProgressSheet.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation RDLogOpener

- (id) initWithState:(AtlantisState *) state
{
    self = [super init];
    if (self) {
        _rdState = [state retain];
        _rdSavePanel = nil;
    }
    return self;
}

- (id) initWithHotkeyState:(RDHotkeyState *)state
{
    NSLog(@"Eeek!");
    return nil;
}

- (void) dealloc
{
    [_rdSavePanel release];
    [_rdState release];
    [super dealloc];
}

NSInteger scrollbackSort(id obj1, id obj2, void *context)
{
    NSAttributedString *st1 = (NSAttributedString *)obj1;
    NSAttributedString *st2 = (NSAttributedString *)obj2;
    
    NSRange tempRange;
    NSDate *d1 = nil;
    NSDate *d2 = nil;

    if ([st1 length]) {
        NSDictionary *dict1 = [st1 attributesAtIndex:0 effectiveRange:&tempRange];
        d1 = [dict1 objectForKey:@"RDTimeStamp"];
    }
    if ([st2 length]) {
        NSDictionary *dict2 = [st2 attributesAtIndex:0 effectiveRange:&tempRange];
        d2 = [dict2 objectForKey:@"RDTimeStamp"];
    }
    
    if (d1 && !d2) {
        return NSOrderedDescending;
    }
    else if (!d1 && d2) {
        return NSOrderedAscending;
    }
    else {
        return [d1 compare:d2];
    }    
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
    if (returnCode == NSOKButton) {
        [NSApp endSheet:sheet];
        [sheet orderOut:self];
        NSArray *logtypes = [[RDAtlantisMainController controller] logTypes];

        NSString *filename = [sheet filename];
        Class logClass = [logtypes objectAtIndex:[_rdLogTypes indexOfSelectedItem]];

        NSString* (*SendReturningString)(id, SEL) = (NSString* (*)(id, SEL))objc_msgSend;
        
        NSString *logtype = SendReturningString(logClass,@selector(logtypeName));
        
        if (logtype) {
            [[NSUserDefaults standardUserDefaults] setObject:logtype forKey:@"atlantis.logsave.type"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[sheet directory] forKey:@"atlantis.logsave.directory"];

        if (_rdTempFilename) {
            [[NSFileManager defaultManager] movePath:_rdTempFilename toPath:filename handler:NULL];
            [_rdTempFilename release];
            _rdTempFilename = nil;
        }
        
        NSString *spawnPath = nil;
        if ([_rdSpawnOnlyButton state] == NSOnState) {
            spawnPath = [[_rdState spawn] internalPath];
        }

        BOOL showTimestamps = NO;
        if ([_rdTimestampButton state] == NSOnState) {
            showTimestamps = YES;
        }
        [[NSUserDefaults standardUserDefaults] setBool:([_rdTimestampButton state] == NSOnState) forKey:@"atlantis.logsave.timestamps"];
        
        RDLogType *logger = (RDLogType *)class_createInstance(logClass,0);
        [logger initWithFilename:filename forSpawn:spawnPath inWorld:[_rdState world] withOptions:_rdCurrentOptions];
        [logger setWriteTimestamps:showTimestamps];
        if ([logger openFile]) {
            [[_rdState world] addLogfile:logger];
            
            if ([_rdScrollbackButton state] == NSOnState) {
                
                NSMutableArray *scrollbackData = nil; 
                AtlantisProgressSheet *progressSheet = [[AtlantisProgressSheet alloc] init];
                
                [progressSheet openPanel:@"Preparing log..." withMaxValue:-1];
                BOOL cancelled = NO;                
                
                if (([[_rdState world] countOpenSpawns] != 1) && ([_rdSpawnOnlyButton state] == NSOffState)) {
                    // Generate combined scrollback
                    scrollbackData = [[NSMutableArray alloc] init];

                    NSEnumerator *spawnEnum = [[_rdState world] spawnEnumerator];
                    RDAtlantisSpawn *spawnWalk;
                    
                    while (spawnWalk = [spawnEnum nextObject]) {
                        [progressSheet setLabel:[NSString stringWithFormat:@"Adding %@ to scrollback...", [spawnWalk viewName]]];
                        cancelled = [progressSheet modalRun];
                        if (cancelled) {
                            [logger closeFile];
                            [[_rdState world] removeLogfile:logger];
                            [scrollbackData release];
                            [progressSheet closePanel];
                            [progressSheet release];                
                            [_rdCurrentOptions release];
                            _rdCurrentOptions = nil;
                            return;                        
                        }
                        [scrollbackData addObjectsFromArray:[spawnWalk scrollbackData]];
                    }
                    
                    [progressSheet setLabel:@"Sorting combined scrollback..."];
                    [scrollbackData sortUsingFunction:scrollbackSort context:nil];
                }
                else {
                    scrollbackData = [[[_rdState spawn] scrollbackData] mutableCopy];                
                }
                
                // Write out lines
                if (scrollbackData) {
                    NSEnumerator *scrollbackEnum = [scrollbackData objectEnumerator];
                    NSAttributedString *stringWalk;
                    
                    unsigned int totalLines = [scrollbackData count];
                    
                    [progressSheet setLabel:[NSString stringWithFormat:@"Writing %d lines...", totalLines]];
                    [progressSheet setMaxValue:(double)totalLines];
                    
                    double progress = 0;
                    [progressSheet setProgress:0];
                    
                    while (stringWalk = [scrollbackEnum nextObject]) {
                        NSRange effRange;
                        NSDictionary *attrs = nil;
                        
                        if ([stringWalk length])
                            attrs = [stringWalk attributesAtIndex:0 effectiveRange:&effRange];
                        
                        progress++;
                        NSString *lineClass = [attrs objectForKey:@"RDLineClass"];
                        [progressSheet setProgress:progress];
                        cancelled = [progressSheet modalRun];
                        if (cancelled) {
                            [logger closeFile];
                            [[_rdState world] removeLogfile:logger];
                            [scrollbackData release];
                            [progressSheet closePanel];
                            [progressSheet autorelease];                
                            [_rdCurrentOptions release];
                            _rdCurrentOptions = nil;
                            return;
                        }
                        
                        if (!(lineClass && [lineClass isEqualToString:@"console"])) {
                            if ([attrs objectForKey:@"RDOmitSpan"]) {
                                [logger writeString:[stringWalk attributedSubstringFromRange:NSMakeRange(effRange.length,[stringWalk length] - effRange.length)] withState:_rdState];
                            }
                            else
                                [logger writeString:stringWalk withState:_rdState];
                        }
                    }
                    [scrollbackData release];
                }
                [progressSheet closePanel];
                [progressSheet autorelease];                
            }            
        }
        else {
            // TODO: Uhm... error handling of some sort.
        }
        
        [_rdCurrentOptions release];
        _rdCurrentOptions = nil;
    }
}

- (void) resyncButton
{
    NSArray *logtypes = [[RDAtlantisMainController controller] logTypes];
    Class logClass = [logtypes objectAtIndex:[_rdLogTypes indexOfSelectedItem]];

    BOOL (*SendReturningBool)(id, SEL) = (BOOL (*)(id, SEL))objc_msgSend;
    
    if(SendReturningBool(logClass,@selector(supportsOptions))) {
        [_rdOptionsButton setEnabled:YES];
    }
    else {
        [_rdOptionsButton setEnabled:NO];    
    }
}

- (void) logTypeChanged:(id) sender
{
    [_rdCurrentOptions release];
    _rdCurrentOptions = nil;
    [self resyncButton];
}

- (void) logTypeOptions:(id) sender
{
    NSArray *logtypes = [[RDAtlantisMainController controller] logTypes];
    Class logClass = [logtypes objectAtIndex:[_rdLogTypes indexOfSelectedItem]];

    RDLogType *tempLog = (RDLogType *)class_createInstance(logClass,0);
    [tempLog init];

    NSDictionary *newOptions = [tempLog configureOptions:_rdCurrentOptions];
    
    if (newOptions != _rdCurrentOptions) {
        [_rdCurrentOptions release];
        _rdCurrentOptions = [newOptions retain];
    }        
}

- (BOOL) openPanel
{
    if ([NSBundle loadNibNamed:@"LogOptionPanel" owner:self])
    {
        [_rdSpawnOnlyButton setState:NSOffState];
        [_rdScrollbackButton setState:NSOffState];
        [_rdTimestampButton setState:NSOffState];
        [_rdLogTypes removeAllItems];
        _rdCurrentOptions = nil;
        
        NSEnumerator *logtypeEnum = [[[RDAtlantisMainController controller] logTypes] objectEnumerator];
        Class logWalk;
        
        NSString *lastType = 
            [[NSUserDefaults standardUserDefaults] objectForKey:@"atlantis.logsave.type"];

        NSString* (*SendReturningString)(id, SEL) = (NSString* (*)(id, SEL))objc_msgSend;
        
        while (logWalk = [logtypeEnum nextObject]) {
            if (logWalk) {
                NSString *result = SendReturningString(logWalk,@selector(logtypeName));
                
                if (!result) {
                    result = @"<unknown log type>";
                }
                
                [_rdLogTypes addItemWithTitle:result];
            }            
         }
         
        if (lastType) {
            [_rdLogTypes selectItemWithTitle:lastType];
        }
        [self resyncButton];        
        
        BOOL lastTimestamp = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.logsave.timestamps"];
        if (lastTimestamp) {
            [_rdTimestampButton setState:NSOnState];
        }
        
        NSWindow *window = [NSApp keyWindow];
        
        _rdTempFilename = nil;
        _rdSavePanel = [[NSSavePanel savePanel] retain];
        [_rdSavePanel setAccessoryView:_rdOptionsView];
        [_rdSavePanel setDelegate:self];
        NSString *lastDirectory = [[NSUserDefaults standardUserDefaults] objectForKey:@"atlantis.logsave.directory"];
        if (!lastDirectory)
            lastDirectory = @"~/Documents";
        [_rdSavePanel beginSheetForDirectory:lastDirectory file:nil modalForWindow:window modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
        return YES;
    }
    else
        return NO;
    
}

- (NSString *)panel:(id)sender userEnteredFilename:(NSString *)filename confirmed:(BOOL)okFlag
{
    if (okFlag) {
        
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *savePanelPath = [_rdSavePanel directory];
        NSString *realFilename = [NSString stringWithFormat:@"%@/%@", savePanelPath, filename];
        
        if ([manager fileExistsAtPath:realFilename]) {
            NSArray *logtypes = [[RDAtlantisMainController controller] logTypes];
            Class logClass = [logtypes objectAtIndex:[_rdLogTypes indexOfSelectedItem]];
            
            BOOL (*SendReturningBool)(id, SEL) = (BOOL (*)(id, SEL))objc_msgSend;
            
            if (SendReturningBool(logClass,@selector(canAppendToLog))) {                
                // Lookie, lookie; we need to ask if we should append, or replace!
                
                NSAlert *alert = 
                [NSAlert alertWithMessageText:@"File already Exists!" 
                                 defaultButton:@"Replace" 
                               alternateButton:@"Cancel" 
                                   otherButton:@"Append" 
                     informativeTextWithFormat:@"A file named %@ already exists, but this logfile format can append to existing logs.  Would you like to append to the existing file, or replace it?", filename];
                    
                    int result = [alert runModal];
                    
                    if (result == NSAlertAlternateReturn) {
                        // Cancel button
                        return nil;
                    }
                    else if (result == NSAlertDefaultReturn) {
                        // Replace button
                        [manager removeFileAtPath:realFilename handler:NULL];
                    }
                    else if (result == NSAlertOtherReturn) {
                        // Append button
                        _rdTempFilename = 
                            [[NSString stringWithFormat:@"%@/.temp-%@", savePanelPath, filename] retain];
                            
                        [manager movePath:realFilename toPath:_rdTempFilename handler:NULL];
                        return filename;
                    }
            }
            else {
                return filename;
            }
        }
        else
            return filename;        
    }
    
    return filename;
}

@end
