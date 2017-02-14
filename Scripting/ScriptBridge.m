//
//  ScriptBridge.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/13/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ScriptBridge.h"
#import <Lemuria/Lemuria.h>
#import "RDAtlantisMainController.h"
#import "RDAtlantisSpawn.h"
#import "RDAtlantisWorldInstance.h"
#import "RDAtlantisWorldPreferences.h"
#import "WorldCollection.h"
#import "CodeUploader.h"
#import "TextfileUploader.h"
#import "NSAttributedStringAdditions.h"
#import "AtlantisState.h"

@implementation ScriptBridge

- (id) init
{
    self = [super init];
    if (self) {
        _rdSpeaker = nil;
        _rdSound = nil;
    }
    return self;
}

- (void) dealloc
{
    if (_rdSound) {
        if (!IsMovieDone([_rdSound QTMovie])) {
            StopMovie([_rdSound QTMovie]);
        }
        [_rdSound release];
        _rdSound = nil;
    }
    
    if (_rdSpeaker) {
        [_rdSpeaker stopSpeaking];
        [_rdSpeaker release];
        _rdSpeaker = nil;
    }
    [super dealloc];
}

- (void) sendText:(NSString *) text toWorld:(NSString *)worldName
{
    RDAtlantisWorldInstance *world = [[RDAtlantisMainController controller] connectedWorld:worldName];
    if (world)
        [world sendString:text];
}

- (void) sendStatus:(NSString *) text toSpawn:(NSString*) spawnPath inWorld:(NSString *)worldName
{
    id <RDNestedViewDescriptor> view = [[RDNestedViewManager manager] viewByPath:spawnPath];

    if (!view && [worldName length]) {
        view = [[RDNestedViewManager manager] viewByPath:[NSString stringWithFormat:@"%@:%@", worldName, spawnPath]];
    }
    
    if (!view && [worldName length] && spawnPath) {
        NSMutableString *realPath = [[spawnPath mutableCopy] autorelease];
        
        NSRange tempRange = [realPath rangeOfString:[NSString stringWithFormat:@"%@:",worldName]];
        if (tempRange.length) {
            [realPath replaceCharactersInRange:tempRange withString:@""];
        }
        
        RDAtlantisWorldInstance *world = [[RDAtlantisMainController controller] connectedWorld:worldName];
        if (!world)
            return;
        
        RDSpawnConfigRecord *config = [world configForSpawn:realPath];
        
        view = [world spawnForPath:realPath withPreferences:config];
    }  
    
    if (view && [(NSObject *)view isKindOfClass:[RDAtlantisSpawn class]]) {
        RDAtlantisSpawn *spawn = (RDAtlantisSpawn *)view;
        
        [[spawn world] handleStatusOutput:[NSString stringWithFormat:@"%@\n",text] onSpawn:spawn];
    }
}

- (void) setVariable:(NSString *)value forKey:(NSString *)tempKey inWorld:(NSString *)worldName
{
    RDAtlantisWorldInstance *world = [[RDAtlantisMainController controller] connectedWorld:worldName];
    if (world || [[[tempKey substringToIndex:5] lowercaseString] isEqualToString:@"temp."]) {
        if ([[[tempKey substringToIndex:5] lowercaseString] isEqualToString:@"temp."]) {
            NSString *keyname = [tempKey substringFromIndex:5];
            [[RDAtlantisMainController controller] setStateVar:value forKey:keyname];
        }
        else if ([[[tempKey substringToIndex:10] lowercaseString] isEqualToString:@"worldtemp."]) {
            [world setInfo:value forBaseStateKey:tempKey];
        }
        else if ([[[tempKey substringToIndex:9] lowercaseString] isEqualToString:@"userconf."]) {
            NSMutableDictionary *userconf = [[[world preferences] preferenceForKey:@"atlantis.userconf" withCharacter:[world character] fallback:NO] mutableCopy];
            if (!userconf) {
                userconf = [[NSMutableDictionary alloc] init];
            }
            [userconf setObject:value forKey:[tempKey substringFromIndex:9]];
            [[world preferences] setPreference:[NSDictionary dictionaryWithDictionary:userconf] forKey:@"atlantis.userconf" withCharacter:[world character]];
            [userconf release];
        }
    }
    
}

