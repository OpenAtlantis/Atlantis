//
//  RDAtlantisWorldInstance.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/8/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Lemuria/Lemuria.h>
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisSpawn.h"
#import "RDAtlantisApplication.h"
#import "RDAnsiFilter.h"
#import "RDLogType.h"
#import "RDSpawnConfigRecord.h"
#import "RDAtlantisMainController.h"
#import "RDStringPattern.h"
#import "WorldEvent.h"
#import "HighlightEvent.h"
#import "EventCollection.h"
#import "AtlantisState.h"
#import "NSStringExtensions.h"
#import "BaseCommand.h"
#import "AliasEvent.h"
#import "ScriptingDispatch.h"
#import "BaseAction.h"
#import "DelayedEvent.h"

#import "RDCompressionFilter.h"
#import "MCPMessage.h"

#import "WorldNotesView.h"

#import <CoreServices/CoreServices.h>

#include <string.h>

#import <objc/runtime.h>

        
static NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

@interface RDAtlantisWorldInstance(Private)
- (void) characterRenamed:(NSNotification *)notification;
- (void) refreshConveniencePointers:(NSNotification *)notification;
- (void) setWorldDefaults;
- (void) sendCurrentBuffer;
- (id) realPreferenceForKey:(NSString *)key;
- (void) handleStatusOutput:(NSString *)string;
- (void) handleDisconnect;
- (void) handleBytesOnStream:(NSInputStream *)stream;
- (void) fireEventsForState:(AtlantisState *)state;
@end

@interface NSFont (StringWidth)
- (CGFloat) widthOfString:(NSString *)string;
@end

@implementation RDAtlantisWorldInstance

#pragma mark Initialization

- (id) initWithWorld:(RDAtlantisWorldPreferences *)world forCharacter:(NSString *) character withBasePath:(NSString *)basePath
{
    self = [super init];
    if (self) {
        _rdBaseViewPath = [basePath retain];
        _rdCharacter = [character retain];
        _rdPreferences = [world retain];
        _rdSpawns = [[NSMutableDictionary alloc] init];
        _rdBaseStateInfo = [[NSMutableDictionary alloc] init];
        _rdTempVariables = [[NSMutableDictionary alloc] init];
        _rdEvents = nil;
        _rdHighlights = nil;    
        _rdAliases = nil;
        _rdParaStyle = nil;
        _rdNeedsReconnect = NO;
        _rdIsCompressing = NO;
        _rdDefaultColor = nil;
        _rdGrabPattern = nil;
        _rdDisplayFont = nil;
        _rdDisplayFontBolded = nil;
        _rdTempWorld = NO;
        _rdMcpSessionKey = nil;
        _rdConnectedOn = nil;
        _rdMcpNegotiated = NO;
        _rdMcpDisabled = NO;
        _rdWorldNotes = nil;
        
        _rdSpawnPrefixes = [[NSMutableDictionary alloc] init];
        
        [self refreshConveniencePointers:nil];
       
        [_rdBaseStateInfo setObject:[NSString stringWithString:_rdBaseViewPath] forKey:@"world.name"];
        if (_rdCharacter)
            [_rdBaseStateInfo setObject:[NSString stringWithString:_rdCharacter] forKey:@"world.character"];
        else
            [_rdBaseStateInfo setObject:@"" forKey:@"world.character"];
        
        NSString *worldName = [_rdPreferences preferenceForKey:@"atlantis.world.name" withCharacter:_rdCharacter];
        if (worldName)
            [_rdBaseStateInfo setObject:[NSString stringWithString:worldName] forKey:@"world.game"];
        

        _rdInputStream = nil;
        _rdOutputStream = nil;
        _rdOutputBuffer = nil;
        _rdHoldoverBlock = nil;

        RDSpawnConfigRecord *mainConfig = [self configForSpawn:@""];
        _rdMainView = [self spawnForPath:@"" withPreferences:mainConfig];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshConveniencePointers:) name:@"RDAtlantisWorldDidUpdateNotification" object:_rdPreferences];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshConveniencePointers:) name:@"RDAtlantisWorldDidUpdateNotification" object:[[RDAtlantisMainController controller] globalWorld]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(characterRenamed:) name:@"RDAtlantisCharacterRenamedNotification" object:_rdPreferences];
        
        NSEnumerator *filterEnum;
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        NSArray *filters = [[RDAtlantisMainController controller] inputFilters];
        filterEnum = [filters objectEnumerator];
        
        Class myClass;
        
        // Create instances of every atlantis filter class for this world
        while (myClass = [filterEnum nextObject]) {
            id newClass = (id)class_createInstance(myClass,0);
            if ([newClass isKindOfClass:[RDAtlantisFilter class]]) {
                RDAtlantisFilter *newFilter = (RDAtlantisFilter *)newClass;
                [newFilter initWithWorld:self];
                [tempArray addObject:newFilter];
            }
        }
        
        _rdMcpPackets = [[NSMutableArray alloc] init];
        _rdMcpTags = [[NSMutableDictionary alloc] init];
        _rdMcpPackages = [[NSMutableDictionary alloc] init];
        
        _rdDelayQueue = [[NSMutableArray alloc] init];
        
        _rdInputFilters = tempArray;
        _rdCommandHistory = [[NSMutableArray alloc] init];
        _rdHistoryPointer = -1;
        _rdCommandHoldover = nil;
        _rdFuguePattern = [[RDStringPattern patternWithString:@"FugueEdit > " type:RDPatternBeginsWith] retain];
        
        _rdLogfiles = [[NSMutableArray alloc] init];
        _rdUploaders = [[NSMutableArray alloc] init];
        _rdLastUserActivity = [[NSDate distantPast] retain];
        _rdLastNetActivity = [[NSDate distantPast] retain];
        
        _rdOutputTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(sendCurrentBuffer) userInfo:nil repeats:YES];
        
        [[RDAtlantisMainController controller] addWorld:self];
        
        AtlantisState *state = [[AtlantisState alloc] initWithString:nil inWorld:self forSpawn:_rdMainView];
        [state setExtraData:@"statechange" forKey:@"event.cause"];
        [state setExtraData:@"opened" forKey:@"event.statechange"];        
        [self fireEventsForState:state];
        [state release];
    }
    return self;
}

- (void) setWorldDefaults
{
    if (![_rdPreferences preferenceForKey:@"atlantis.colors.ansi" withCharacter:_rdCharacter]) {
        NSMutableArray * ansiColorArray = [[NSMutableArray alloc] initWithCapacity:16];
        
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.000 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.800 green:0.000 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.800 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.800 green:0.800 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.000 blue:0.800 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.800 green:0.000 blue:0.800 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.800 blue:0.800 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.800 green:0.800 blue:0.800 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.500 green:0.500 blue:0.500 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:1.000 green:0.000 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:1.000 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:1.000 green:1.000 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.000 blue:1.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:1.000 green:0.000 blue:1.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:1.000 blue:1.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:1.000 green:1.000 blue:1.000 alpha:1.0]];
        
        [_rdPreferences setPreference:ansiColorArray forKey:@"atlantis.colors.ansi" withCharacter:nil];
        [ansiColorArray release];
    }
    
    if (![_rdPreferences preferenceForKey:@"atlantis.colors.url" withCharacter:_rdCharacter]) {
        [_rdPreferences setPreference:[NSColor cyanColor] forKey:@"atlantis.colors.url" withCharacter:nil];
    }
    
}

- (void) characterRenamed:(NSNotification *) notification
{
    NSString *oldName = [[notification userInfo] objectForKey:@"RDAtlantisCharacterOld"];
    NSString *newName = [[notification userInfo] objectForKey:@"RDAtlantisCharacterNew"];
    
    if (oldName && _rdCharacter && [oldName isEqualToString:_rdCharacter]) {
        [_rdCharacter release];
        _rdCharacter = [newName retain];
    }
}

