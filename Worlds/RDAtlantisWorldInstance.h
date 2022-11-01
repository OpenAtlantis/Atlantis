//
//  RDAtlantisWorldInstance.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/8/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDAtlantisWorldPreferences.h"
#import "RDSpawnConfigRecord.h"
#import "EventCollection.h"

typedef enum {
    AtlantisServerTinyMU,
    AtlantisServerMud,
    AtlantisServerIRE
} AtlantisWorldType;


@class RDAtlantisSpawn;
@class RDLogType;
@class RDStringPattern;
@class UploadEngine;
@class MCPMessage;
@class WorldNotesView;
@class BaseAction;

@interface RDAtlantisWorldInstance : NSObject <NSStreamDelegate> {

    NSString                    *_rdBaseViewPath;
    NSString                    *_rdCharacter;
    RDAtlantisWorldPreferences  *_rdPreferences;    
  
    NSMutableDictionary         *_rdSpawns;
    
    WorldNotesView              *_rdWorldNotes;

    NSInputStream               *_rdInputStream;
    NSOutputStream              *_rdOutputStream;
    NSMutableData               *_rdOutputBuffer;
    NSTimer                     *_rdOutputTimer;
    BOOL                         _rdDataReceived;
    
    NSData                      *_rdHoldoverBlock;
    BOOL                         _rdLastHeldover;
    
    NSStringEncoding             _rdInputEncoding;
    NSStringEncoding             _rdOutputEncoding;

    // Engines
    NSArray                     *_rdInputFilters;
    NSArray                     *_rdEvents;
    NSArray                     *_rdAliases;
    NSArray                     *_rdHighlights;
    NSMutableArray              *_rdLogfiles;
    NSMutableArray              *_rdUploaders;
    
    NSMutableArray              *_rdCommandHistory;
    int                          _rdHistoryPointer;
    NSString                    *_rdCommandHoldover;
    
    NSMutableDictionary         *_rdBaseStateInfo;
    NSMutableDictionary         *_rdTempVariables;
    
    NSDate                      *_rdLastUserActivity;
    NSDate                      *_rdLastNetActivity;
    NSDate                      *_rdConnectedOn;

    BOOL                         _rdShuttingDown;
    BOOL                         _rdNeedsReconnect;
    BOOL                         _rdIsCompressing;
    
    BOOL                         _rdNetSync;
    BOOL                         _rdHttpProxyConnected;
    
    BOOL                         _rdTempWorld;
    BOOL                         _rdMudPrompted;
    
    NSMutableArray              *_rdMcpPackets;
    NSMutableDictionary         *_rdMcpTags;
    NSString                    *_rdMcpSessionKey;
    BOOL                         _rdMcpNegotiated;
    BOOL                         _rdMcpDisabled;
    NSMutableDictionary         *_rdMcpPackages;
    
    // Convenience pointers into preferences
    NSDictionary                *_rdSpawnPreferences;
    NSFont                      *_rdDisplayFont;
    NSFont                      *_rdDisplayFontBolded;
    RDAtlantisSpawn             *_rdMainView;
    NSParagraphStyle            *_rdParaStyle;
    RDStringPattern             *_rdGrabPattern;
    RDStringPattern             *_rdFuguePattern;
    NSColor                     *_rdDefaultColor;
    BOOL                         _rdLocalEcho;
    NSString                    *_rdLocalEchoPrefix;
    int                          _rdServerCodebase;
    
    BOOL                         _rdAlternateLinefeed;
    
    NSMutableArray              *_rdDelayQueue;
    
    NSMutableDictionary         *_rdSpawnPrefixes;
}

- (id) initWithWorld:(RDAtlantisWorldPreferences *)world forCharacter:(NSString *) character withBasePath:(NSString *)basePath;

- (id) preferenceForKey:(NSString *) key;
- (RDAtlantisWorldPreferences *) preferences;
- (NSString *) character;
- (NSString *) uuid;
- (NSParagraphStyle *) paragraphStyle;

- (NSString *) basePath;
- (void) closeAndRemove;