- (id) getPreference:(NSString *) key inWorld:(NSString *)worldName
{
    RDAtlantisWorldInstance *world = [[RDAtlantisMainController controller] connectedWorld:worldName];
    if (world)
    {
        id result = [[world preferences] preferenceForKey:key withCharacter:[world character] fallback:YES];
        if (!result)
            return @"";
        else
            return result;
    }
    else {
        return @"";
    }
}

- (void) setPreference:(id)preference forKey:(NSString *) key inWorld:(NSString *)worldName
{
    RDAtlantisWorldInstance *world = [[RDAtlantisMainController controller] connectedWorld:worldName];
    if (world)
    {
        if (![[[key substringToIndex:9] lowercaseString] isEqualToString:@"atlantis."])
            [[world preferences] setPreference:preference forKey:key withCharacter:[world character]];
    }
}


- (void) setTemporaryVariable:(NSString *) value forKey:(NSString *)tempKey
{
    [[RDAtlantisMainController controller] setStateVar:value forKey:tempKey];
}

- (NSString *) getTextFromInput
{
    id <RDNestedViewDescriptor> view = [[RDNestedViewManager manager] currentFocusedView];
    if (view && [(NSObject *)view isKindOfClass:[RDAtlantisSpawn class]]) {
        return [(RDAtlantisSpawn *)view stringFromInput];
    }
    
    return @"";
}

- (void) sendTextToInput:(NSString *) text
{
    id <RDNestedViewDescriptor> view = [[RDNestedViewManager manager] currentFocusedView];
    if (view && [(NSObject *)view isKindOfClass:[RDAtlantisSpawn class]]) {
        [(RDAtlantisSpawn *)view stringIntoInput:text];
    }
}

- (void) growlText:(NSString *)text withTitle:(NSString *)title
{
    if ([GrowlApplicationBridge isGrowlRunning]) {
        [GrowlApplicationBridge
            notifyWithTitle:title 
                description:text 
           notificationName:@"User Defined" 
                   iconData:nil
                   priority:0 
                   isSticky:NO 
               clickContext:nil];    
    }
}

- (NSString *) worldUuidForName:(NSString *)name
{
    RDAtlantisWorldPreferences *preferences = [[[RDAtlantisMainController controller] worlds] worldForName:name];
    if (preferences) {
        return [preferences uuid];
    }
    else
        return @"";
}

- (id) getPreference:(NSString *) key inWorldUUID:(NSString *)uuid withCharacter:(NSString *)character
{
    RDAtlantisWorldPreferences *preferences = [[[RDAtlantisMainController controller] worlds] worldForUUID:uuid];
    if (preferences) {
        NSString *tempChar = character;
        if ([character isEqualToString:@""])
            tempChar = nil;
        return [preferences preferenceForKey:key withCharacter:tempChar fallback:YES];
    }
    else
        return @"";    
}

- (void) setPreference:(id) value forKey:(NSString *)key inWorldUUID:(NSString *)uuid withCharacter:(NSString *)character
{
    RDAtlantisWorldPreferences *preferences = [[[RDAtlantisMainController controller] worlds] worldForUUID:uuid];
    if (preferences) {
        NSString *tempChar = character;
        if ([character isEqualToString:@""])
            tempChar = nil;
        [preferences setPreference:value forKey:key withCharacter:tempChar];
    }
}

- (void) removePreference:(NSString *)key inWorldUUID:(NSString *)uuid withCharacter:(NSString *)character
{
    RDAtlantisWorldPreferences *preferences = [[[RDAtlantisMainController controller] worlds] worldForUUID:uuid];
    if (preferences) {
        NSString *tempChar = character;
        if ([character isEqualToString:@""])
            tempChar = nil;
        [preferences removePreferenceForKey:key withCharacter:tempChar];
    }
}

- (NSArray *) charactersForWorld:(NSString *)uuid
{
    RDAtlantisWorldPreferences *preferences = [[[RDAtlantisMainController controller] worlds] worldForUUID:uuid];
    if (preferences) {
        return [preferences characters];
    }
    else
        return [NSArray array];
}

- (RDAtlantisWorldInstance *) instanceForUuid:(NSString *)uuid withCharacter:(NSString *)character
{
    NSEnumerator *worldWalk = [[RDAtlantisMainController controller] worldWalk];
    RDAtlantisWorldInstance *world;

    while (world = [worldWalk nextObject]) {
        NSString *walkUUID = [[world preferences] uuid];
        
         if ([walkUUID isEqualToString:uuid]) {
            if ([[[world character] lowercaseString] isEqualToString:[character lowercaseString]])
                return world;
         }
    }
    
    return nil;
}