- (void) refreshConveniencePointers:(NSNotification *) notification
{
    NSNumber *localEcho = [self preferenceForKey:@"atlantis.text.localEcho"];
    _rdLocalEcho = [localEcho boolValue];
    
    NSNumber *linefeed = [self preferenceForKey:@"atlantis.text.linefeed"];
    _rdAlternateLinefeed = [linefeed boolValue];
    
    NSString *localEchoPrefix = [self preferenceForKey:@"atlantis.text.localEchoPrefix"];
    if (!localEchoPrefix) {
        _rdLocalEchoPrefix = @"> ";
    }
    else {
        _rdLocalEchoPrefix = localEchoPrefix;
    }

    NSNumber *reflectionsOn = [self preferenceForKey:@"atlantis.world.codebase"];
    _rdServerCodebase = [reflectionsOn intValue];

    NSFont *realFont = [self preferenceForKey:@"atlantis.formatting.font"];
    if (!realFont) {
        realFont = [NSFont userFixedPitchFontOfSize:10.0f];
    }
    NSFont *oldFont = _rdDisplayFont;
    _rdDisplayFont = [realFont retain];
    [oldFont release];
    
    [_rdDisplayFontBolded release];
    _rdDisplayFontBolded = [[NSFontManager sharedFontManager] convertFont:_rdDisplayFont toHaveTrait:NSBoldFontMask];
    if (_rdDisplayFontBolded)
        [_rdDisplayFontBolded retain];
    
    BOOL timestamps = [[self preferenceForKey:@"atlantis.formatting.timestamps"] boolValue];

    float fontWidth;    
    fontWidth = ((float)[realFont widthOfString:alphabet]) / [alphabet length];

    NSNumber *temp = [self preferenceForKey:@"atlantis.mcp.disabled"];
    if (temp) {
        _rdMcpDisabled = [temp boolValue];
    }

    [_rdParaStyle release];
    NSMutableParagraphStyle *para = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    int indent = [[self preferenceForKey:@"atlantis.formatting.indent"] intValue];
    if (timestamps)
        indent += 11;
    [para setFirstLineHeadIndent:0.0];
    [para setHeadIndent:(fontWidth * indent)];
    _rdParaStyle = para;

    NSMutableDictionary *tempSpawn = [[[NSMutableDictionary alloc] init] autorelease];

    NSDictionary *globalSpawns = [[[RDAtlantisMainController controller] globalWorld] preferenceForKey:@"atlantis.spawns" withCharacter:nil];

    if (globalSpawns) {
        [tempSpawn addEntriesFromDictionary:globalSpawns];
    }

    if (_rdCharacter) {
        NSDictionary *parentSpawns = [_rdPreferences preferenceForKey:@"atlantis.spawns" withCharacter:nil fallback:NO];
        if (parentSpawns) {
            [tempSpawn addEntriesFromDictionary:parentSpawns];
        }
    }

    NSDictionary *selfSpawns = [self realPreferenceForKey:@"atlantis.spawns"];
    if (selfSpawns)
        [tempSpawn addEntriesFromDictionary:selfSpawns];
        
    [_rdSpawnPreferences release];
    _rdSpawnPreferences = [[NSDictionary alloc] initWithDictionary:tempSpawn];

    [_rdAliases release];
    _rdAliases = [[[self realPreferenceForKey:@"atlantis.aliases"] events] copyWithZone:nil];
    
    if (_rdCharacter) {
        NSArray *tempArray = [[_rdPreferences preferenceForKey:@"atlantis.aliases" withCharacter:nil fallback:NO] events];
        if (tempArray) {
            NSMutableArray *newEvents = [[NSMutableArray alloc] init];
            [newEvents addObjectsFromArray:tempArray];
            if (_rdAliases) {
                [newEvents addObjectsFromArray:_rdAliases];
                [_rdAliases release];
                _rdAliases = newEvents;
            }
            else {
                _rdAliases = newEvents;
            }
        }
    }
    
    [_rdEvents release];
    _rdEvents = [[[self realPreferenceForKey:@"atlantis.events"] events] copyWithZone:nil];
    
    if (_rdCharacter) {
        NSArray *tempArray = [[_rdPreferences preferenceForKey:@"atlantis.events" withCharacter:nil fallback:NO] events];
        if (tempArray) {
            NSMutableArray *newEvents = [[NSMutableArray alloc] init];
            [newEvents addObjectsFromArray:tempArray];
            if (_rdEvents) {
                [newEvents addObjectsFromArray:_rdEvents];
                [_rdEvents release];
                _rdEvents = newEvents;
            }
            else {
                _rdEvents = newEvents;
            }
        }
    }
    
    [_rdHighlights release];
    _rdHighlights = [[self realPreferenceForKey:@"atlantis.highlights"] copyWithZone:nil];

    if (_rdCharacter) {
        NSArray *tempArray = [_rdPreferences preferenceForKey:@"atlantis.highlights" withCharacter:nil fallback:NO];
        if (tempArray) {
            NSMutableArray *newEvents = [[NSMutableArray alloc] init];
            [newEvents addObjectsFromArray:tempArray];
            if (_rdHighlights) {
                [newEvents addObjectsFromArray:_rdHighlights];
                [_rdHighlights release];
                _rdHighlights = newEvents;
            }
            else {
                _rdHighlights = newEvents;
            }
        }
    }

    [self setWorldDefaults]; // Just in case.
    
    [_rdBaseStateInfo removeAllObjects];
    [_rdBaseStateInfo setObject:[[NSBundle mainBundle] localizedStringForKey:@"CFBundleShortVersionString" value:@"" table:@"InfoPlist"] forKey:@"application.version"];
#ifdef _ATLANTIS_DEBUG
    [_rdBaseStateInfo setObject:@"yes" forKey:@"application.debug"];
#endif
    
    [_rdBaseStateInfo addEntriesFromDictionary:_rdTempVariables];


    [_rdBaseStateInfo setObject:[NSString stringWithString:_rdBaseViewPath] forKey:@"world.name"];
    if (_rdCharacter)
        [_rdBaseStateInfo setObject:[NSString stringWithString:_rdCharacter] forKey:@"world.character"];
    else
        [_rdBaseStateInfo setObject:@"" forKey:@"world.character"];
    
    NSString *worldName = [_rdPreferences preferenceForKey:@"atlantis.world.name" withCharacter:_rdCharacter];
    if (worldName)
        [_rdBaseStateInfo setObject:worldName forKey:@"world.game"];
    
    // Build our userconf namespace
    NSEnumerator *ucKeyEnum;
    NSString *keyWalk;
    NSDictionary *userconf = [[[RDAtlantisMainController controller] globalWorld] preferenceForKey:@"atlantis.userconf" withCharacter:nil fallback:NO];
    if (userconf) {
        ucKeyEnum = [userconf keyEnumerator];
        while (keyWalk = [ucKeyEnum nextObject]) {
            [_rdBaseStateInfo setObject:[userconf objectForKey:keyWalk] forKey:[NSString stringWithFormat:@"userconf.%@", keyWalk]];
        }
    }
    userconf = [_rdPreferences preferenceForKey:@"atlantis.userconf" withCharacter:nil fallback:NO];
    if (userconf) {
        ucKeyEnum = [userconf keyEnumerator];
        while (keyWalk = [ucKeyEnum nextObject]) {
            [_rdBaseStateInfo setObject:[userconf objectForKey:keyWalk] forKey:[NSString stringWithFormat:@"userconf.%@", keyWalk]];
        }
    }
    if (_rdCharacter) {
        userconf = [_rdPreferences preferenceForKey:@"atlantis.userconf" withCharacter:_rdCharacter fallback:NO];
        if (userconf) {
            ucKeyEnum = [userconf keyEnumerator];
            while (keyWalk = [ucKeyEnum nextObject]) {
                [_rdBaseStateInfo setObject:[userconf objectForKey:keyWalk] forKey:[NSString stringWithFormat:@"userconf.%@", keyWalk]];
            }
        }    
    }
    
    NSString *tempString = [_rdPreferences preferenceForKey:@"atlantis.grab.password" withCharacter:_rdCharacter fallback:YES];
    [_rdGrabPattern release];
    _rdGrabPattern = nil;
    if (tempString) {
        _rdGrabPattern = [[RDStringPattern patternWithString:[NSString stringWithFormat:@"1234%@ ",tempString] type:RDPatternBeginsWith] retain];
    }

    NSColor *tempColor = [_rdPreferences preferenceForKey:@"atlantis.colors.default" withCharacter:_rdCharacter fallback:YES];
    [_rdDefaultColor release];
    _rdDefaultColor = nil;
    if (tempColor)
        _rdDefaultColor = [[tempColor copyWithZone:nil] retain];
    else
        _rdDefaultColor = [[NSColor colorWithCalibratedRed:0.8f green:0.8f blue:0.8f alpha:1.0f] retain];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RDAtlantisConnectionDidRefreshConfigNotification" object:self];
    NSEnumerator *filterEnum = [_rdInputFilters objectEnumerator];
    RDAtlantisFilter *filter;
    
    while (filter = [filterEnum nextObject]) {
        [filter worldWasRefreshed];
    }       
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self closeAndRemove];
    
    [_rdSpawnPrefixes release];

    [_rdConnectedOn release];
    [_rdOutputTimer invalidate];
    [_rdMcpPackages release];
    [_rdMcpTags release];
    [_rdMcpPackets release];
    [_rdOutputTimer release];
    [_rdOutputBuffer release];
    [_rdLastUserActivity release];
    [_rdLastNetActivity release];
    [_rdDefaultColor release];
    [_rdGrabPattern release];
    [_rdFuguePattern release];
    [_rdBaseViewPath release];
    [_rdCharacter release];
    [_rdPreferences release];
    [_rdInputStream release];
    [_rdOutputStream release];
    [_rdSpawns release];
    [_rdHoldoverBlock release];
    [_rdEvents release];
    [_rdAliases release];  
    [_rdDelayQueue release];  
    [_rdHighlights release];
    [_rdInputFilters release];
    [_rdCommandHistory release];
    [_rdBaseStateInfo release];
    [_rdTempVariables release];
    [_rdParaStyle release];
    if (_rdCommandHoldover)
        [_rdCommandHoldover release];
    [_rdLogfiles release];
    [_rdUploaders release];
   
    [super dealloc];
}

#pragma mark Preferences, Events and Filters

- (RDAtlantisWorldPreferences *) preferences
{
    return _rdPreferences;
}

- (NSString *) character
{
    return _rdCharacter;
}

- (NSString *) uuid
{
    return [_rdPreferences uuidForCharacter:_rdCharacter];
}

- (id) preferenceForKey:(NSString *) key
{
    return [_rdPreferences preferenceForKey:key withCharacter:_rdCharacter fallback:YES];
}

- (id) realPreferenceForKey:(NSString *) key
{
    return [_rdPreferences preferenceForKey:key withCharacter:_rdCharacter fallback:NO];
}

- (NSParagraphStyle *) paragraphStyle
{
    return _rdParaStyle;
}

- (void) setInfo:(NSString *) info forBaseStateKey:(NSString *)key
{
    [_rdBaseStateInfo setObject:info forKey:key];
    [_rdTempVariables setObject:info forKey:key];
}

- (NSDictionary *) baseStateInfo
{
    return _rdBaseStateInfo;
}

- (NSDate *) lastUserActivity
{
    return _rdLastUserActivity;
}

- (NSDate *) lastNetActivity
{
    return _rdLastNetActivity;
}

- (NSDate *) connectedSince
{
    return _rdConnectedOn;
}

