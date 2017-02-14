//
//  RDAtlantisWorldPreferences.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/8/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDAtlantisWorldPreferences.h"
#import "RDAtlantisMainController.h"

NSString *generateUUID()
{
    CFUUIDRef   uuid;
    CFStringRef string;
 
    uuid = CFUUIDCreate( NULL );
    string = CFUUIDCreateString( NULL, uuid );

    return (NSString *)string;
}

@interface RDAtlantisWorldPreferences (Private)
- (void) recreateMutables:(NSNotification *)notification;
@end

@implementation RDAtlantisWorldPreferences

#pragma mark Initialization

- (id) init
{
    self = [super init];
    if (self) {
        _rdWorldPreferences = [[NSMutableDictionary alloc] init];
        _rdCharacterPreferences = [[NSMutableDictionary alloc] init];
        _rdBulkUpdate = NO;
        _rdSyncUpdate = NO;
        _rdSyncChanged = NO;
        _rdBulkChanged = NO;
        _rdExpiring = NO;
        _rdDirty = NO;
        _rdCharactersUpdated = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recreateMutables:) name:@"RDAtlantisWorldDidLoadNotification" object:self];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_rdCharactersUpdated release];
    [_rdWorldPreferences release];
    [_rdCharacterPreferences release];
    [super dealloc];
}

#pragma mark Serialization

- (id) initWithCoder:(NSCoder *) coder
{
    self = [self init];
    if (self) {
        int revision = [coder decodeIntForKey:@"RDAtlantisWorldFormat"];
        if (revision == 1) {
            
            NSDictionary *keyDict = [coder decodeObjectForKey:@"RDAtlantisWorldPrefs"];
            NSDictionary *charDict = [coder decodeObjectForKey:@"RDAtlantisWorldChars"];
            
            [_rdWorldPreferences release];
            [_rdCharacterPreferences release];
            
            _rdWorldPreferences = [keyDict mutableCopy];
            _rdCharacterPreferences = [charDict mutableCopy];
                        
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RDAtlantisWorldDidLoadNotification" object:self];
    }    
    return self;
}

- (NSString *) uuidForCharacter:(NSString *) character;
{
    NSString *uuid = [self preferenceForKey:@"atlantis.world.uuid" withCharacter:character fallback:NO];
    
    if (!uuid) {
        uuid = generateUUID();
        [self setPreference:uuid forKey:@"atlantis.world.uuid" withCharacter:character];
    }

    return uuid;
}

- (NSString *) uuid
{
    return [self uuidForCharacter:nil];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<RDAtlantisWorldPreferences: %@ (%@)>",
        [self preferenceForKey:@"atlantis.world.name" withCharacter:nil], [self uuid]];
}

- (void) expire
{
    _rdExpiring = YES;
}

- (BOOL) expiring
{
    return _rdExpiring;
}

- (void) recreateMutables:(NSNotification *) notification
{
    NSDictionary *tempDict;
    NSArray *tempArray;
    
    _rdBulkUpdate = YES;
    
    NSString *uuid = [self uuid];
    if (!uuid) {
        uuid = generateUUID();
        [self setPreference:uuid forKey:@"atlantis.world.uuid" withCharacter:nil];
    }
    
    tempArray = [self preferenceForKey:@"atlantis.highlights" withCharacter:nil fallback:NO];
    if (tempArray) {
        if (![tempArray isKindOfClass:[NSMutableArray class]]) {
            [self setPreference:[[tempArray mutableCopy] autorelease] forKey:@"atlantis.highlights" withCharacter:nil];
        }
    }
    
    tempDict = [self preferenceForKey:@"atlantis.spawns" withCharacter:nil fallback:NO];
    if (tempDict) {
        if (![tempDict isKindOfClass:[NSMutableDictionary class]]) {
            [self setPreference:[[tempDict mutableCopy] autorelease] forKey:@"atlantis.spawns" withCharacter:nil];
        }
    }
    
    NSEnumerator *charEnum = [[self characters] objectEnumerator];
    NSString *charWalk;
    
    while (charWalk = [charEnum nextObject]) {
        tempArray = [self preferenceForKey:@"atlantis.highlights" withCharacter:charWalk fallback:NO];
        if (tempArray) {
            if (![tempArray isKindOfClass:[NSMutableArray class]]) {
                [self setPreference:[[tempArray mutableCopy] autorelease] forKey:@"atlantis.highlights" withCharacter:charWalk];
            }
        }
        
        tempDict = [self preferenceForKey:@"atlantis.spawns" withCharacter:charWalk fallback:NO];
        if (tempDict) {
            if (![tempDict isKindOfClass:[NSMutableDictionary class]]) {
                [self setPreference:[[tempDict mutableCopy] autorelease] forKey:@"atlantis.spawns" withCharacter:charWalk];
            }
        }
    }
    
    _rdBulkUpdate = NO;
}


- (void) encodeWithCoder:(NSCoder *) coder
{
    [coder encodeInt:1 forKey:@"RDAtlantisWorldFormat"];
    [coder encodeObject:_rdWorldPreferences forKey:@"RDAtlantisWorldPrefs"];
    [coder encodeObject:_rdCharacterPreferences forKey:@"RDAtlantisWorldChars"];
    _rdDirty = NO;
}

- (BOOL) dirty
{
    return _rdDirty;
}

- (void) setDirty:(BOOL)dirty
{
    _rdDirty = dirty;
}

#pragma mark Notification Stuff

- (void) markCharacterDirty:(NSString *) character
{
    NSString *tempChar = character;
    if (!tempChar)
        tempChar = @"";
        
    if (tempChar && ![_rdCharactersUpdated containsObject:tempChar])
        [_rdCharactersUpdated addObject:tempChar];
        
    _rdDirty = YES;
}