- (NSString *) isWorldConnected:(NSString *) uuid forCharacter:(NSString *)character
{
    RDAtlantisWorldInstance *world = [self instanceForUuid:uuid withCharacter:character];
    if (world) {
        return ([world isConnected] ? @"1" : @"0");
    }
    return 
        @"0";
}

- (void) connectWorld:(NSString *)uuid forCharacter:(NSString *)character
{
    RDAtlantisWorldInstance *world = [self instanceForUuid:uuid withCharacter:character];
    if (!world) {
        RDAtlantisWorldPreferences *preferences = [[[RDAtlantisMainController controller] worlds] worldForUUID:uuid];
        if (preferences) {
            NSString *basePath = [preferences basePathForCharacter:character];
            NSString *result = basePath;
            int loop = 0;
            while ([[RDAtlantisMainController controller] connectedWorld:result]) {
                result = [NSString stringWithFormat:@"%@ (%d)", basePath, ++loop];
            }
        
            world = [[RDAtlantisWorldInstance alloc] initWithWorld:preferences forCharacter:character withBasePath:result];
        }
    }
    
    if (![world isConnected])
        [world connect];
}

- (void) disconnectWorld:(NSString *)uuid forCharacter:(NSString *)character
{
    RDAtlantisWorldInstance *world = [self instanceForUuid:uuid withCharacter:character];
    if (world && [world isConnected]) {
        [world disconnectWithMessage:@"Disconnected by script."];
    }
}

- (void) focusSpawn:(NSString *) path
{
    id <RDNestedViewDescriptor> focusMe = nil;
    
    focusMe = [[RDNestedViewManager manager] viewByPath:path];
    
    if (focusMe) {
        [[RDNestedViewManager manager] performSelector:@selector(selectView:) withObject:focusMe afterDelay:0.2];
    }
}

- (NSString *) selectedStringInSpawn:(NSString *)path
{
    id <RDNestedViewDescriptor> view = nil;
    
    view = [[RDNestedViewManager manager] viewByPath:path];
    
    NSString *result = nil;
    if (view && [(NSObject *)view isKindOfClass:[RDAtlantisSpawn class]]) {
        result = [(RDAtlantisSpawn *)view stringFromOutputSelection];
    }
    
    if (result)
        return result;
    else
        return @"";
}

- (NSString *) getTextFromInputForSpawn:(NSString *)path
{
    id <RDNestedViewDescriptor> view = nil;
    
    view = [[RDNestedViewManager manager] viewByPath:path];
    
    if (view && [(NSObject *)view isKindOfClass:[RDAtlantisSpawn class]]) {
        return [(RDAtlantisSpawn *)view stringFromInput];
    }
    
    return @"";

}

- (void) setTextToInput:(NSString *)text forSpawn:(NSString *)path
{
    id <RDNestedViewDescriptor> view = nil;
    
    view = [[RDNestedViewManager manager] viewByPath:path];
    
    if (view && [(NSObject *)view isKindOfClass:[RDAtlantisSpawn class]]) {
        [(RDAtlantisSpawn *)view stringIntoInput:text];
    }
}

- (void) setStatusBarText:(NSString *)text forSpawn:(NSString *)path inWorld:(NSString *)worldName
{
    id <RDNestedViewDescriptor> view = nil;
    
    view = [[RDNestedViewManager manager] viewByPath:path];

    if (!view && [worldName length]) {
        view = [[RDNestedViewManager manager] viewByPath:[NSString stringWithFormat:@"%@:%@", worldName, path]];
    }
    
    if (!view && [worldName length] && path) {
        NSMutableString *realPath = [[path mutableCopy] autorelease];
        
        NSRange tempRange = [realPath rangeOfString:[NSString stringWithFormat:@"%@:",worldName]];
        if (tempRange.length) {
            [realPath replaceCharactersInRange:tempRange withString:@""];
        }
        
        RDAtlantisWorldInstance *world = [[RDAtlantisMainController controller] connectedWorld:worldName];
        if (!world)
            return;
        
        RDSpawnConfigRecord *config = [world configForSpawn:realPath];
        
        view = [world spawnForPath:realPath withPreferences:config];
    }    
        
    if (view && [(NSObject *)view isKindOfClass:[RDAtlantisSpawn class]]) {
        NSAttributedString *realString = [[NSAttributedString alloc] initWithAML:text forWorld:[(RDAtlantisSpawn *)view world] withFont:nil withDefaultFG:[NSColor blackColor] withDefaultBG:nil];
        [(RDAtlantisSpawn *)view setStatusBarUserText:realString];
        [realString release];
    }    
}


