//
//  ScriptBridge.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/13/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AtlantisState;

@interface ScriptBridge : NSObject {

    NSSpeechSynthesizer         *_rdSpeaker;
    NSMovie                     *_rdSound;

}

// LEGACY: Spawn-based
- (void) sendText:(NSString *) text toWorld:(NSString *)world;
- (void) sendStatus:(NSString *) text toSpawn:(NSString *)spawnPath inWorld:(NSString *)worldName;

// LEGACY: Input-based
- (NSString *) getTextFromInput;
- (void) sendTextToInput:(NSString *) text;

// LEGACY: Variable
- (void) setVariable:(NSString *) value forKey:(NSString *)tempKey inWorld:(NSString *)worldName;

// LEGACY: Preference
- (id) getPreference:(NSString *) value inWorld:(NSString *)worldName;
- (void) setPreference:(id) preference forKey:(NSString *)key inWorld:(NSString *)worldName;

- (void) growlText:(NSString *)text withTitle:(NSString *)title;
- (void) speakText:(NSString *)text;
- (void) systemBeep;
- (void) playSoundFile:(NSString *)filename;

// Behind-the-scenes for the World classes
- (NSString *) worldUuidForName:(NSString *)name;
- (id) getPreference:(NSString *) key inWorldUUID:(NSString *)uuid withCharacter:(NSString *)character;
- (void) setPreference:(id) value forKey:(NSString *)key inWorldUUID:(NSString *)uuid withCharacter:(NSString *)character;
- (void) removePreference:(NSString *)key inWorldUUID:(NSString *)uuid withCharacter:(NSString *)character;
- (NSArray *) charactersForWorld:(NSString *)uuid;
- (NSString *) isWorldConnected:(NSString *) uuid forCharacter:(NSString *)character;
- (void) connectWorld:(NSString *)uuid forCharacter:(NSString *)character;
- (void) disconnectWorld:(NSString *)uuid forCharacter:(NSString *)character;

// Behind-the-scenes for the Spawn classes
- (void) focusSpawn:(NSString *)path;
- (NSString *) selectedStringInSpawn:(NSString *)path;
- (NSString *) getTextFromInputForSpawn:(NSString *)path;
- (void) setStatusBarText:(NSString *)text forSpawn:(NSString *)path inWorld:(NSString *)worldName;
- (void) setTextToInput:(NSString *)text forSpawn:(NSString *)path;
- (void) appendHTML:(NSString *)text toSpawn:(NSString *)path inWorld:(NSString *)worldName;
- (void) appendAML:(NSString *)text toSpawn:(NSString *)path inWorld:(NSString *)worldName;
- (void) replaceEventLine:(NSString *)text inSession:(NSString *)sessionUID;
- (void) setLineSpawn:(NSString *)spawn copy:(NSString *)copyMe inSession:(NSString *)sessionUID;
- (void) setPrefix:(NSString *)prefix forSpawn:(NSString *)spawn inSession:(NSString *)sessionUID;

// Behind the scenes automation
- (void) uploadTextfile:(NSString *) filename toWorld:(NSString *) world;
- (void) uploadCodefile:(NSString *) filename toWorld:(NSString *) world;
- (void) sendAsInput:(NSString *)text onWorld:(NSString *)world;
- (void) registerFunction:(NSString *)function forLinePattern:(NSString *)pattern withLanguage:(NSString *)language inWorld:(NSString *)world;
- (void) registerFunction:(NSString *)function forEventType:(NSString *)eventType withLanguage:(NSString *)language inWorld:(NSString *)world;
- (void) registerAlias:(NSString *)function withName:(NSString *)alias withLanguage:(NSString *)language inWorld:(NSString *)world;
- (void) registerHotkeyFunction:(NSString *)function withKeyCode:(NSString *)keycode modifiers:(NSString *)modifiers globally:(NSString *)globally withLanguage:(NSString *)language;
- (void) registerTimer:(NSString *)function withLanguage:(NSString *)language inWorld:(NSString *)world withInterval:(NSString *)seconds repeats:(NSString *)repeats;

@end