- (void) postUpdates
{
    if (!_rdBulkUpdate && !_rdSyncUpdate) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RDAtlantisWorldDidUpdateNotification" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithArray:_rdCharactersUpdated],@"RDCharacters",nil]];
        [_rdCharactersUpdated removeAllObjects];
    }
    else {
        if (_rdBulkUpdate)
            _rdBulkChanged = YES;
        if (_rdSyncUpdate)
            _rdSyncChanged = YES;
    }
}

#pragma mark Character Utilities

- (void) addCharacter:(NSString *) character
{
    NSMutableDictionary *charPrefs = [_rdCharacterPreferences objectForKey:character];
    if (!charPrefs) {
        charPrefs = [[NSMutableDictionary alloc] init];
        [_rdCharacterPreferences setObject:charPrefs forKey:character];
        [charPrefs release];
        [self setDirty:YES];
    }
}

- (void) removeCharacter:(NSString *) character
{
    [_rdCharacterPreferences removeObjectForKey:character];
    [self setDirty:YES];
}

- (void) renameCharacter:(NSString *) character to:(NSString *) newName
{
    if ([character isEqualToString:newName])
        return;

    NSMutableDictionary *charPrefs = [_rdCharacterPreferences objectForKey:character];
    [_rdCharacterPreferences setObject:charPrefs forKey:newName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RDAtlantisCharacterRenamedNotification" object:self 
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:character,@"RDAtlantisCharacterOld",newName,@"RDAtlantisCharacterNew",nil]];
    
    [_rdCharacterPreferences removeObjectForKey:character];
    [self setDirty:YES];
}

- (NSArray *) characters
{
    NSArray *tempArray;
    
    tempArray = [[_rdCharacterPreferences allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return tempArray;
}

- (BOOL) hasCharacter:(NSString *) character;
{
    if ([_rdCharacterPreferences objectForKey:character] == nil)
        return NO;
    else
        return YES;
}

- (NSString *) basePathForCharacter:(NSString *) character
{
    NSString *path = [self preferenceForKey:@"atlantis.world.displayName" withCharacter:character fallback:NO];
    if (path)
        return path;
        
    if (!character)
        path = [self preferenceForKey:@"atlantis.world.name" withCharacter:character fallback:NO];
    else {
        NSString *worldName = [self preferenceForKey:@"atlantis.world.displayName" withCharacter:nil fallback:NO];
        if (!worldName)
            worldName = [self preferenceForKey:@"atlantis.world.name" withCharacter:character fallback:YES];
    
        path = [NSString stringWithFormat:@"%@@%@", character, worldName];
    }
    
    if (!path)
        return [self uuid];  // Last resort, just to have a non-nil
    
    return path;
}

#pragma mark Preference Utilities

- (id) preferenceForKey:(NSString *) keyName withCharacter:(NSString *) character
{
    return [self preferenceForKey:keyName withCharacter:character fallback:YES];
}

- (id) preferenceForKey:(NSString *) keyName withCharacter:(NSString *) character fallback:(BOOL) fallback
{
    NSDictionary *charPrefs = [_rdCharacterPreferences objectForKey:character];
    id result = nil;
    
    if (charPrefs) {
        result = [charPrefs objectForKey:keyName];
    }
    
    if (!result && (fallback || !character)) {
        result = [_rdWorldPreferences objectForKey:keyName];
        
        if (!result && ![keyName isEqualToString:@"atlantis.events"] && ![keyName isEqualToString:@"atlantis.highlights"] &&![keyName isEqualToString:@"atlantis.aliases"]) {
            RDAtlantisWorldPreferences *global = [[RDAtlantisMainController controller] globalWorld];
            if (fallback && (global != self)) {
                result = [global preferenceForKey:keyName withCharacter:nil fallback:NO];
            }
        }
    }
    
    return result;
}

- (void) removePreferenceForKey:(NSString *) keyName withCharacter:(NSString *) character
{
    NSMutableDictionary *dict = _rdWorldPreferences;
    
    if (character) {
        dict = (NSMutableDictionary *)[_rdCharacterPreferences objectForKey:character];
    }
    
    if (dict && [dict objectForKey:keyName]) {
        [dict removeObjectForKey:keyName];
        [self markCharacterDirty:character];
        [self postUpdates];
    }
}

- (void) setPreference:(id) preference forKey:(NSString *) keyName withCharacter:(NSString *) character
{
    NSMutableDictionary *dict = _rdWorldPreferences;
    
    [self setDirty:YES];
    
    if (character) {
        dict = (NSMutableDictionary *)[_rdCharacterPreferences objectForKey:character];
    }
    
    if (dict && preference) {
        id temp;
        
        temp = [dict objectForKey:keyName];
        if (!temp || ![preference isKindOfClass:[NSString class]] || ![preference isEqualToString:temp]) {
            [dict setObject:preference forKey:keyName];
            [self markCharacterDirty:character];
            [self postUpdates];
        }
    }
}

- (void) beginSyncUpdate
{
    _rdSyncUpdate = YES;
    _rdSyncChanged = NO;
}

- (void) beginBulk
{
    _rdBulkUpdate = YES;
    _rdBulkChanged = NO;
}

- (void) endBulk
{
    _rdBulkUpdate = NO;
    if (_rdBulkChanged) {
        [self postUpdates];
    }
}

- (void) endSyncUpdate
{
    _rdSyncUpdate = NO;
    if (_rdSyncChanged) {
        [self postUpdates];
    }
    _rdSyncChanged = NO;
}

@end