- (void) uploadCodefile:(NSString *) filename toWorld:(NSString *)worldName
{
    RDAtlantisWorldInstance *world = [[RDAtlantisMainController controller] connectedWorld:worldName];
    if (!world)
        return;

    CodeUploader *ulEngine =
        [[[CodeUploader alloc] initWithFile:[filename stringByExpandingTildeInPath] forWorld:world atInterval:0 withPrefix:nil suffix:nil] autorelease];
        
    if (!ulEngine) {
        // Error?
    }
}

- (void) uploadTextfile:(NSString *) filename toWorld:(NSString *)worldName
{
    RDAtlantisWorldInstance *world = [[RDAtlantisMainController controller] connectedWorld:worldName];
    if (!world)
        return;

    TextfileUploader *ulEngine =
        [[[TextfileUploader alloc] initWithFile:[filename stringByExpandingTildeInPath] forWorld:world atInterval:0 withPrefix:nil suffix:nil] autorelease];

    if (!ulEngine) {
        // Error?
    }
}

- (void) sendAsInput:(NSString *)text onWorld:(NSString *)worldName
{
    RDAtlantisWorldInstance *world = [[RDAtlantisMainController controller] connectedWorld:worldName];
    if (!world)
        return;

    [world processInputString:text onSpawn:nil];
}

- (void) appendAML:(NSString *)aml toSpawn:(NSString *)path inWorld:(NSString *)worldName
{
    if (!path || !aml)
        return;

    id <RDNestedViewDescriptor> view = nil;
    
    view = [[RDNestedViewManager manager] viewByPath:path];
    
    if (!view && [worldName length]) {
        view = [[RDNestedViewManager manager] viewByPath:[NSString stringWithFormat:@"%@:%@", worldName, path]];
    }
    
    if (!view && [worldName length] && path) {
        NSMutableString *realPath = [[path mutableCopy] autorelease];
        
        NSRange tempRange = [realPath rangeOfString:[NSString stringWithFormat:@"%@:",worldName]];
        if (tempRange.length) {
            [realPath replaceCharactersInRange:tempRange withString:@""];
        }
        
        RDAtlantisWorldInstance *world = [[RDAtlantisMainController controller] connectedWorld:worldName];
        if (!world)
            return;
        
        RDSpawnConfigRecord *config = [world configForSpawn:realPath];
        
        view = [world spawnForPath:realPath withPreferences:config];
    }    
    
    if (view && [(NSObject *)view isKindOfClass:[RDAtlantisSpawn class]]) {
        RDAtlantisSpawn *spawn = (RDAtlantisSpawn *)view;

        NSAttributedString *tempstring = [[NSAttributedString alloc] initWithAML:aml forWorld:[spawn world]];
        NSMutableAttributedString *realString = [tempstring mutableCopy];
        [tempstring release];
        
        if (![realString length] || [[realString string] characterAtIndex:[realString length] - 1] != '\n') {
            NSAttributedString *newline = [[NSAttributedString alloc] initWithString:@"\n"];
            [realString appendAttributedString:newline];
            [newline release];
        }

        if ([realString length])
            [realString addAttribute:@"RDTimeStamp" value:[NSDate date] range:NSMakeRange(0,[realString length])];
        
        [spawn appendString:realString];
        [realString release];
    }
}

- (void) replaceEventLine:(NSString *)aml inSession:(NSString *)sessionUID;
{
    if (!aml || !sessionUID)
        return;
        
    AtlantisState *state = [[RDAtlantisMainController controller] stateForSession:sessionUID];
    if (!state)
        return;

    NSMutableAttributedString *tempstring = [[NSMutableAttributedString alloc] initWithAML:aml forWorld:[state world]];
    if (!tempstring || ![tempstring length])
        return;
        
    if ([tempstring length])
        [tempstring addAttribute:@"RDTimeStamp" value:[NSDate date] range:NSMakeRange(0,[tempstring length])];
    
    [state setStringData:tempstring];
    [tempstring release];
}