- (void) fireEventsForState:(AtlantisState *)state
{
    BOOL highlighted = NO;

    if (![[state extraDataForKey:@"event.cause"] isEqualToString:@"line"]) {
        [[RDAtlantisMainController controller] fireScriptedEventsForState:state];
    }

    if ([state stringData] && [[RDAtlantisMainController controller] globalHighlights]) {
        NSEnumerator *highlightEnum = [[[RDAtlantisMainController controller] globalHighlights] objectEnumerator];
        
        HighlightEvent *highlightWalk;
        
        while (highlightWalk = [highlightEnum nextObject]) {
            BOOL thisHighlight = [highlightWalk highlightLine:[state stringData]];
            highlighted = highlighted || thisHighlight;
        }
    }
    if ([state stringData] && _rdHighlights) {
        NSEnumerator *highlightEnum = [_rdHighlights objectEnumerator];
        
        HighlightEvent *highlightWalk;
        
        while (highlightWalk = [highlightEnum nextObject]) {
            BOOL thisHighlight = [highlightWalk highlightLine:[state stringData]];
            highlighted = highlighted || thisHighlight;
        }
    }
    
    if (highlighted) {
        [state setExtraData:@"yes" forKey:@"event.highlighted"];
    }
    else {
        [state setExtraData:@"no" forKey:@"event.highlighted"];    
    }
    
    if ([[RDAtlantisMainController controller] globalEvents]) {
        NSEnumerator *eventEnum = [[[RDAtlantisMainController controller] globalEvents] objectEnumerator];
        WorldEvent *eventWalk;
        
        while (eventWalk = [eventEnum nextObject]) {
            if ([eventWalk shouldExecute:state])
                [eventWalk executeForState:state];
        }    
    }
    if (_rdEvents) {
        NSEnumerator *eventEnum = [_rdEvents objectEnumerator];
        WorldEvent *eventWalk;
        
        while (eventWalk = [eventEnum nextObject]) {
            if ([eventWalk shouldExecute:state])
                [eventWalk executeForState:state];
        }
    }
}

- (void) netsync
{
    if (_rdNetSync && ![self isConnected] && ![self isConnecting]) {
        [self disconnectWithMessage:@"Network error, connection lost."];
        _rdNeedsReconnect = YES;
    }
    else if ([self isConnected] && [_rdOutputBuffer length]) {
        [self sendCurrentBuffer];
    }
    
    NSEnumerator *spawnEnum = [_rdSpawns objectEnumerator];
    RDAtlantisSpawn *spawnWalk;
    
    while (spawnWalk = [spawnEnum nextObject]) {
        [spawnWalk updateStatusBar];
    }
}

- (void) addQueuedAction:(BaseAction *)action withDelay:(NSTimeInterval)delay
{
    DelayedEvent *event = [[DelayedEvent alloc] init];
    [event eventAddAction:action];
    [event setTargetDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
    [_rdDelayQueue addObject:event];
    [event release];
}

- (void) fireTimerEvents
{
    AtlantisState *state = [[AtlantisState alloc] initWithString:nil inWorld:self forSpawn:nil];
    [state setExtraData:@"timer" forKey:@"event.cause"];
    
    [self fireEventsForState:state];

    NSEnumerator *delayEnum = [_rdDelayQueue objectEnumerator];
    DelayedEvent *event;
    while (event = [delayEnum nextObject]) {
        NSDate *testDate = [event targetDate];
        if (testDate && [testDate isLessThanOrEqualTo:[NSDate date]]) {
            [event executeForState:state];
            [_rdDelayQueue removeObject:event];
        }
    }
    
    [state release]; 
}

- (void) fireEventsForString:(NSMutableAttributedString *)workString onSpawn:(RDAtlantisSpawn *)spawn withState:(AtlantisState *)baseState
{
    BOOL focused = NO;
    AtlantisState *state = baseState;

    if (!state) {
        state = [[AtlantisState alloc] initWithString:workString inWorld:self forSpawn:spawn];
        [state setExtraData:@"line" forKey:@"event.cause"];
    }
    else {
        [state resetForSpawn:spawn];
        [state resetForString:workString];
        [state setExtraData:@"line" forKey:@"event.cause"];
    }
    
    id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];
    if (curView && (curView == spawn)) {
        focused = YES;
    }
        
    [self fireEventsForState:state];
    
    if ([_rdLogfiles count] && [workString length]) {
        NSRange effRange;    
        NSDictionary *attrs = [workString attributesAtIndex:0 effectiveRange:&effRange];
    
        if (![attrs objectForKey:@"RDLogOmitLine"]) {
            NSEnumerator *logEnum = [_rdLogfiles objectEnumerator];
            
            RDLogType *logWalk;
            
            while (logWalk = [logEnum nextObject]) {
                if ([logWalk shouldWriteForState:state])
                    [logWalk writeString:workString withState:state];
            }
        }
    }

    if (!baseState)
        [state release];
}

- (void) setTemp:(BOOL) temp
{
    _rdTempWorld = temp;
}

- (BOOL) isTemp
{
    return _rdTempWorld;
}

- (void) addUploader:(UploadEngine *) uploader
{
    if (![_rdUploaders containsObject:uploader])
        [_rdUploaders addObject:uploader];
}

- (void) removeUploader:(UploadEngine *) uploader
{
    if ([_rdUploaders containsObject:uploader])
        [_rdUploaders removeObject:uploader];
}

- (void) killAllUploaders
{
    [_rdUploaders removeAllObjects];
}

- (void) addLogfile:(RDLogType *)logfile
{
    if (![_rdLogfiles containsObject:logfile])
        [_rdLogfiles addObject:logfile];
}

- (void) removeLogfile:(RDLogType *)logfile
{
    if ([_rdLogfiles containsObject:logfile]) {
        [logfile closeFile];
        [_rdLogfiles removeObject:logfile];
    }
}

- (NSArray *) logfiles
{
    return _rdLogfiles;
}

- (void) closeAllLogfiles
{
    if (_rdLogfiles) {
        NSEnumerator *logEnum = [_rdLogfiles objectEnumerator];
        
        RDLogType *logWalk;
        
        while (logWalk = [logEnum nextObject]) {
            [logWalk closeFile];
        }
        [_rdLogfiles removeAllObjects];
    }
}

- (void) addMcpPacket:(MCPMessage *)packet
{
    if (![_rdMcpPackets containsObject:packet])
        [_rdMcpPackets addObject:packet];
}

- (void) removeMcpPacket:(MCPMessage *)packet
{
    if ([_rdMcpPackets containsObject:packet])
        [_rdMcpPackets removeObject:packet];

    NSEnumerator *tagEnum = [_rdMcpTags keyEnumerator];
    
    NSString *tagWalk;
    
    while (tagWalk = [tagEnum nextObject]) {
        MCPMessage *tempPacket = [_rdMcpTags objectForKey:tagWalk];
        if (tempPacket == packet) {
            [_rdMcpTags removeObjectForKey:tagWalk];
        }
    }
}

- (void) mapMcpPacket:(MCPMessage *)packet toTag:(NSString *)tag
{
    [_rdMcpTags setObject:packet forKey:tag];
}

- (MCPMessage *) mcpPacketForTag:(NSString *)tag
{
    return [_rdMcpTags objectForKey:tag];
}

- (NSString *) mcpSessionKey
{
    if (!_rdMcpSessionKey) {
        _rdMcpSessionKey = [[NSString stringWithFormat:@"%ul", [[NSDate date] timeIntervalSinceReferenceDate]] retain];
    }
    
    return _rdMcpSessionKey;
}

- (void) addMcpPackage:(NSString *)package min:(float)minVersion max:(float)maxVersion
{
    NSMutableDictionary *pkgInfo = [_rdMcpPackages objectForKey:package];
    
    if (!pkgInfo) {
        pkgInfo = [[[NSMutableDictionary alloc] init] autorelease];
        [_rdMcpPackages setObject:pkgInfo forKey:package];
    }    
    [pkgInfo setObject:[NSNumber numberWithFloat:minVersion] forKey:@"version-min"];
    [pkgInfo setObject:[NSNumber numberWithFloat:maxVersion] forKey:@"version-max"];
}

- (BOOL) supportsMcpPackage:(NSString *)package
{
    NSDictionary *pkgInfo = [_rdMcpPackages objectForKey:package];
    if (pkgInfo)
        return YES;

    return NO;
}


- (BOOL) supportsMcpPackage:(NSString *)package version:(float)version
{
    NSDictionary *pkgInfo = [_rdMcpPackages objectForKey:package];
    if (!pkgInfo)
        return NO;
        
    float minVersion = [[pkgInfo objectForKey:@"version-min"] floatValue];
    float maxVersion = [[pkgInfo objectForKey:@"version-max"] floatValue];
    
    if ((version >= minVersion) && (version <= maxVersion))
        return YES;
        
    return NO;
}


- (BOOL) supportsMCP
{
    return (_rdMcpDisabled ? NO : (_rdMcpSessionKey != nil));
}

- (BOOL) mcpDisabled
{
    return _rdMcpDisabled;
}

- (BOOL) mcpNegotiated
{
    return _rdMcpNegotiated;
}

- (void) setMcpNegotiated:(BOOL) negotiated
{
    _rdMcpNegotiated = YES;
}

- (BOOL) shouldReconnect
{
    return _rdNeedsReconnect;
}

- (void) setShouldReconnect:(BOOL) reconnect
{
    _rdNeedsReconnect = YES;
}

- (void) compress:(BOOL) compress
{
    BOOL oldCompress = _rdIsCompressing;
    _rdIsCompressing = compress;
    
    if (oldCompress != _rdIsCompressing) {
        NSEnumerator *filterEnum = [_rdInputFilters objectEnumerator];
        RDAtlantisFilter *filter;
        
        while (filter = [filterEnum nextObject]) {
            [filter worldWasRefreshed];
        }        
    }
}

