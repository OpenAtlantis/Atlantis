//
//  RDLogType.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/14/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDAtlantisWorldInstance.h"

@class AtlantisState;

@interface RDLogType : NSObject {

    NSString                    *_rdFilename;
    NSString                    *_rdSpawnPath;
    RDAtlantisWorldInstance     *_rdWorld;
    NSDictionary                *_rdOptions;
    NSFileHandle                *_rdLogfile;
    
    BOOL                         _rdTimestamps;

}

+ (NSString *) logtypeName;
+ (BOOL) canAppendToLog;
+ (BOOL) supportsOptions;

- (NSDictionary *) configureOptions:(NSDictionary *)oldOptions;

+ (NSString *) shortTypeName;
- (NSString *) shortTypeName;

- (id) initWithFilename:(NSString *)filename forSpawn:(NSString *)spawnPath inWorld:(RDAtlantisWorldInstance *)world;
- (id) initWithFilename:(NSString *)filename forSpawn:(NSString *)spawnPath inWorld:(RDAtlantisWorldInstance *)world withOptions:(NSDictionary *)dictionary;

- (BOOL) openFile;
- (BOOL) closeFile;
- (BOOL) isOpen;

- (NSString *) filename;
- (NSString *) spawnPath;
- (NSFileHandle *) fileHandle;
- (RDAtlantisWorldInstance *) world;
- (NSDictionary *) options;

- (NSDictionary *) defaultOptions;

- (BOOL) writeTimestamps;
- (void) setWriteTimestamps:(BOOL) timestamps;

- (void) writeStringToFile:(NSString *)string;

- (BOOL) shouldWriteForState:(AtlantisState *)state;
- (void) writeString:(NSAttributedString *)string withState:(AtlantisState *)state;

@end