- (void) setLineSpawn:(NSString *)spawn copy:(NSString *)copyMe inSession:(NSString *)sessionUID
{
    if (!sessionUID)
        return;
        
    NSString *realPath = spawn;

    AtlantisState *state = [[RDAtlantisMainController controller] stateForSession:sessionUID];
    if (!state)
        return;

    NSString *worldName = [state extraDataForKey:@"world.name"];

    if ([worldName length] && spawn) {
        NSMutableString *finalPath = [spawn mutableCopy];
        
        NSRange tempRange = [finalPath rangeOfString:[NSString stringWithFormat:@"%@:",worldName] options:NSCaseInsensitiveSearch];
        if (tempRange.length) {
            [finalPath replaceCharactersInRange:tempRange withString:@""];
        }

        realPath = finalPath;
        [finalPath autorelease];
    }      

    NSRange effRange;
    NSDictionary *attrs = [[state stringData] attributesAtIndex:0 effectiveRange:&effRange];
    NSArray *tempArray = [attrs objectForKey:@"RDExtraSpawns"];
    NSMutableArray *workArray;
    
    if (tempArray) {
        workArray = [tempArray mutableCopy];
    }
    else {
        workArray = [[NSMutableArray alloc] init];
    }

        
    [workArray addObject:realPath];

    unsigned stringLen = [[state stringData] length];
    effRange = NSMakeRange(0,stringLen);
    
    [[state stringData] addAttribute:@"RDExtraSpawns" value:[NSArray arrayWithArray:workArray] range:effRange];
    [[state stringData] addAttribute:@"RDExtraSpawnMove" value:[NSNumber numberWithBool:![copyMe intValue]] range:effRange];
    [workArray release];
}

- (void) setPrefix:(NSString *)prefix forSpawn:(NSString *)spawn inSession:(NSString *)sessionUID
{
    if (!sessionUID)
        return;
        
    NSString *realPath = spawn;
    AtlantisState *state = [[RDAtlantisMainController controller] stateForSession:sessionUID];
    if (!state)
        return;

    id <RDNestedViewDescriptor> view = [[RDNestedViewManager manager] viewByPath:spawn];
    NSString *worldName = [state extraDataForKey:@"world.name"];
    
    if (!view && [worldName length] && spawn) {
        NSMutableString *finalPath = [spawn mutableCopy];
        
        NSRange tempRange = [finalPath rangeOfString:[NSString stringWithFormat:@"%@:",worldName]];
        if (tempRange.length) {
            [finalPath replaceCharactersInRange:tempRange withString:@""];
        }

        realPath = finalPath;
        [finalPath autorelease];
    }      

    [[state world] setPrefix:prefix forSpawnPath:realPath];
}


- (NSString *) webCode:(NSColor *)color
{
    NSColor *tempColor = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];

    int red = [tempColor redComponent] * 255.0;
    int green = [tempColor greenComponent] * 255.0;
    int blue = [tempColor blueComponent] * 255.0;
    
    return [NSString stringWithFormat:@"#%02X%02X%02X",red,green,blue];
}