- (void) addBytesToCompress:(NSData *) dataBytes
{
    NSEnumerator *filterEnum = [_rdInputFilters objectEnumerator];
    RDAtlantisFilter *filter;
    
    while (filter = [filterEnum nextObject]) {
        if ([filter isKindOfClass:[RDCompressionFilter class]]) {
            [(RDCompressionFilter *)filter addBytesToHoldover:dataBytes];
        }
    }           
}

- (BOOL) isCompressing
{
    return _rdIsCompressing;
}

- (BOOL) isSSL
{
    if (![self isConnected])
        return NO;
        
    BOOL result = NO;
    
    id keyValue = [_rdInputStream propertyForKey:NSStreamSocketSecurityLevelKey];
    
    if (keyValue && (keyValue != NSStreamSocketSecurityLevelNone)) {
        result = YES;
    }
    
    return result;
}

#pragma mark View/UI Management

- (NSString *) basePath
{
    return _rdBaseViewPath;
}

- (int) mainScreenWidth
{
    return [_rdMainView screenWidth];
}

- (int) mainScreenHeight
{
    return [_rdMainView screenHeight];
}

- (void) closeAndRemove
{
    if (_rdShuttingDown)
        return;
        
    _rdShuttingDown = YES;

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self closeAllLogfiles];

    if ([self isConnected])
        [self disconnectWithMessage:@"Disconnected due to world closure."];

    AtlantisState *state = [[AtlantisState alloc] initWithString:nil inWorld:self forSpawn:_rdMainView];
    [state setExtraData:@"statechange" forKey:@"event.cause"];
    [state setExtraData:@"closed" forKey:@"event.statechange"];        
    [self fireEventsForState:state];
    [state release];

        
    if (_rdSpawns) {
        NSEnumerator *spawnEnum = [_rdSpawns objectEnumerator];
        
        RDAtlantisSpawn *spawnWalk;
        NSMutableArray *safeRemoves = [[NSMutableArray alloc] init];
        
        while (spawnWalk = [spawnEnum nextObject]) {
            [safeRemoves addObject:[spawnWalk viewUID]];
            [_rdSpawns removeObjectForKey:[spawnWalk internalPath]];
        }
        
        spawnEnum = [safeRemoves objectEnumerator];
        NSString *uidWalk;
        
        while (uidWalk = [spawnEnum nextObject]) {
            id <RDNestedViewDescriptor> checkMe = [[RDNestedViewManager manager] viewByUid:uidWalk];
            if (checkMe) {
                [[RDNestedViewManager manager] removeView:checkMe];
            }
        }
    
        [safeRemoves release];
        
    }
    [[RDAtlantisMainController controller] saveWorld:_rdPreferences];
    [[RDAtlantisMainController controller] removeWorld:self];
}

- (NSString *) realPathForSpawn:(NSString *) path
{
    NSString *realPath; 
    
    if ([path isEqualToString:@""]) {
        realPath = _rdBaseViewPath;
    }
    else {
        realPath = [NSString stringWithFormat:@"%@:%@", _rdBaseViewPath, path];
    }
    
    return realPath;
}

- (RDAtlantisSpawn *) mainSpawn
{
    return _rdMainView;
}

- (RDAtlantisSpawn *) spawnForPath:(NSString *)path withPreferences:(RDSpawnConfigRecord *)prefs
{
    RDAtlantisSpawn *view = (RDAtlantisSpawn *)[_rdSpawns objectForKey:path];
    
    if (!view) {
        NSString *realPath = [self realPathForSpawn:path]; 
        view = [[RDAtlantisSpawn alloc] initWithPath:realPath forInstance:self withPrefs:prefs];
        if (_rdDisplayFont)
            [view setFont:_rdDisplayFont];
        else
            [view setFont:[NSFont userFixedPitchFontOfSize:10.0f]];
        
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
            [self preferenceForKey:@"atlantis.colors.url"],NSForegroundColorAttributeName,
            [NSNumber numberWithInt:NSUnderlineStyleSingle],NSUnderlineStyleAttributeName,
            [NSCursor pointingHandCursor],NSCursorAttributeName,nil];

        [view setLinkStyle:tempDict];        
        [view setParagraphStyle:[self formattingParagraphStyle]];
        [view setInternalPath:path];
        [_rdSpawns setObject:view forKey:path];
        [view autorelease];
        if ([_rdSpawnPrefixes objectForKey:path])
            [view setPrefix:[_rdSpawnPrefixes objectForKey:path]];
    }
    
    return view;
}

- (NSEnumerator *) spawnEnumerator
{
    return [_rdSpawns objectEnumerator];
}

- (unsigned int) countOpenSpawns
{
    return [_rdSpawns count] + 1;
}

- (void) notesDisplay
{
    if (!_rdWorldNotes) {
        _rdWorldNotes = [[WorldNotesView alloc] initForWorld:self];
    }
    [[RDNestedViewManager manager] selectView:_rdWorldNotes];
}

- (void) notesClose
{
    if (_rdWorldNotes) {
        [_rdWorldNotes release];
        _rdWorldNotes = nil;
        [[RDAtlantisMainController controller] saveWorld:_rdPreferences];
    }
}

- (void) setPrefix:(NSString *)prefix forSpawnPath:(NSString *)internalPath
{
    if ([internalPath isEqualToString:@""]) {
        return;
    }
    else {
        NSMutableDictionary *spawns = [[self realPreferenceForKey:@"atlantis.spawns"] mutableCopy];
        
        RDSpawnConfigRecord *tempRecord = [spawns objectForKey:internalPath];
        if (tempRecord) {
            [tempRecord setPrefix:prefix];
            NSDictionary *newSpawns = [NSDictionary dictionaryWithDictionary:spawns];
            [_rdPreferences setPreference:newSpawns forKey:@"atlantis.spawns" withCharacter:[self character]];
        }        
        else {
            RDAtlantisSpawn *tempSpawn = [_rdSpawns objectForKey:internalPath];
            if (tempSpawn)
                [tempSpawn setPrefix:prefix];
            else
                [_rdSpawnPrefixes setObject:prefix forKey:internalPath];
        }
        [spawns release];        
    }
}

- (void) hideStatusBar:(BOOL)hidden forSpawnPath:(NSString *)internalPath
{
    if ([internalPath isEqualToString:@""]) {
        [_rdPreferences setPreference:[NSNumber numberWithBool:!hidden] forKey:@"atlantis.mainview.statusBar" withCharacter:[self character]];
    }
    else {
        NSMutableDictionary *spawns = [[self realPreferenceForKey:@"atlantis.spawns"] mutableCopy];
        
        RDSpawnConfigRecord *tempRecord = [spawns objectForKey:internalPath];
        if (tempRecord) {
            [tempRecord setStatusBar:!hidden];
            NSDictionary *newSpawns = [NSDictionary dictionaryWithDictionary:spawns];
            [_rdPreferences setPreference:newSpawns forKey:@"atlantis.spawns" withCharacter:[self character]];
        }
        else {
            RDAtlantisSpawn *tempSpawn = [_rdSpawns objectForKey:internalPath];
            if (tempSpawn)
                [tempSpawn setStatusBarHidden:hidden];
        }
        
        [spawns release];        
    }
}

- (RDSpawnConfigRecord *) configForSpawn:(NSString *) internalPath
{
    if (internalPath && [internalPath isEqualToString:@""]) {
        RDSpawnConfigRecord *tempRecord;

        NSNumber *mainWeight = [self realPreferenceForKey:@"atlantis.mainview.weight"];
        NSNumber *mainActivity = [self realPreferenceForKey:@"atlantis.mainview.activity"];
        NSNumber *mainLines = [self realPreferenceForKey:@"atlantis.mainview.lines"];
        NSNumber *mainStatus = [self realPreferenceForKey:@"atlantis.mainview.statusBar"];
        
        BOOL activity = YES;
        BOOL statusBar = YES;
        unsigned weight = 1;
        unsigned lines = 0;
        if (mainWeight)
            weight = [mainWeight intValue];
        if (mainActivity)
            activity = [mainActivity boolValue];
        if (mainLines)
            lines = [mainLines intValue];
        if (mainStatus)
            statusBar = [mainStatus boolValue];
        
        tempRecord = [[RDSpawnConfigRecord alloc] initWithPath:@"" forPatterns:nil withExceptions:nil weight:weight defaultsActive:activity activePatterns:nil maxLines:lines prefix:nil statusBar:statusBar];
        return tempRecord;
    }
    else {
        NSEnumerator *spawnEnum = [_rdSpawnPreferences objectEnumerator];
        
        RDSpawnConfigRecord *walk;
        RDSpawnConfigRecord *result = nil;
        
        while (!result && (walk = [spawnEnum nextObject])) {
            if ([[walk path] isEqualToString:internalPath]) {
                result = walk;
            }
        }
        return result;
    }
}

- (void) spawnWasClosed:(RDAtlantisSpawn *) spawn
{
    [_rdSpawns removeObjectForKey:[spawn internalPath]];
}

- (void) handleStatusOutput:(NSString *) string onSpawn:(RDAtlantisSpawn *)spawn
{
    if (_rdMainView) {
        NSColor *realColor = [self preferenceForKey:@"atlantis.colors.system"];
        if (!realColor) {
            realColor = [NSColor yellowColor];
        }
        
        NSAttributedString *realString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%%%% %@", string]  
                                                                         attributes:[NSDictionary dictionaryWithObjectsAndKeys:realColor,NSForegroundColorAttributeName,_rdDisplayFont,NSFontAttributeName,[self formattingParagraphStyle],NSParagraphStyleAttributeName,[NSDate date],@"RDTimeStamp",@"console",@"RDLineClass",[NSNumber numberWithInt:NSUTF8StringEncoding], NSCharacterEncodingDocumentAttribute, nil]];
        
        [spawn ensureNewline];
        [spawn appendString:realString];
        [realString release];
    }
}