- (void) handleOutput:(NSAttributedString *) string;
- (void) handleLocalInput:(NSAttributedString *) string onSpawn:(RDAtlantisSpawn *) spawn;
- (void) processInputString:(NSString *)string onSpawn:(RDAtlantisSpawn *)spawn;

- (void) sendData:(NSData *)data;
- (void) sendDataRaw:(NSData *)data;
- (void) sendString:(NSString *)string;

- (RDAtlantisSpawn *) mainSpawn;
- (RDAtlantisSpawn *) spawnForPath:(NSString *)path withPreferences:(RDSpawnConfigRecord *)prefs;
- (void) spawnWasClosed:(RDAtlantisSpawn *)spawn;
- (RDSpawnConfigRecord *) configForSpawn:(NSString *) internalPath;
- (NSEnumerator *) spawnEnumerator;
- (unsigned int) countOpenSpawns;
- (void) hideStatusBar:(BOOL)hidden forSpawnPath:(NSString *)internalPath;
- (void) setPrefix:(NSString *)prefix forSpawnPath:(NSString *)internalPath;

- (BOOL) isTemp;
- (void) setTemp:(BOOL) temp;

- (void) connect;
- (void) connectAndFocus;
- (BOOL) isConnected;
- (BOOL) isConnecting;
- (void) disconnect;
- (void) disconnectWithMessage:(NSString *) string;

- (void) setShouldReconnect:(BOOL) shouldReconnect;
- (BOOL) shouldReconnect;

- (NSDate *) connectedSince;

- (void) fireTimerEvents;
- (NSDate *) lastUserActivity;
- (NSDate *) lastNetActivity;

- (void) setStringEncoding:(NSStringEncoding) encoding;
- (NSStringEncoding) stringEncoding;

- (void) netsync;

- (NSFont *) displayFont;
- (NSParagraphStyle *) formattingParagraphStyle;

- (void) addLogfile:(RDLogType *)logfile;
- (void) removeLogfile:(RDLogType *)logfile;
- (void) closeAllLogfiles;

- (void) addUploader:(UploadEngine *)uploader;
- (void) removeUploader:(UploadEngine *)uploader;
- (void) killAllUploaders;

- (void) outputStatus:(NSString *)string toSpawn:(NSString *)spawnPath;
- (void) handleStatusOutput:(NSString *) string onSpawn:(RDAtlantisSpawn *)spawn;
- (void) handleStatusOutput:(NSString *) string;


- (NSArray *) commandHistory;
- (void) addToCommandHistory:(NSString *)string;
- (int) commandHistoryPoint;
- (void) setCommandHistoryPoint:(int) history;
- (NSString *) commandHoldover;
- (void) setCommandHoldover:(NSString *)holdover;

- (NSArray *) logfiles;

- (int) mainScreenWidth;
- (int) mainScreenHeight;

- (void) compress:(BOOL) compress;
- (BOOL) isCompressing;
- (void) addBytesToCompress:(NSData *)dataBytes;

- (BOOL) isSSL;

- (NSDictionary *) baseStateInfo;
- (void) setInfo:(NSString *)info forBaseStateKey:(NSString *)key;

- (void) addMcpPacket:(MCPMessage *)packet;
- (void) mapMcpPacket:(MCPMessage *)packet toTag:(NSString *)tag;
- (void) removeMcpPacket:(MCPMessage *)packet;
- (MCPMessage *) mcpPacketForTag:(NSString *)tag;
- (NSString *) mcpSessionKey;
- (BOOL) supportsMCP;
- (BOOL) mcpDisabled;
- (BOOL) mcpNegotiated;
- (void) setMcpNegotiated:(BOOL)negotiated;
- (void) addMcpPackage:(NSString *)package min:(float)minVersion max:(float)maxVersion;
- (BOOL) supportsMcpPackage:(NSString *)package;
- (BOOL) supportsMcpPackage:(NSString *)package version:(float)version;


- (void) notesDisplay;
- (void) notesClose;

- (void) addQueuedAction:(BaseAction *)action withDelay:(NSTimeInterval)delay;

@end