- (void) appendHTML:(NSString *)html toSpawn:(NSString *)path inWorld:(NSString *)worldName
{
    if (!path || !html)
        return;

    id <RDNestedViewDescriptor> view = nil;
    
    view = [[RDNestedViewManager manager] viewByPath:path];
    
    if (!view && [worldName length]) {
        view = [[RDNestedViewManager manager] viewByPath:[NSString stringWithFormat:@"%@:%@", worldName, path]];
    }
    
    if (!view && [worldName length] && path) {
        NSMutableString *realPath = [[path mutableCopy] autorelease];
        
        NSRange tempRange = [realPath rangeOfString:[NSString stringWithFormat:@"%@:",worldName]];
        if (tempRange.length) {
            [realPath replaceCharactersInRange:tempRange withString:@""];
        }
        
        RDAtlantisWorldInstance *world = [[RDAtlantisMainController controller] connectedWorld:worldName];
        if (!world)
            return;

        RDSpawnConfigRecord *config = [world configForSpawn:realPath];
            
        view = [world spawnForPath:realPath withPreferences:config];
    }
    
    if (view && [(NSObject *)view isKindOfClass:[RDAtlantisSpawn class]]) {
        RDAtlantisSpawn *spawn = (RDAtlantisSpawn *)view;
        NSFont *tempFont = [[spawn world] preferenceForKey:@"atlantis.formatting.font"];
        NSColor *tempColor = [[spawn world] preferenceForKey:@"atlantis.colors.default"];

        if (!tempColor) {
            NSArray *colors = [[spawn world] preferenceForKey:@"atlantis.colors.ansi"];
            if (colors) {
                tempColor = [colors objectAtIndex:7];
            }
        }
        
        // Convert from point to em.
        float fontSize = [tempFont pointSize] / 12.0f;

        NSString *tempHTML = 
            [NSString stringWithFormat:@"<span style='color: %@; font-family: %@, %@; font-size: %.3fem;'>%@</span>",
                [self webCode:tempColor], [tempFont displayName], [tempFont familyName], fontSize, html];

        NSData *data = [tempHTML dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSAttributedString *htmlString = [[NSAttributedString alloc] initWithHTML:data documentAttributes:nil];
        NSMutableAttributedString *realString = [htmlString mutableCopy];

        if (![realString length] || [[realString string] characterAtIndex:[realString length] - 1] != '\n') {
            NSAttributedString *newline = [[NSAttributedString alloc] initWithString:@"\n"];
            [realString appendAttributedString:newline];
            [newline release];
        }

        if ([realString length])
            [realString addAttribute:@"RDTimeStamp" value:[NSDate date] range:NSMakeRange(0,[realString length])];
            
        [(RDAtlantisSpawn *)view appendString:realString];
        [realString release];
        [htmlString release];
    }
}

- (void) registerFunction:(NSString *)function forLinePattern:(NSString *)pattern withLanguage:(NSString *)language inWorld:(NSString *)world
{
    [[RDAtlantisMainController controller]
        addScriptPattern:pattern withFunction:function inLanguage:language withWorld:world];    
}


- (void) registerFunction:(NSString *)function forEventType:(NSString *)eventType withLanguage:(NSString *)language inWorld:(NSString *)world
{
    [[RDAtlantisMainController controller]
        addScriptEvent:function inLanguage:language forType:eventType withWorld:world];
}

- (void) registerTimer:(NSString *)function withLanguage:(NSString *)language inWorld:(NSString *)world withInterval:(NSString *)seconds repeats:(NSString *)repeats
{
    if ([repeats intValue] != 0)
        [[RDAtlantisMainController controller]
            addScriptTimer:function inLanguage:language withWorld:world withInterval:[seconds intValue] repeats:[repeats intValue]];
}


- (void) registerAlias:(NSString *)function withName:(NSString *)alias withLanguage:(NSString *)language inWorld:(NSString *)world
{
    [[RDAtlantisMainController controller]
        addScriptAlias:alias forFunction:function inLanguage:language withWorld:world];
}

- (void) registerHotkeyFunction:(NSString *)function withKeyCode:(NSString *)keycode modifiers:(NSString *)modifiers globally:(NSString *)globally withLanguage:(NSString *)language
{
    [[RDAtlantisMainController controller]
        addScriptHotkey:[keycode intValue] modifiers:[modifiers intValue] globally:([globally intValue] != 0) forFunction:function inLanguage:language withWorld:@""];
}

- (void) speakText:(NSString *)text
{
    if (text && ![text isEqualToString:@""]) {
        if (_rdSpeaker) {
            [_rdSpeaker stopSpeaking];
        }
        else {
            _rdSpeaker = [[NSSpeechSynthesizer alloc] initWithVoice:nil];
        }
        [_rdSpeaker startSpeakingString:text];
    }
}

- (void) systemBeep
{
    NSBeep();
}

- (void) playSoundFile:(NSString *)filename
{
    if (_rdSound) {
        if (!IsMovieDone([_rdSound QTMovie])) {
            StopMovie([_rdSound QTMovie]);
        }
        [_rdSound release];
        _rdSound = nil;
    }

    if (filename) {
        NSString *realFilename = [filename stringByExpandingTildeInPath];
        _rdSound = [[NSMovie alloc] initWithURL:[NSURL fileURLWithPath:realFilename] byReference:YES];
        if (_rdSound) {
            GoToBeginningOfMovie([_rdSound QTMovie]);
            StartMovie([_rdSound QTMovie]);
        }
    }    
}

@end
