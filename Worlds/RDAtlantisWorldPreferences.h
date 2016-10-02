//
//  RDAtlantisWorldPreferences.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/8/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RDAtlantisWorldPreferences : NSObject <NSCoding> {

    NSMutableDictionary             *_rdWorldPreferences;
    NSMutableDictionary             *_rdCharacterPreferences;

    BOOL                             _rdBulkUpdate;
    BOOL                             _rdBulkChanged;
    BOOL                             _rdExpiring;
    BOOL                             _rdDirty;

    BOOL                             _rdSyncUpdate;
    BOOL                             _rdSyncChanged;
    NSMutableArray                  *_rdCharactersUpdated;
}

- (NSString *) uuid;
- (NSString *) uuidForCharacter:(NSString *) character;
- (NSString *) basePathForCharacter:(NSString *) character;

- (void) addCharacter:(NSString *) characterName;
- (void) removeCharacter:(NSString *) characterName;
- (void) renameCharacter:(NSString *) characterName to:(NSString *) newName;
- (NSArray *) characters;
- (BOOL) hasCharacter:(NSString *)character;

- (void) beginSyncUpdate;
- (void) beginBulk;
- (void) endBulk;
- (void) endSyncUpdate;

- (void) expire;
- (BOOL) expiring;

- (BOOL) dirty;
- (void) setDirty:(BOOL)dirty;

- (id)   preferenceForKey:(NSString *) keyName withCharacter:(NSString *) character;
- (id)   preferenceForKey:(NSString *) keyName withCharacter:(NSString *) character fallback:(BOOL) fallback;
- (void) removePreferenceForKey:(NSString *) keyName withCharacter:(NSString *) character;
- (void) setPreference:(id) pref forKey:(NSString *) keyName withCharacter:(NSString *) character;

@end
