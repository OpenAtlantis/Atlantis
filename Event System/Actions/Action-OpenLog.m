//
//  Action-OpenLog.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/18/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-OpenLog.h"
#import "AtlantisState.h"
#import "RDAtlantisMainController.h"
#import "RDLogType.h"
#import "NSStringExtensions.h"
#import "RDAtlantisSpawn.h"

@implementation Action_OpenLog

+ (NSString *) actionName
{
    // TODO: Localize
    return @"Log: Open Specific Logfile";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Open a specific predefined logfile and append.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeEvent) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (id) init
{
    self = [super init];
    if (self) {
        _rdPath = nil;
        _rdLogType = [[NSString alloc] initWithString:@"Text"];
        _rdSpawnPath = nil;
        _rdScrollback = NO;
        _rdTimestamps = NO;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdSpawnPath = [[coder decodeObjectForKey:@"logopen.spawnpath"] retain];
        _rdPath = [[coder decodeObjectForKey:@"logopen.filename"] retain];
        _rdLogType = [[coder decodeObjectForKey:@"logopen.logtype"] retain];
        if (!_rdLogType) {
            _rdLogType = [[NSString alloc] initWithString:@"Text"];
        }
        _rdScrollback = [coder decodeBoolForKey:@"logopen.scrollback"];
        _rdTimestamps = [coder decodeBoolForKey:@"logopen.timestamps"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    if (_rdSpawnPath && [_rdSpawnPath length])
        [coder encodeObject:_rdSpawnPath forKey:@"logopen.spawnpath"];
    if (_rdPath)
        [coder encodeObject:_rdPath forKey:@"logopen.filename"];
    if (_rdLogType)
        [coder encodeObject:_rdLogType forKey:@"logopen.logtype"];
    else
        [coder encodeObject:@"Text" forKey:@"logopen.logtype"];
    [coder encodeBool:_rdScrollback forKey:@"logopen.scrollback"];
    [coder encodeBool:_rdTimestamps forKey:@"logopen.timestamps"];
}

- (void) dealloc
{
    [_rdSpawnPath release];
    [_rdPath release];
    [_rdLogType release];
    [super dealloc];
}

- (RDLogType *) allocNamedType:(NSString *) logType
{
    NSArray *logTypes = [[RDAtlantisMainController controller] logTypes];
    NSEnumerator *logEnum = [logTypes objectEnumerator];
    Class logWalk;
    RDLogType *result = nil;
    
    while (!result && (logWalk = [logEnum nextObject])) {
        NSString *tempString = objc_msgSend(logWalk,@selector(shortTypeName));
        
        if (tempString && [tempString isEqualToString:logType]) {
            result = (RDLogType *)class_createInstance(logWalk,0);
        }
    }
    
    return result;
}


extern int scrollbackSort(id obj1, id obj2, void *context);

- (BOOL) executeForState:(AtlantisState *) state
{
    if ([state world]) {
        NSString *filename =
            [_rdPath expandWithDataIn:[state data]];
            
        NSString *spawn = nil;
        if (_rdSpawnPath && [_rdSpawnPath length])
            spawn = _rdSpawnPath;

        RDLogType *newLog = [self allocNamedType:_rdLogType];
        if (newLog) {
            [newLog initWithFilename:filename forSpawn:spawn inWorld:[state world] withOptions:_rdOptions];
            [newLog setWriteTimestamps:_rdTimestamps];
            [newLog openFile];
            [[state world] addLogfile:newLog];
            
            if (_rdScrollback) {
                
                NSMutableArray *scrollbackData = nil; 
                
                if (!spawn) {
                    // Generate combined scrollback                    
                    scrollbackData = [[NSMutableArray alloc] init];

                    NSEnumerator *spawnEnum = [[state world] spawnEnumerator];
                    RDAtlantisSpawn *spawnWalk;
                    
                    while (spawnWalk = [spawnEnum nextObject]) {
                        [scrollbackData addObjectsFromArray:[spawnWalk scrollbackData]];
                    }
                    
                    [scrollbackData sortUsingFunction:scrollbackSort context:nil];
                }
                else {
                    scrollbackData = [[[state spawn] scrollbackData] mutableCopy];                
                }
                
                // Write out lines
                if (scrollbackData) {
                    NSEnumerator *scrollbackEnum = [scrollbackData objectEnumerator];
                    NSAttributedString *stringWalk;
                    
                    while (stringWalk = [scrollbackEnum nextObject]) {
                        NSRange effRange;
                        NSDictionary *attrs = nil;
                        
                        if ([stringWalk length])
                            attrs = [stringWalk attributesAtIndex:0 effectiveRange:&effRange];
                        
                        NSString *lineClass = [attrs objectForKey:@"RDLineClass"];
                        
                        if ([attrs objectForKey:@"RDOmitSpan"] || (lineClass && [lineClass isEqualToString:@"console"])) {
                            [newLog writeString:[stringWalk attributedSubstringFromRange:NSMakeRange(effRange.location + effRange.length,[stringWalk length] - effRange.length)] withState:state];
                        }
                        else
                            [newLog writeString:stringWalk withState:state];
                    }
                    [scrollbackData release];
                }
            
            }
        }        
    }

    return NO;
}

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    if ([notification object] == _rdFilename) {
        [_rdPath release];
        _rdPath = [[_rdFilename stringValue] retain];
    }
    if ([notification object] == _rdSpawnTextfield) {
        [_rdSpawnPath release];
        _rdSpawnPath = [[_rdSpawnTextfield stringValue] retain];
    }
}

- (void) logTypeChanged:(id) sender
{
    int selected = [_rdLogTypes indexOfSelectedItem];
    
    NSArray *logTypes = [[RDAtlantisMainController controller] logTypes];
    Class newLogType = [logTypes objectAtIndex:selected];
    
    NSString *newLogName = (NSString *)objc_msgSend(newLogType,@selector(shortTypeName));
    if (newLogName && ![newLogName isEqualToString:_rdLogType]) {
        [_rdLogType release];
        _rdLogType = [newLogName retain];
        [_rdOptions release];
        _rdOptions = nil;
        
        if (objc_msgSend(newLogType,@selector(supportsOptions))) {
            [_rdOptionsButton setEnabled:YES];
        }
        else {
            [_rdOptionsButton setEnabled:NO];
        }        
    }
}

- (void) spawnEnabledChanged:(id) sender
{
    if ([_rdSpawnEnabled state] == NSOnState) {
        [_rdSpawnTextfield setEnabled:YES];    
    }
    else {
        [_rdSpawnTextfield setEnabled:NO];
    }
}

- (void) scrollbackEnabledChanged:(id) sender
{
    _rdScrollback = ([_rdLogScrollback state] == NSOnState);
}

- (void) timestampsChanged:(id) sender
{
    _rdTimestamps = ([_rdTimestampsEnabled state] == NSOnState);
}

- (void) optionsButton:(id) sender
{
    RDLogType *tempType = [self allocNamedType:_rdLogType];
    if (tempType) {
        [tempType init];
        
        NSDictionary *options = [tempType configureOptions:_rdOptions];
        if (options != _rdOptions) {
            [_rdOptions release];
            _rdOptions = [options retain];
        }
    }
}

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_LogOpen" owner:self];
        [_rdFilename setDelegate:self];
        [_rdSpawnTextfield setDelegate:self];
    }
 
    if (_rdPath)
        [_rdFilename setStringValue:_rdPath];
    else
        [_rdFilename setStringValue:@""];

    if (_rdSpawnPath) {
        [_rdSpawnTextfield setStringValue:_rdSpawnPath];
        [_rdSpawnTextfield setEnabled:YES];
        [_rdSpawnEnabled setState:NSOnState];
    }
    else {
        [_rdSpawnTextfield setStringValue:@""];
        [_rdSpawnTextfield setEnabled:NO];
        [_rdSpawnEnabled setState:NSOffState];
    }
    
    if (_rdScrollback)
        [_rdLogScrollback setState:NSOnState];
    else
        [_rdLogScrollback setState:NSOffState];
        
    if (_rdTimestamps)
        [_rdTimestampsEnabled setState:NSOnState];
    else
        [_rdTimestampsEnabled setState:NSOffState];
    
    [_rdLogTypes removeAllItems];
    
    NSArray *logTypes = [[RDAtlantisMainController controller] logTypes];
    NSEnumerator *logEnum = [logTypes objectEnumerator];
    Class logWalk;
    
    int selectMe = 0;
    BOOL enabled = YES;
    
    while (logWalk = [logEnum nextObject]) {
        NSString *result = (NSString *)objc_msgSend(logWalk,@selector(logtypeName));
        NSString *typeName = (NSString *)objc_msgSend(logWalk,@selector(shortTypeName));
        
        if (!result) {
            result = @"<unknown log type>";
        }
        
        [_rdLogTypes addItemWithTitle:result];        
        if (typeName && [typeName isEqualToString:_rdLogType]) {
            selectMe = [_rdLogTypes indexOfItemWithTitle:result];
            enabled = (objc_msgSend(logWalk,@selector(supportsOptions)) != nil);
        }
    }

    [_rdLogTypes selectItemAtIndex:selectMe];
    [_rdOptionsButton setEnabled:enabled];
 
    return _rdInternalConfigurationView;
}


@end