- (void) handleLocalEcho:(NSString *) string onSpawn:(RDAtlantisSpawn *)spawn withState:(AtlantisState *)prevState
{
    if (_rdMainView) {
        NSColor *realColor = [self preferenceForKey:@"atlantis.colors.system"];
        if (!realColor) {
            realColor = [NSColor yellowColor];
        }
        
        NSAttributedString *realString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@\n", _rdLocalEchoPrefix, string]  
                                                                         attributes:[NSDictionary dictionaryWithObjectsAndKeys:realColor,NSForegroundColorAttributeName,_rdDisplayFont,NSFontAttributeName,[self formattingParagraphStyle],NSParagraphStyleAttributeName,[NSDate date],@"RDTimeStamp",@"localEcho",@"RDLineClass",[NSNumber numberWithInt:NSUTF8StringEncoding],NSCharacterEncodingDocumentAttribute, nil]];

        _rdMudPrompted = NO;        
        [spawn ensureNewline];
        [spawn appendString:realString];
        NSMutableAttributedString *workString = [realString mutableCopy];

        AtlantisState *state = nil;
        
        if (prevState)
            state = prevState;
        else
            state = [[AtlantisState alloc] initWithString:workString inWorld:self forSpawn:spawn];

        [state setExtraData:@"line" forKey:@"event.cause"];
        
        if ([_rdLogfiles count]) {
            NSEnumerator *logEnum = [_rdLogfiles objectEnumerator];
            
            RDLogType *logWalk;
            
            while (logWalk = [logEnum nextObject]) {
                if ([logWalk shouldWriteForState:state])
                    [logWalk writeString:workString withState:state];
            }
        }
        [workString release];
        [realString release];
        if (!prevState)
            [state release];
    }
}


- (void) handleStatusOutput:(NSString *) string
{
    if (_rdMainView) {
        [self handleStatusOutput:string onSpawn:_rdMainView];
    }
}

- (void) outputStatus:(NSString *) string toSpawn:(NSString *)spawnPath
{
    RDAtlantisSpawn *spawn = _rdMainView;
    
    if (spawnPath)
        spawn = [_rdSpawns objectForKey:spawnPath];
    
    if (!spawn) {
        RDSpawnConfigRecord *prefs = [_rdSpawnPreferences objectForKey:spawnPath];
        spawn = [self spawnForPath:spawnPath withPreferences:prefs];
    }
    
    if (spawn) {
        [self handleStatusOutput:[NSString stringWithFormat:@"%@\n",string] onSpawn:spawn];
    }
}


- (void) text:(NSAttributedString *)string toSpawn:(RDAtlantisSpawn *)spawn processEvents:(BOOL) events withState:(AtlantisState *)state
{
    if (!string && ![string length])
        return;
        
    NSMutableAttributedString *workString = [string mutableCopy];

    if (events) {
        [self fireEventsForString:workString onSpawn:spawn withState:state];
    }
    
    if (![workString length]) {
        [workString release];
        return;
    }

    NSRange effRange;
    NSDictionary *attrs = [workString attributesAtIndex:0 effectiveRange:&effRange];
    if (![attrs objectForKey:@"RDScreenOmitLine"]) {            
        NSArray *otherSpawns;
        NSNumber *moveNotCopy;
        BOOL activity;
        
        moveNotCopy = [attrs objectForKey:@"RDExtraSpawnMove"];
        otherSpawns = [attrs objectForKey:@"RDExtraSpawns"];
        
        if (otherSpawns) {
            NSEnumerator *otherSpawnEnum = [otherSpawns objectEnumerator];
            
            NSString *walk;
            
            while (walk = [otherSpawnEnum nextObject]) {
                RDSpawnConfigRecord *spawnConfig = [self configForSpawn:walk];
                RDAtlantisSpawn *tempSpawn = [self spawnForPath:walk withPreferences:spawnConfig];
            
                activity = [tempSpawn wantsActiveFor:[workString string]];
                
                [tempSpawn appendString:workString];
                if (activity && ![attrs objectForKey:@"RDActivityOmitLine"])
                    [[RDNestedViewManager manager] view:tempSpawn hasActivity:YES];
            }
        }
        
        if (!moveNotCopy || ![moveNotCopy boolValue]) {        
            activity = [spawn wantsActiveFor:[workString string]];
            
            [spawn appendString:workString];
            if (activity && ![attrs objectForKey:@"RDActivityOmitLine"])
                [[RDNestedViewManager manager] view:spawn hasActivity:YES];
                
        }
    }
    [workString release];
}

- (void) handleOutput:(NSAttributedString *) string
{
    BOOL spawned = NO;
    NSRange dummyRange;
    
    NSString *compareString = [string string];

    if (_rdGrabPattern) {
        if ([_rdGrabPattern patternMatchesString:compareString]) {
            int patternLength = [[_rdGrabPattern pattern] length];
            NSRange tempRange = NSMakeRange(patternLength, [compareString length] - patternLength - 1); 
            NSMutableString *grabbedString = [[compareString substringWithRange:tempRange] mutableCopy];
            [grabbedString replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0,[grabbedString length])];
            [grabbedString replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:NSMakeRange(0,[grabbedString length])];
            NSString *attrName = [[grabbedString componentsSeparatedByString:@" "] objectAtIndex:0];
            if ([attrName isEqualToString:@"name"] || [attrName isEqualToString:@"desc"]) {
                [_rdMainView stringIntoInput:[NSString stringWithFormat:@"@%@", grabbedString]];
            }
            else {
                [_rdMainView stringIntoInput:[NSString stringWithFormat:@"&%@", grabbedString]];
            }
            [grabbedString release];
            return;
        }
    }
    
    if (_rdFuguePattern) {
        if ([_rdFuguePattern patternMatchesString:compareString]) {
            BOOL fugueMe = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.grab.fugueedit"];
            if (fugueMe) {
                int patternLength = [[_rdFuguePattern pattern] length];
                NSRange tempRange = NSMakeRange(patternLength, [compareString length] - patternLength - 1); 
                [_rdMainView stringIntoInput:[NSString stringWithFormat:@"%@", [compareString substringWithRange:tempRange]]];
                return;
            }
        }
    }

    NSMutableAttributedString *workString = [string mutableCopy];
    BOOL needsNewline = NO;


    if ([workString length]) {
        if (_rdMudPrompted) {
            if ([[workString string] characterAtIndex:0] == '\n') {
                [workString replaceCharactersInRange:NSMakeRange(0,1) withString:@""];
                _rdMudPrompted = NO;
            }
        }
    
        if ([workString length] && [workString attribute:@"RDPromptMarker" atIndex:0 effectiveRange:&dummyRange]) {
            _rdMudPrompted = YES;
        }
    }
    
    // Any line-type scripted events get fired BEFORE all the spawn-walking and highlights.
    AtlantisState *state = [[AtlantisState alloc] initWithString:workString inWorld:self forSpawn:_rdMainView];
    [state setExtraData:@"line" forKey:@"event.cause"];
    [[RDAtlantisMainController controller] fireScriptedEventsForState:state];

    BOOL scriptSpawned = NO;
    
    NSAttributedString *newline = nil;
    if (needsNewline) {
        NSDictionary *attrs = nil;
        if ([workString length]) {
            attrs = [workString attributesAtIndex:0 effectiveRange:&dummyRange];
            if ([attrs objectForKey:@"RDExtraSpawns"]) {
                if ([[attrs objectForKey:@"RDExtraSpawnMove"] boolValue])
                    scriptSpawned = YES;            
            }
        } 
        newline = [[NSAttributedString alloc] initWithString:@"\n" attributes:attrs]; 
    }

    compareString = [workString string];
    [state setExtraData:compareString forKey:@"event.line"];
    
    if (_rdSpawnPreferences && !scriptSpawned) {
        NSEnumerator *spawnEnum = [_rdSpawnPreferences objectEnumerator];
        
        id walk;
        
        while (walk = [spawnEnum nextObject]) {
            RDSpawnConfigRecord *spawnRec = (RDSpawnConfigRecord *)walk;
            
            if ([spawnRec matches:compareString]) {
                RDAtlantisSpawn *tempSpawn = [self spawnForPath:[spawnRec path] withPreferences:spawnRec];
                if (tempSpawn) {
                    spawned = YES;
                    [self text:workString toSpawn:tempSpawn processEvents:YES withState:state];
                }
            }
        }
    }

    if (!spawned) {
        [self text:workString toSpawn:_rdMainView processEvents:YES withState:state];
    }
    [newline release];    
    [workString release];
    [state release];
}

