//
//  AtlantisState.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RDAtlantisWorldInstance;
@class RDAtlantisSpawn;

@interface AtlantisState : NSObject {

    NSMutableAttributedString           *_rdEventLine;
    
    RDAtlantisWorldInstance             *_rdEventWorld;
    RDAtlantisSpawn                     *_rdEventSpawn;
    NSString                            *_rdEventSpawnPath;
    BOOL                                 _rdEventSpawnIsActive;

    NSMutableDictionary                 *_rdEventExtraData;
    NSMutableDictionary                 *_rdScriptSafeData;
}

+ (AtlantisState *) genericStateForWorld:(RDAtlantisWorldInstance *) world;

- (id) initWithString:(NSMutableAttributedString *)string inWorld:(RDAtlantisWorldInstance *)world forSpawn:(RDAtlantisSpawn *) spawn;

-(RDAtlantisWorldInstance *) world;
-(RDAtlantisSpawn *) spawn;
-(NSString *) spawnPath;
-(BOOL) spawnIsActive;

- (NSMutableAttributedString *) stringData;
- (void) setStringData:(NSAttributedString *)newString;

-(id) extraDataForKey:(NSString *) key;
-(void) setExtraData:(id) extraData forKey:(NSString *) key;
-(NSDictionary *) data;
-(void) addExtraDataFrom:(NSDictionary *)dict;
-(NSDictionary *) scriptSafeData;

- (void) resetForSpawn:(RDAtlantisSpawn *)spawn;
- (void) resetForString:(NSAttributedString *)string;

// Convenience options
- (BOOL) textToWorld:(NSString *) text;
- (BOOL) textToCurrentDisplay:(NSAttributedString *) text;
- (BOOL) textToInput:(NSString *) text;
- (NSString *) textFromInput;
- (NSString *) textFromHighlight;


@end