- (void) processInputString:(NSString *)string onSpawn:(RDAtlantisSpawn *)eventSpawn
{
    NSMutableString *baseString = [[string mutableCopy] autorelease];
    BOOL handledAsCommand = NO;
    BOOL noSlashies = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.input.noSlashies"];
    BOOL hasSlash = NO;
    RDAtlantisSpawn *spawn = eventSpawn;

    // Nuke obnoxious Lion ellipsis conversion.
    [baseString replaceOccurrencesOfString:[NSString stringWithCString:"\311"] withString:@"..." options:0 range:NSMakeRange(0,[baseString length])];
    
    if (!spawn)
        spawn = _rdMainView;

    AtlantisState *state = [[AtlantisState alloc] initWithString:nil inWorld:self forSpawn:spawn];
    [[[RDAtlantisMainController controller] scriptDispatch] refreshEngines:state];

    if ([baseString length] == 0) {
        [self sendString:baseString];
        if (_rdLocalEcho)
            [self handleLocalEcho:baseString onSpawn:spawn withState:state];
        [state release];
        return;
    }
    
    hasSlash = ([baseString characterAtIndex:0] == '/');
    
    if (hasSlash || noSlashies) {
        if (!noSlashies && hasSlash && ([baseString length] > 1) && ([baseString characterAtIndex:1] == '/')) {
            [baseString replaceCharactersInRange:NSMakeRange(0,1) withString:@""];
        }
        else {
            handledAsCommand = YES;
            
            // Parse and set up the state
            NSString *commandName;
            NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
            
            NSRange searchRange = [baseString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
            if (searchRange.location == NSNotFound) {
                commandName = [baseString substringFromIndex:hasSlash ? 1 : 0];
            }
            else {
                commandName = [baseString substringWithRange:NSMakeRange(hasSlash ? 1 : 0,searchRange.location - (hasSlash ? 1 : 0))];
                
                NSString *restOfString = [baseString substringFromIndex:(searchRange.location + searchRange.length)];
                
                [options addEntriesFromDictionary:[restOfString optionsFromString]];                
            }
            
            BaseCommand *command = [[RDAtlantisMainController controller] commandForText:commandName];
            if (command && hasSlash) {
                [state setExtraData:@"command" forKey:@"event.cause"];
                [state setExtraData:commandName forKey:@"event.command"];
                [state setExtraData:options forKey:@"RDCommandParams"];
                
                NSString *checkInvalid = [command checkOptionsForState:state];
                if (checkInvalid && ![checkInvalid isEqualToString:@""]) {
                    [self handleStatusOutput:[NSString stringWithFormat:@"Cannot execute '%@': %@\n", commandName, checkInvalid] onSpawn:spawn];
                }
                else {
                    [command executeForState:state];
                }
            }
            else {
                AliasEvent *eventResult = nil;
                AliasEvent *walk;
                NSEnumerator *aliasEnum = [_rdAliases objectEnumerator];
                
                while (!eventResult && (walk = [aliasEnum nextObject])) {
                    if ([[[walk eventName] lowercaseString] isEqualToString:[commandName lowercaseString]]) {
                        eventResult = walk;
                    }
                }
                
                if (!eventResult) {
                    aliasEnum = [[[RDAtlantisMainController controller] globalAliases] objectEnumerator];
                    
                    while (!eventResult && (walk = [aliasEnum nextObject])) {
                        if ([walk isEnabled] && [[[walk eventName] lowercaseString] isEqualToString:[commandName lowercaseString]]) {
                            eventResult = walk;
                        }
                    }
                }
                
                if (eventResult) {
                    [state setExtraData:@"command" forKey:@"event.cause"];
                    [state setExtraData:commandName forKey:@"event.command"];
                    [state setExtraData:options forKey:@"RDCommandParams"];
                    [eventResult executeForState:state];
                }
                else {
                    [state setExtraData:@"command" forKey:@"event.cause"];
                    [state setExtraData:commandName forKey:@"event.command"];
                    [state setExtraData:options forKey:@"RDCommandParams"];
                    BOOL handledInScripts = [[RDAtlantisMainController controller] fireScriptedEventsForAlias:commandName withState:state];
                                  
                    if (noSlashies && !handledInScripts)
                        handledAsCommand = NO;
                    else if (!handledInScripts)
                        [self handleStatusOutput:[NSString stringWithFormat:@"Unknown command '%@'\n", commandName] onSpawn:spawn];
                    else
                        handledAsCommand = YES;
                }
            }                        
        }    
    } 
    
    if (!handledAsCommand) {
        if (_rdInputStream && (([_rdInputStream streamStatus] == NSStreamStatusOpen) || ([_rdInputStream streamStatus] == NSStreamStatusReading))) {
            if (![baseString canBeConvertedToEncoding:_rdOutputEncoding]) {
                
                // Attempt our 'default' fallback to get rid of Unicode markup, then try once more
                [baseString replaceOccurrencesOfString:[NSString stringWithCString:"\320"] withString:@"-" options:0 range:NSMakeRange(0,[baseString length])];
                [baseString replaceOccurrencesOfString:[NSString stringWithCString:"\324"] withString:@"'" options:0 range:NSMakeRange(0,[baseString length])];
                [baseString replaceOccurrencesOfString:[NSString stringWithCString:"\325"] withString:@"'" options:0 range:NSMakeRange(0,[baseString length])];
                [baseString replaceOccurrencesOfString:[NSString stringWithCString:"\322"] withString:@"\"" options:0 range:NSMakeRange(0,[baseString length])];
                [baseString replaceOccurrencesOfString:[NSString stringWithCString:"\323"] withString:@"\"" options:0 range:NSMakeRange(0,[baseString length])];
                
                if (![baseString canBeConvertedToEncoding:_rdOutputEncoding]) {                
                    // Give up and warn...
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.input.silentConvert"])
                        [self handleStatusOutput:@"Your input contained Unicode characters that this server cannot understand; you may have pasted from Word or something similar.  Atlantis will attempt to convert it all to be usable, but some characters may be lost in the process.\n" onSpawn:spawn];
                }
            }
            
            [self sendString:baseString];
            if (_rdLocalEcho)
                [self handleLocalEcho:baseString onSpawn:spawn withState:state];
        }
        else {
            [self handleStatusOutput:@"World is not connected.\n" onSpawn:spawn];
        }
    }

    [state release];
}

- (void) handleLocalInput:(NSAttributedString *) string onSpawn:(RDAtlantisSpawn *) spawn
{
    if (![string length]) {
        [self sendString:@""];
        return;
    }
    NSMutableString *origString = [[string string] mutableCopy];
    
    if ([origString length]) 
        [self addToCommandHistory:origString];
    [self setCommandHoldover:nil];
    [self setCommandHistoryPoint:-1];
    
    [_rdLastUserActivity release];
    _rdLastUserActivity = [[NSDate date] retain];
    
    [origString replaceOccurrencesOfString:@"\r\n" withString:@"\n" options:0 range:NSMakeRange(0,[origString length])];
    [origString replaceOccurrencesOfString:@"\n\r" withString:@"\n" options:0 range:NSMakeRange(0,[origString length])];
    [origString replaceOccurrencesOfString:@"\r" withString:@"\n" options:0 range:NSMakeRange(0,[origString length])];
    
    NSArray *stringArray = [origString componentsSeparatedByString:@"\n"];
    
    NSString *tempString;
    NSEnumerator *stringEnum = [stringArray objectEnumerator];
    
    while (tempString = [stringEnum nextObject]) {
        [self processInputString:tempString onSpawn:spawn];
    }
    
    [origString release];
}

- (void) sendCurrentBuffer
{
    int length = [_rdOutputBuffer length];
    if ([self isConnected] && length) {
        if ([_rdOutputStream hasSpaceAvailable]) {            
            int result = [_rdOutputStream write:[_rdOutputBuffer bytes] maxLength:length];
            if (result) {
                NSMutableData *oldData = _rdOutputBuffer;
                if (length == result) {
                    _rdOutputBuffer = [[NSMutableData alloc] init];
                }
                else {
                    NSData *tempdata = [_rdOutputBuffer subdataWithRange:NSMakeRange(result,length - result)];
                    _rdOutputBuffer = [tempdata mutableCopy];                
                }
                [oldData release]; 
            }
        }
    }
}

- (void) sendDataRaw:(NSData *)data
{
    [_rdLastNetActivity release];
    _rdLastNetActivity = [[NSDate date] retain];

    [_rdOutputBuffer appendData:data];
    [self sendCurrentBuffer];
}

- (void) sendData:(NSData *)data
{
    NSMutableData *mutableData = [data mutableCopy];

    NSEnumerator *filterEnum = [_rdInputFilters reverseObjectEnumerator];
    RDAtlantisFilter *filter;
    
    while (filter = [filterEnum nextObject]) {
        [filter filterOutput:mutableData];
    }       

    [self sendDataRaw:mutableData];
    [mutableData release];
}

- (void) sendString:(NSString *) string
{
    NSMutableString *realString = [string mutableCopy];
    if (!_rdAlternateLinefeed)    
        [realString appendString:@"\n"];
    else 
        [realString appendString:@"\r\n"];

    NSEnumerator *filterEnum = [_rdInputFilters reverseObjectEnumerator];
    RDAtlantisFilter *filter;
    
    while (filter = [filterEnum nextObject]) {
        [filter filterOutput:realString];
    }       

    NSData *tempData = [realString dataUsingEncoding:_rdOutputEncoding allowLossyConversion:YES];
    
    [self sendData:tempData];
    [realString release];
}

- (NSFont *) displayFont
{
    return _rdDisplayFont;
}

- (NSParagraphStyle *) formattingParagraphStyle
{
    return _rdParaStyle;
}

- (NSArray *) commandHistory
{
    return _rdCommandHistory;
}

- (void) addToCommandHistory:(NSString *)string
{
    if (![_rdCommandHistory count] || ![[_rdCommandHistory objectAtIndex:0] isEqualToString:string]) {
        [_rdCommandHistory insertObject:string atIndex:0];
        int count = [_rdCommandHistory count];
        if (count > 150) {
            [_rdCommandHistory removeObjectsInRange:NSMakeRange(149,count - 150)];
        }
    }
}

- (int) commandHistoryPoint
{
    return _rdHistoryPointer;
}

- (void) setCommandHistoryPoint:(int) history
{
    if (history <= -1) {
        _rdHistoryPointer = -1;
    }
    else if (history >= [_rdCommandHistory count]) {
        _rdHistoryPointer = [_rdCommandHistory count] - 1;
    }
    else {
        _rdHistoryPointer = history;
    }
}

- (NSString *) commandHoldover
{
    return _rdCommandHoldover;
}

- (void) setCommandHoldover:(NSString *)holdover
{
    [_rdCommandHoldover release];
    _rdCommandHoldover = nil;
    if (holdover)
        _rdCommandHoldover = [holdover retain];
}

- (void) setStringEncoding:(NSStringEncoding) encoding
{
    _rdInputEncoding = encoding;
    _rdOutputEncoding = encoding;
}

- (NSStringEncoding) stringEncoding
{
    if (_rdInputEncoding != _rdOutputEncoding)
        return -1;

    return _rdOutputEncoding;
}

#pragma mark Network Interface

- (void) connect
{
    if ([self isConnected] || [self isConnecting])
        return;

    if (_rdMcpSessionKey) {
        [_rdMcpSessionKey release];
        _rdMcpSessionKey = nil;
    }
    
    [_rdMcpPackages removeAllObjects];
    
    _rdMudPrompted = NO;
    
    _rdMcpNegotiated = NO;
    
    _rdInputEncoding = NSISOLatin1StringEncoding;
    _rdOutputEncoding = NSASCIIStringEncoding;
    
    NSNumber *encoding = [self preferenceForKey:@"atlantis.encoding"];
    if (encoding) {
        int enc = [encoding intValue];
        if (enc) {
            _rdInputEncoding = enc;
            _rdOutputEncoding = enc;
        }
    }
    
    NSString *hostName = [self preferenceForKey:@"atlantis.world.host"];
    NSNumber *hostPort = [self preferenceForKey:@"atlantis.world.port"];
    
    UInt16 port = [hostPort intValue];

    // TODO: Localization
    [self handleStatusOutput:[NSString stringWithFormat:@"Connecting to %@ %d...\n", hostName, port]];
    if (_rdInputStream) {
        [_rdInputStream close];
        [_rdInputStream release];
    }
    if (_rdOutputStream) {
        [_rdOutputStream close];
        [_rdOutputStream release];
    }

    NSString *newHost = hostName;

    int proxyType = [[NSUserDefaults standardUserDefaults] integerForKey:@"atlantis.network.proxyType"];
    if (proxyType) {
        if ((proxyType == 3) || (proxyType == 4)) {
            NSString *proxyServer = [[NSUserDefaults standardUserDefaults] stringForKey:@"atlantis.network.proxyHost"];
            port = [[NSUserDefaults standardUserDefaults] integerForKey:@"atlantis.network.proxyPort"];
            newHost = proxyServer;
        } 
    }
    
	[NSStream getStreamsToHostWithName:newHost port:port inputStream:&_rdInputStream outputStream:&_rdOutputStream];
    
    if (!_rdInputStream || !_rdOutputStream) {
        [self handleStatusOutput:@"Unable to reach host, cannot connect.\n"];
        return;
    }
    
    _rdOutputBuffer = [[NSMutableData data] retain];
    
    [_rdInputStream retain];
    [_rdOutputStream retain];
    [_rdInputStream setDelegate:self];
    [_rdOutputStream setDelegate:self];
    
    NSNumber *sslOn = [self preferenceForKey:@"atlantis.world.ssl"];
    if (sslOn && [sslOn boolValue] && ((proxyType != 3) && (proxyType != 4)) ) {
//        if ([RDAtlantisApplication isTiger]) {
            NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                [NSNumber numberWithBool:YES], @"kCFStreamSSLAllowsExpiredCertificates",
                [NSNumber numberWithBool:YES], @"kCFStreamSSLAllowsAnyRoot",
                [NSNumber numberWithBool:NO], @"kCFStreamSSLValidatesCertificateChain",
                @"kCFStreamSocketSecurityLevelNegotiatedSSL", @"kCFStreamSSLLevel",
                nil];
        
            CFReadStreamSetProperty((CFReadStreamRef)_rdInputStream, (CFStringRef)@"kCFStreamPropertySSLSettings", (CFTypeRef)settings);
            CFWriteStreamSetProperty((CFWriteStreamRef)_rdOutputStream, (CFStringRef)@"kCFStreamPropertySSLSettings", (CFTypeRef)settings);    
//        }
//        else {
//            [_rdInputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
//            [_rdOutputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
//        }
    }
    
    if ((proxyType == 1) || (proxyType == 2)) {
        NSString *proxyServer = [[NSUserDefaults standardUserDefaults] stringForKey:@"atlantis.network.proxyHost"];
        int proxyPort = [[NSUserDefaults standardUserDefaults] integerForKey:@"atlantis.network.proxyPort"];
        NSString *proxyUser = [[NSUserDefaults standardUserDefaults] stringForKey:@"atlantis.network.proxyUser"];
        NSString *proxyPass = [[NSUserDefaults standardUserDefaults] stringForKey:@"atlantis.network.proxyPass"];
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
        if (proxyServer && proxyPort) {
            switch (proxyType) {
                case 1:
                    // SOCKS4
                case 2:
                    // SOCKS5
                    [settings setObject:((proxyType == 1) ? NSStreamSOCKSProxyVersion4 : NSStreamSOCKSProxyVersion5) forKey:NSStreamSOCKSProxyVersionKey];
                    [settings setObject:proxyServer forKey:NSStreamSOCKSProxyHostKey];
                    [settings setObject:[NSNumber numberWithInt:proxyPort] forKey:NSStreamSOCKSProxyPortKey];
                    if (proxyUser && proxyPass && [proxyUser length] && [proxyPass length]) {
                        [settings setObject:proxyUser forKey:NSStreamSOCKSProxyUserKey];
                        [settings setObject:proxyPass forKey:NSStreamSOCKSProxyPasswordKey];
                    }
                    [_rdInputStream setProperty:settings forKey:NSStreamSOCKSProxyConfigurationKey];
                    [_rdOutputStream setProperty:settings forKey:NSStreamSOCKSProxyConfigurationKey];
                    break;
                    
            }
        }
        [settings release];
    }
    
    [_rdInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    _rdNetSync = YES;
    _rdDataReceived = NO;
    
    [_rdInputStream open];
    [_rdOutputStream open];    
}

- (void) connectAndFocus
{
    if (![self isConnected])
        [self connect];

    if (_rdMainView)
        [[RDNestedViewManager manager] selectView:_rdMainView];
}

- (BOOL) isConnected
{
    BOOL connected = NO;
    
    if (_rdInputStream) {
        NSStreamStatus status = [_rdInputStream streamStatus];
        if ((status == NSStreamStatusOpen) || (status == NSStreamStatusReading))
            connected = YES;
    }
    
    return connected;
}

- (BOOL) isConnecting
{
    BOOL connected = [self isConnected];
    
    if (_rdInputStream && !connected) {
        if ([_rdInputStream streamStatus] == NSStreamStatusOpening)
            connected = YES;
    }
    
    return connected;
}


- (void) handleDisconnect:(NSString *) reason
{
    _rdNetSync = NO;
    [_rdInputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_rdInputStream close];
    [_rdOutputStream close];
    [_rdInputStream release];
    [_rdOutputStream release];
    _rdInputStream = nil;
    _rdOutputStream = nil;
    [_rdOutputBuffer release];
    _rdOutputBuffer = nil;
    [_rdMcpSessionKey release];
    _rdMcpSessionKey = nil;
    _rdDataReceived = NO;
    [self compress:NO];
    // TODO: Localization
    [self handleStatusOutput:@"Disconnected.\n"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RDAtlantisConnectionDidDisconnectNotification" object:self];

    AtlantisState *state = [[AtlantisState alloc] initWithString:nil inWorld:self forSpawn:_rdMainView];
    [state setExtraData:@"statechange" forKey:@"event.cause"];
    [state setExtraData:@"disconnected" forKey:@"event.statechange"];
    [state setExtraData:reason ? reason : @"Disconnected." forKey:@"event.detail"];
    [self fireEventsForState:state];
    [state release];
}

- (void) disconnect
{
    if ([self isConnecting]) {
        [self handleDisconnect:@"Disconnected."];
    }
}

- (void) disconnectWithMessage:(NSString *) string
{
    if ([self isConnecting]) {
        [self handleStatusOutput:[NSString stringWithFormat:@"%@\n",string]];
        [self handleDisconnect:string];
    }
}

- (void) sendLogin
{
    NSString *character = [self preferenceForKey:@"atlantis.world.character"];
    NSString *password = [self preferenceForKey:@"atlantis.world.password"];

    if (!character && _rdCharacter)
        character = _rdCharacter;
    
    if (character && password) {
        NSNumber *serverType = [self preferenceForKey:@"atlantis.world.codebase"];
        if (!serverType || ([serverType intValue] == AtlantisServerTinyMU)) {
            NSString *connectString;
            
            NSRange testRange = [character rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (testRange.length) 
                connectString = [NSString stringWithFormat:@"connect \"%@\" %@", character, password];
            else
                connectString = [NSString stringWithFormat:@"connect %@ %@", character, password];            
            
            [self sendString:connectString];            
        }
        else if ([serverType intValue] == AtlantisServerMud) {
            [self performSelector:@selector(sendString:) withObject:character afterDelay:0.1];
            [self performSelector:@selector(sendString:) withObject:password afterDelay:0.2];
        }
        else if ([serverType intValue] == AtlantisServerIRE) {
            [self performSelector:@selector(sendString:) withObject:@"1" afterDelay:1];
            [self performSelector:@selector(sendString:) withObject:character afterDelay:1.5];
            [self performSelector:@selector(sendString:) withObject:password afterDelay:1.8];
        }
    }
    
    AtlantisState *state = [[AtlantisState alloc] initWithString:nil inWorld:self forSpawn:_rdMainView];
    [state setExtraData:@"statechange" forKey:@"event.cause"];
    [state setExtraData:@"charlogin" forKey:@"event.statechange"];    
    [self performSelector:@selector(fireEventsForState:) withObject:state afterDelay:0.5];
    [state performSelector:@selector(autorelease) withObject:nil afterDelay:1.0];    
}

#pragma mark Network Delegates

-(void) handleData:(NSData *)data
{
    if ([data length]) {
        [_rdLastNetActivity release];
        _rdLastNetActivity = [[NSDate date] retain];

        NSMutableData *mutableData  = [data mutableCopy];

        NSEnumerator *filterEnum = [_rdInputFilters objectEnumerator];
        RDAtlantisFilter *filter;

        while (filter = [filterEnum nextObject]) {
            [filter filterInput:mutableData];
        }       

        if (_rdHoldoverBlock) {
            NSData *tempData = mutableData;
            mutableData = [_rdHoldoverBlock mutableCopy];
            [mutableData appendData:tempData];
            [_rdHoldoverBlock release];
            _rdHoldoverBlock = nil;
            [tempData release];
        }

        if ([mutableData length]) {
            // Split up into multiple newlines for processing
            NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
            NSMutableString *tempString = [[NSMutableString alloc] initWithData:mutableData encoding:_rdInputEncoding];
            
            if (!tempString) {
                tempString = [[NSMutableString alloc] initWithData:mutableData encoding:NSISOLatin1StringEncoding];
                if (!tempString) {
                    _rdHoldoverBlock = [mutableData retain];
                    [mutableData release];
                    return;
                }
            }
            
            [tempString replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:NSMakeRange(0,[tempString length])];
                        
            unsigned curPos = 0;
            unsigned length = [tempString length];
            BOOL done = NO;
            
            while (!done && (curPos < length)) {
                NSString *temporaryString = nil;
            
                NSRange nextLinebreak = [tempString rangeOfCharacterFromSet:cset options:NSLiteralSearch range:NSMakeRange(curPos,length - curPos)];
                if (nextLinebreak.location != NSNotFound) {
                    NSRange getme = NSMakeRange(curPos,nextLinebreak.location - curPos);
                    temporaryString = [tempString substringWithRange:getme];
                    curPos = nextLinebreak.location + nextLinebreak.length;
                }
                else {
                    NSRange getme = NSMakeRange(curPos,length - curPos);                
                    _rdHoldoverBlock = [[[tempString substringWithRange:getme] dataUsingEncoding:_rdInputEncoding] retain];
                    curPos = nextLinebreak.location + nextLinebreak.length;
                    done = YES;
                }
            
                if (temporaryString) {
                    NSMutableAttributedString *realString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",temporaryString]];
                    
                    filterEnum = [_rdInputFilters objectEnumerator];
                    while (filter = [filterEnum nextObject]) {
                        [filter filterInput:realString];
                    }
                    if ([realString length]) {
                        [self handleOutput:realString];
                    }
                    [realString release];
                }
            }
            
            [tempString release];
            
            if (_rdServerCodebase == AtlantisServerMud) {
                if (_rdHoldoverBlock) {
                    NSString *tempString = [[[NSString alloc] initWithData:_rdHoldoverBlock encoding:_rdInputEncoding] autorelease];
                    NSMutableAttributedString *realString = [[NSMutableAttributedString alloc] initWithString:tempString];
                    
                    filterEnum = [_rdInputFilters objectEnumerator];
                    while (filter = [filterEnum nextObject]) {
                        [filter filterInput:realString];
                    }
                    [self handleOutput:realString];
                    [_rdHoldoverBlock release];
                    _rdHoldoverBlock = nil;
                    [realString release];
                }
            }
        }
        
        [mutableData release];
    }
}


- (void) connectionEstablished
{
    [_rdLastNetActivity release];
    _rdLastNetActivity = [[NSDate date] retain];
    [_rdConnectedOn release];
    _rdConnectedOn = [[NSDate date] retain];
    
    BOOL isSSL = NO;
    
    if ([[_rdInputStream propertyForKey:NSStreamSocketSecurityLevelKey] isEqualTo:NSStreamSocketSecurityLevelNegotiatedSSL])
        isSSL = YES;
    
    if (!isSSL)
        [self handleStatusOutput:@"Connected.\n"];
    else
        [self handleStatusOutput:@"Connected with SSL encryption.\n"];
    _rdDataReceived = NO;
    
    [_rdPreferences setPreference:[NSDate date] forKey:@"atlantis.stats.lastConnect" withCharacter:_rdCharacter];
    _rdNeedsReconnect = NO;
    
    NSNumber *conTotal = [self preferenceForKey:@"atlantis.stats.totalConnections"];
    int newTotal = 0;
    if (conTotal) {
        newTotal = [conTotal intValue];
    }
    newTotal++;
    [_rdPreferences setPreference:[NSNumber numberWithInt:newTotal] forKey:@"atlantis.stats.totalConnections" withCharacter:_rdCharacter];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RDAtlantisConnectionDidConnectNotification" object:self];
    
    BOOL focused = NO;
    
    id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];
    if (curView && (curView == _rdMainView)) {
        focused = YES;
    }
    
    AtlantisState *state = [[AtlantisState alloc] initWithString:nil inWorld:self forSpawn:_rdMainView];
    [state setExtraData:@"statechange" forKey:@"event.cause"];
    [state setExtraData:@"connected" forKey:@"event.statechange"];
    
    if (isSSL) {
        [state setExtraData:@"Connection established and secured with SSL encryption." forKey:@"event.details"];                        
    }
    else {
        [state setExtraData:@"Connection established successfully." forKey:@"event.details"];
    }
    
    [self fireEventsForState:state];
    [state release];
    
}


- (void) handleBytesOnStream:(NSInputStream *)stream
{
    uint8_t buffer[5000];
    int buflen;
    
    memset(&buffer[0],0,5000);
    buflen = [(NSInputStream *)stream read:&buffer[0] maxLength:4999];
    
    if (buflen > 0) {
        NSMutableData *tempData = [[NSData dataWithBytes:&buffer[0] length:buflen] mutableCopy];
        
        if (!_rdHttpProxyConnected) {
            NSString *tempString = [[NSString alloc] initWithData:tempData encoding:NSASCIIStringEncoding];
            NSArray *tempArray = [tempString componentsSeparatedByString:@"\n"];
            NSEnumerator *tempEnum = [tempArray objectEnumerator];
            NSString *walk;
            while ((walk = [tempEnum nextObject]) && !_rdHttpProxyConnected) {
                if ([[walk substringToIndex:7] isEqualToString:@"HTTP/1."]) {
                    if ([[[walk substringFromIndex:9] substringToIndex:3] intValue] == 200) {
                        _rdHttpProxyConnected = YES;
                        [self connectionEstablished];
                    }
                }
                [tempData replaceBytesInRange:NSMakeRange(0,[walk length]) withBytes:0 length:0];
                if (*(char *)[tempData bytes] == '\n')
                    [tempData replaceBytesInRange:NSMakeRange(0,1) withBytes:0 length:0];
            }
            if (!_rdHttpProxyConnected) {
                [self disconnectWithMessage:@"Unable to connect through proxy."];
                [tempData release];
                return;
            }
        }
        
        
        [self handleData:tempData];
        if (!_rdDataReceived) {
            _rdDataReceived = YES;
            // Wait a few, to allow telnet negotiation to finish before we send any login.
            // Useful for things which require telnet negotiation before login in order to
            // display useful login information for staff or guests.
            [self sendLogin];
        }
        [tempData release];
    } 
    else if (buflen < 0) {
        [self disconnectWithMessage:@"Connection lost."];
    }               
}

- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable:
        {
            if ([stream isKindOfClass:[NSInputStream class]]) {
                [self handleBytesOnStream:(NSInputStream *)stream];
            } 
        }
        break;
            
        case NSStreamEventEndEncountered:
        {
            NSString *status = @"Connection closed by remote host.";
            [self handleStatusOutput:[NSString stringWithFormat:@"%@\n", status]];
            [self handleDisconnect:status];
        }
        break;
            
        case NSStreamEventErrorOccurred:
        {
            NSError *error = [stream streamError];
            if (([error code] == -9812) && ([[error domain] isEqualToString:@"NSUnknownErrorDomain"])) {
                [self handleStatusOutput:@"Unable to connect, certificate is not verifiable.\n"];
                [self handleStatusOutput:@"(Mac OS X 10.3.x does not support self-signed certificates.  Add the server's self-signing root certificate to your local certificate chain, and you should be able to connect.  Otherwise, wait until I can figure out a workaround.)\n"];
                [self handleDisconnect:@"SSL Validation Failure"];
            }
            else {
                NSString *status = [NSString stringWithFormat:@"Network error: %@", [error localizedDescription]];
                [self handleStatusOutput:[NSString stringWithFormat:@"%@\n", status]];
                [self handleDisconnect:status];
                _rdNeedsReconnect = YES;
            }
        }
        break;
            
        case NSStreamEventOpenCompleted:
        {
            if ([stream isKindOfClass:[NSInputStream class]]) {
            
                int proxyType = [[NSUserDefaults standardUserDefaults] integerForKey:@"atlantis.network.proxyType"];
                if ((proxyType == 3) || (proxyType == 4)) {
                    NSString *hostName = [self preferenceForKey:@"atlantis.world.host"];
                    NSNumber *hostPort = [self preferenceForKey:@"atlantis.world.port"];
                    [self sendString:[NSString stringWithFormat:@"CONNECT %@:%d HTTP/1.1\n\n", hostName, [hostPort intValue]]];
                    [self handleStatusOutput:@"Connection established to HTTP proxy server, connecting...\n"];
                    _rdHttpProxyConnected = NO;
                }
                else {
                    _rdHttpProxyConnected = YES;
                    [self connectionEstablished];
                }
                
            }
        }
        break;
            
        case NSStreamEventNone:
        {
            NSLog(@"WTF?");
        }
        break;
        
        case NSStreamEventHasSpaceAvailable:
        {
            // We don't care about these.
        }
        break;
    }
}


@end
