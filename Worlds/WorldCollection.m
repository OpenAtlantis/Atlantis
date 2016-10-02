//
//  WorldCollection.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldCollection.h"
#import "RDAtlantisWorldPreferences.h"
#import "RDAtlantisMainController.h"
#import "RDAtlantisWorldInstance.h"
#import <Lemuria/Lemuria.h>
#import "NSDictionary+XMLPersistence.h"

int compareWorlds(id obj1, id obj2, void *context)
{
    RDAtlantisWorldPreferences *prefs1 = (RDAtlantisWorldPreferences *)obj1;
    RDAtlantisWorldPreferences *prefs2 = (RDAtlantisWorldPreferences *)obj2;
    
    NSString *name1 = [prefs1 preferenceForKey:@"atlantis.world.name" withCharacter:nil];
    NSString *name2 = [prefs2 preferenceForKey:@"atlantis.world.name" withCharacter:nil];

    if (name1 && name2)
        return [name1 compare:name2];
    else
        return NSOrderedSame;
}

@implementation WorldCollection

- (id) init
{
    self = [super init];
    if (self) {
        _rdWorlds = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [_rdWorlds release];
    [super dealloc];
}

- (NSArray *) worlds
{
    return _rdWorlds;
}

- (unsigned) count
{
    return [_rdWorlds count];
}

- (void) sortWorlds
{
    [_rdWorlds sortUsingFunction:compareWorlds context:nil];
}

- (RDAtlantisWorldPreferences *) worldForName:(NSString *) worldName
{
    NSEnumerator *worldEnum = [_rdWorlds objectEnumerator];
    RDAtlantisWorldPreferences *result = nil;
    RDAtlantisWorldPreferences *walk;
    
    while (!result && (walk = [worldEnum nextObject])) {
        NSString *tempWorldName = 
            [walk preferenceForKey:@"atlantis.world.name" withCharacter:nil fallback:NO];
            
        if (tempWorldName && [tempWorldName isEqualToString:worldName])
            result = walk;
    }
    
    return walk;
}

- (RDAtlantisWorldPreferences *) worldForUUID:(NSString *) worldName
{
    NSEnumerator *worldEnum = [_rdWorlds objectEnumerator];
    RDAtlantisWorldPreferences *result = nil;
    RDAtlantisWorldPreferences *walk;
    
    while (!result && (walk = [worldEnum nextObject])) {
        NSString *tempWorldName = 
            [walk uuid];
            
        if (tempWorldName && [tempWorldName isEqualToString:worldName])
            result = walk;
    }
    
    return walk;
}


- (BOOL) createDirectoriesToFile:(NSString *) filename
{
    NSArray *pathComponents = [[[filename stringByExpandingTildeInPath] stringByDeletingLastPathComponent] pathComponents];
    
    NSString *currentPath = @"";
    NSFileManager *fileman = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    NSEnumerator *pathEnum = [pathComponents objectEnumerator];
    NSString *pathFragment = @"/";
    
    do {
        currentPath = [currentPath stringByAppendingPathComponent:pathFragment];
        if ([fileman fileExistsAtPath:currentPath isDirectory:&isDirectory]) {
            if (!isDirectory)
                return NO;
        }
        else {
            if (![fileman createDirectoryAtPath:currentPath attributes:nil])
                return NO;
        }
    } while (pathFragment = [pathEnum nextObject]);

    return YES;
}

- (void) saveAllWorlds
{
    NSEnumerator *worldEnum = [_rdWorlds objectEnumerator];

    RDAtlantisWorldPreferences *prefWalk;
    
    while (prefWalk = [worldEnum nextObject]) {
        NSString *worldName = 
            [prefWalk uuid];
        BOOL expiring = [prefWalk expiring];
    
        if (worldName && !expiring) {
            NSString *filename = 
                [NSString stringWithFormat:@"~/Library/Application Support/Atlantis/worlds/%@.awd",
                    worldName];
                    
            filename = [filename stringByExpandingTildeInPath];
            [self createDirectoriesToFile:filename];

            [NSKeyedArchiver archiveRootObject:prefWalk toFile:filename];
        }
    }
}

- (void) saveDirtyWorlds
{
    NSEnumerator *worldEnum = [_rdWorlds objectEnumerator];

    RDAtlantisWorldPreferences *prefWalk;
    
    while (prefWalk = [worldEnum nextObject]) {
        NSString *worldName = 
            [prefWalk uuid];
        BOOL expiring = [prefWalk expiring];
        BOOL dirty = [prefWalk dirty];
    
        if (worldName && !expiring && dirty) {
            NSString *filename = 
                [NSString stringWithFormat:@"~/Library/Application Support/Atlantis/worlds/%@.awd",
                    worldName];
                    
            filename = [filename stringByExpandingTildeInPath];
            [self createDirectoriesToFile:filename];

            [NSKeyedArchiver archiveRootObject:prefWalk toFile:filename];
        }
    }
}


- (void) saveWorld:(RDAtlantisWorldPreferences *)world
{
    NSString *worldName = 
        [world uuid];

    BOOL temporary = [[world preferenceForKey:@"atlantis.world.temporary" withCharacter:nil] boolValue];    
    BOOL expiring = [world expiring];

    if (worldName && !temporary && !expiring) {
        NSString *filename = 
            [NSString stringWithFormat:@"~/Library/Application Support/Atlantis/worlds/%@.awd",
                worldName];
                
        filename = [filename stringByExpandingTildeInPath];
        [self createDirectoriesToFile:filename];
        
        [NSKeyedArchiver archiveRootObject:world toFile:filename];
    }
}

- (void) addDefaultWorlds
{
    RDAtlantisWorldPreferences *tempPref;
    
    // OGR
    tempPref = [[RDAtlantisWorldPreferences alloc] init];
    [tempPref setPreference:@"Online Gaming Resource" forKey:@"atlantis.world.name" withCharacter:nil];
    [tempPref setPreference:@"ogrmush.com" forKey:@"atlantis.world.host" withCharacter:nil];
    [tempPref setPreference:[NSNumber numberWithInt:6700] forKey:@"atlantis.world.port" withCharacter:nil];
    [tempPref setPreference:@"OGR" forKey:@"atlantis.world.displayName" withCharacter:nil];
    [tempPref setPreference:@"http://www.ogrmush.com/" forKey:@"atlantis.world.website" withCharacter:nil];
    [tempPref setPreference:@"Online Gaming Resource is a server set up specifically to provide resources to the MUSH/MUX community.  You can find advertisements for games, help with coding, recruit players, or even try to find staff for your budding game there." forKey:@"atlantis.world.description" withCharacter:nil];
    [tempPref addCharacter:@"Guest"];
    [tempPref setPreference:@"Guest" forKey:@"atlantis.world.character" withCharacter:@"Guest"];
    [tempPref setPreference:@"guest" forKey:@"atlantis.world.password" withCharacter:@"Guest"];
    [_rdWorlds addObject:tempPref];
    [tempPref release];
    
    // Firan
    tempPref = [[RDAtlantisWorldPreferences alloc] init];
    [tempPref setPreference:@"Firan" forKey:@"atlantis.world.name" withCharacter:nil];
    [tempPref setPreference:@"firan.legendary.org" forKey:@"atlantis.world.host" withCharacter:nil];
    [tempPref setPreference:[NSNumber numberWithInt:5000] forKey:@"atlantis.world.port" withCharacter:nil];
    [tempPref setPreference:@"http://firan.legendary.org/" forKey:@"atlantis.world.website" withCharacter:nil];
    [tempPref setPreference:@"On FiranMUX, religion, politics, warfare and romance all mesh into a fantasy world reminiscent of ancient Rome to create a distinctive role-playing experience. Set in the capital city of Anarinuell, rival clans unite as a single Republic to fight a more dangerous foe.  Having recaptured their homelands from the Shamibelians, their hated horned enemy, the Firans had at least two crucial tasks before them: to take back the last enslaved Firan city of Ellish, and to learn to live as one people under a new government despite internal conflicts.  Several long years ago the Republic splintered when one clan left, and the remaining clans struggled to come together again under a new Alliance and new leadership. That leadership has proved ineffectual and now their children are being trained and taught to become leaders themselves under a guidance of a Viceroy, who holds the position of supreme authority over the Firan people until one of those children can prove himself to be an effective leader and be elected by a council of his peers as Ranivor.\n\nExtensive coded systems enhance role-play and provide an easy-to-use, intellectually challenging, and character-focused environment.  Helpful staff and friendly players all contribute to a fun time for all!  Choose from more than a hundred different characters, each with a rich background and built-in relationships, or create one of your own through a thematically guided chargen process that allows you to forge your own path." forKey:@"atlantis.world.description" withCharacter:nil];
    [tempPref addCharacter:@"Guest"];
    [tempPref setPreference:@"Guest" forKey:@"atlantis.world.character" withCharacter:@"Guest"];
    [tempPref setPreference:@"guest" forKey:@"atlantis.world.password" withCharacter:@"Guest"];
    [_rdWorlds addObject:tempPref];
    [tempPref release];
    
    // Star Wars Sagas
    tempPref = [[RDAtlantisWorldPreferences alloc] init];
    [tempPref setPreference:@"Star Wars Sagas" forKey:@"atlantis.world.name" withCharacter:nil];
    [tempPref setPreference:@"mush.swsagas.net" forKey:@"atlantis.world.host" withCharacter:nil];
    [tempPref setPreference:[NSNumber numberWithInt:1138] forKey:@"atlantis.world.port" withCharacter:nil];
    [tempPref setPreference:@"SWS" forKey:@"atlantis.world.displayName" withCharacter:nil];
    [tempPref setPreference:@"http://www.swsagas.net/" forKey:@"atlantis.world.website" withCharacter:nil];
    [tempPref setPreference:@"Will your character have a hand in raising the ragtag of rebels into the true Rebel Alliance? Will your character oppress countless beings on thousands of worlds in their service to the Emperor? Will you run the space lanes, smuggle spice, drink lum, and owe too much money to a gangster on some backwater world? You will decide these things.\n\nThe theme of our MUSH is simple: the star wars universe, but at the same time very complex. With control over the characters of the galaxy, we are free to explore hundreds of different stories and we invite you to explore them with us. We will create the great bounty hunters, the slickest smugglers, and the most heroic rebels. We create the bad-guys and the good-guys and meld them into the great stories of Star Wars." forKey:@"atlantis.world.description" withCharacter:nil];
    [tempPref addCharacter:@"Guest"];
    [tempPref setPreference:@"Guest" forKey:@"atlantis.world.character" withCharacter:@"Guest"];
    [tempPref setPreference:@"guest" forKey:@"atlantis.world.password" withCharacter:@"Guest"];
    [_rdWorlds addObject:tempPref];
    [tempPref release];
    
    tempPref = [[RDAtlantisWorldPreferences alloc] init];
    [tempPref setPreference:@"Cuendillar" forKey:@"atlantis.world.name" withCharacter:nil];
    [tempPref setPreference:@"cuendillar.org" forKey:@"atlantis.world.host" withCharacter:nil];
    [tempPref setPreference:[NSNumber numberWithInt:7200] forKey:@"atlantis.world.port" withCharacter:nil];
    [tempPref setPreference:@"http://www.cuendillar.org/" forKey:@"atlantis.world.website" withCharacter:nil];
    [tempPref setPreference:@"Cuendillar MUSH is a online roleplaying game based loosely on Robert Jordan's Wheel of Time Series. The world is set in an alternate dimension, as depicted in 'The Great Hunt', and carries it's own plots and story lines for that alternate dimension. History diverges after the Aiel War. Players do not need to read the books to play the game, as they have extensive theme files that detail the setting of the world. " forKey:@"atlantis.world.description" withCharacter:nil];
    [tempPref addCharacter:@"Guest"];
    [tempPref setPreference:@"Guest" forKey:@"atlantis.world.character" withCharacter:@"Guest"];
    [tempPref setPreference:@"guest" forKey:@"atlantis.world.password" withCharacter:@"Guest"];
    [_rdWorlds addObject:tempPref];
    [tempPref release];
    
    tempPref = [[RDAtlantisWorldPreferences alloc] init];
    [tempPref setPreference:@"X-Men Retribution" forKey:@"atlantis.world.name" withCharacter:nil];
    [tempPref setPreference:@"xmr.dune.net" forKey:@"atlantis.world.host" withCharacter:nil];
    [tempPref setPreference:[NSNumber numberWithInt:4567] forKey:@"atlantis.world.port" withCharacter:nil];
    [tempPref setPreference:@"XMR" forKey:@"atlantis.world.displayName" withCharacter:nil];
    [tempPref setPreference:@"http://xmr.dune.net/" forKey:@"atlantis.world.website" withCharacter:nil];
    [tempPref setPreference:@"Welcome to the world of the X-Men. Set in the near future, X-Men: Retribution explores what it is to be different in a world that fears those who are not the same. A heated political debate rages over the proposed 'Mutant Registration Act'. Many are opposed, many are for it - and both sides have those who will take to violence to try to prove their point in an ever escalating war being fought on many fronts.\n\nFrom students at Xavier's just learning what their powers can do, to an an embittered member of the terrorist Brotherhood, to an average Joe on the street, there's a role for everyone on X-Men: Retribution. OOCly, we emphasize community and involvement both from staff and players. OCs and FCs are equally welcome." forKey:@"atlantis.world.description" withCharacter:nil];
    [tempPref addCharacter:@"Guest"];
    [tempPref setPreference:@"Guest" forKey:@"atlantis.world.character" withCharacter:@"Guest"];
    [tempPref setPreference:@"guest" forKey:@"atlantis.world.password" withCharacter:@"Guest"];
    [_rdWorlds addObject:tempPref];
    [tempPref release];
}

- (void) loadAllWorlds
{
    NSString *worldPath = @"~/Library/Application Support/Atlantis/worlds";
    worldPath = [worldPath stringByExpandingTildeInPath];

    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:worldPath];
    NSString *filename;
    
    while (filename = [dirEnum nextObject]) {
        if ([[filename pathExtension] isEqualToString:@"awd"]) {
            NSString *fullPath = [NSString stringWithFormat:@"%@/%@", worldPath, filename];
            
            RDAtlantisWorldPreferences *newPrefs = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
            if (newPrefs) {
                [_rdWorlds addObject:newPrefs];                
            }
        }
    }
    [self sortWorlds];
    if ([self count] == 0) {
        [self addDefaultWorlds];
    }
}

- (void) doAutoconnects
{
    NSEnumerator *worldEnum = [_rdWorlds objectEnumerator];
    RDAtlantisWorldPreferences *newPrefs;
    
    while (newPrefs = [worldEnum nextObject]) {
        BOOL instance = NO;
        BOOL connect = NO;
        
        NSNumber *tempNumber = [newPrefs preferenceForKey:@"atlantis.world.autoconnect" withCharacter:nil fallback:NO];
        if ([tempNumber boolValue]) {
            instance = YES;
            connect = YES;
        }
        tempNumber = [newPrefs preferenceForKey:@"atlantis.world.autoopen" withCharacter:nil fallback:NO];                
        if (!instance && [tempNumber boolValue]) {
            instance = YES;
        }
        
        if (instance) {
            RDAtlantisWorldInstance *instance =                        
            [[RDAtlantisWorldInstance alloc] initWithWorld:newPrefs forCharacter:nil withBasePath:[newPrefs basePathForCharacter:nil]];
            
            if (connect)
                [instance connect];
            else
                [instance outputStatus:@"World was auto-opened, but not connected." toSpawn:@""];
        }
        
        
        NSEnumerator *charEnum = [[newPrefs characters] objectEnumerator];
        NSString *charWalk;
        
        while (charWalk = [charEnum nextObject]) {
            instance = NO;
            connect = NO;
            
            tempNumber = [newPrefs preferenceForKey:@"atlantis.world.autoconnect" withCharacter:charWalk fallback:NO];
            if ([tempNumber boolValue]) {
                instance = YES;
                connect = YES;
            }
            
            tempNumber = [newPrefs preferenceForKey:@"atlantis.world.autoopen" withCharacter:charWalk fallback:NO];
            if (!instance && [tempNumber boolValue]) {
                instance = YES;
            }
            
            if (instance) {
                RDAtlantisWorldInstance *charInstance =                        
                [[RDAtlantisWorldInstance alloc] initWithWorld:newPrefs forCharacter:charWalk withBasePath:[newPrefs basePathForCharacter:charWalk]];
                
                if (connect)
                    [charInstance connect];
                else
                    [charInstance outputStatus:@"World was auto-opened, but not connected." toSpawn:@""];
                
            }                    
        }
    }
}

- (void) deleteFileForWorld:(RDAtlantisWorldPreferences *)world
{
    NSString *worldName = 
        [world uuid];
    
    if (worldName) {
        NSString *filename = 
        [NSString stringWithFormat:@"~/Library/Application Support/Atlantis/worlds/%@.awd",
            worldName];
        
        filename = [filename stringByExpandingTildeInPath];
        [[NSFileManager defaultManager] removeFileAtPath:filename handler:nil];
    }
}

- (void) addWorld:(RDAtlantisWorldPreferences *)world
{
    if (![_rdWorlds containsObject:world]) {
        [_rdWorlds addObject:world];
        [self sortWorlds];
    }
}

- (void) removeWorld:(RDAtlantisWorldPreferences *)world
{
    if ([_rdWorlds containsObject:world]) {
        [_rdWorlds removeObject:world];
        [self deleteFileForWorld:world];
    }
}

- (void) connectWorldFromMenu:(id) sender
{
    NSMenuItem *item = (NSMenuItem *)sender;
    NSString *characterName = nil;
    
    RDAtlantisWorldPreferences *world = [item representedObject];
    if ([item indentationLevel] == 1) {
        characterName = [item title];
    }

    RDAtlantisWorldInstance *instance;
    NSString *path = [world basePathForCharacter:characterName];
    
    instance = [[RDAtlantisMainController controller] connectedWorld:path];
    if (!instance) {
        instance = [[RDAtlantisWorldInstance alloc] initWithWorld:world forCharacter:characterName withBasePath:[world basePathForCharacter:characterName]];
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.worldMenu.doubleConnect"]) {
        NSString *basePath = [world basePathForCharacter:characterName];
        NSString *result;
        
        BOOL done = NO;
        int counter = 2;
        
        while (!done) {
            result = [NSString stringWithFormat:@"%@ (%d)", basePath, counter];
            if ([[RDAtlantisMainController controller] connectedWorld:result]) {
                counter++;
            }
            else {
                done = YES;
            }
        }
        
        instance = [[RDAtlantisWorldInstance alloc] initWithWorld:world forCharacter:characterName withBasePath:result];
    }
    
    if (![instance isConnecting]) {
        [instance connect];
    }
        
    id <RDNestedViewDescriptor> view = [[RDNestedViewManager manager] viewByPath:path];
    if (view) {
        [[RDNestedViewManager manager] selectView:view];
    }
}

- (NSMenu *) worldMenu
{
    NSMenu *worlds = [NSMenu new];
    [worlds setAutoenablesItems:NO];
    
    NSMenuItem *addressItem = [[NSMenuItem alloc] initWithTitle:@"Open Address Book..." action:@selector(addressBook:) keyEquivalent:@""];
    [addressItem setTarget:[RDAtlantisMainController controller]];
    [worlds addItem:addressItem];
    [addressItem release];
    
    [worlds addItem:[NSMenuItem separatorItem]];
    
    NSEnumerator *worldEnum = [_rdWorlds objectEnumerator];
    RDAtlantisWorldPreferences *worldWalk;
    RDAtlantisMainController *controller = [RDAtlantisMainController controller];
    
    while (worldWalk = [worldEnum nextObject]) {
        NSString *worldName = [worldWalk preferenceForKey:@"atlantis.world.name" withCharacter:nil];
        NSString *worldPath = [worldWalk basePathForCharacter:nil];
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:worldName action:@selector(connectWorldFromMenu:) keyEquivalent:@""];
        [item setTarget:self];
        [item setRepresentedObject:worldWalk];
        
        RDAtlantisWorldInstance *instance = [controller connectedWorld:worldPath];
        BOOL connected = NO;
        if (instance)
            connected = [instance isConnecting];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.worldMenu.doubleConnect"])
            [item setEnabled:!connected];

        [worlds addItem:item];
        [item release];
        
        NSEnumerator *charEnum = [[worldWalk characters] objectEnumerator];
        NSString *charWalk;
        
        while (charWalk = [charEnum nextObject]) {
            item = [[NSMenuItem alloc] initWithTitle:charWalk action:@selector(connectWorldFromMenu:) keyEquivalent:@""];
            [item setTarget:self];
            [item setRepresentedObject:worldWalk];
            [item setIndentationLevel:1];

            instance = [controller connectedWorld:[worldWalk basePathForCharacter:charWalk]];
            connected = NO;
            if (instance)
                connected = [instance isConnecting];
        
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.worldMenu.doubleConnect"])
                [item setEnabled:!connected];
        
            [worlds addItem:item];
            [item release];
        }
    }
    
    return worlds;
}

- (RDAtlantisWorldPreferences *) importWorldXML:(NSString *)filename
{
    NSDictionary *tempWorldValues = [NSDictionary dictionaryWithContentsOfXMLFile:filename];
    
    if (tempWorldValues) {
        NSDictionary *world = [tempWorldValues objectForKey:@"world"];
        if (!world) {
            NSDictionary *temp = [[tempWorldValues allValues] objectAtIndex:0];
            if (temp) {
                world = [temp objectForKey:@"world"];
            }
        }
        if (world) {
            NSString *basename = [world objectForKey:@"name"];
            
            NSString *name = basename;
            int loop = 1;
            
            while ([self worldForName:name]) {
                name = [NSString stringWithFormat:@"%@-%d", basename, loop];
                loop++;
            }
            
            NSString *host = [world objectForKey:@"host"];
            NSString *port = [world objectForKey:@"port"];
            NSString *url = [world objectForKey:@"url"];
            
            if (name && host && port) {
                RDAtlantisWorldPreferences *newPrefs = [[RDAtlantisWorldPreferences alloc] init];
                [newPrefs setPreference:name forKey:@"atlantis.world.name" withCharacter:nil];
                [newPrefs setPreference:host forKey:@"atlantis.world.host" withCharacter:nil];
                [newPrefs setPreference:[NSNumber numberWithInt:[port intValue]] forKey:@"atlantis.world.port" withCharacter:nil];
                
                if (url) {
                    [newPrefs setPreference:url forKey:@"atlantis.world.website" withCharacter:nil];
                }
                
                NSString *serverType = [world objectForKey:@"linetype"];
                if (serverType && [[serverType lowercaseString] isEqualToString:@"mud"]) {
                    [newPrefs setPreference:[NSNumber numberWithInt:AtlantisServerMud] forKey:@"atlantis.world.codebase" withCharacter:nil];
                }
                else if (serverType && [[serverType lowercaseString] isEqualToString:@"ire"]) {
                    [newPrefs setPreference:[NSNumber numberWithInt:AtlantisServerIRE] forKey:@"atlantis.world.codebase" withCharacter:nil];                
                }
                
                NSDictionary *guestchar = [world objectForKey:@"guest"];
                if (guestchar) {
                    NSString *character = [guestchar objectForKey:@"character"];
                    NSString *pass = [guestchar objectForKey:@"password"];
                    
                    if (character && pass) {
                        [newPrefs addCharacter:@"Guest"];
                        [newPrefs setPreference:character forKey:@"atlantis.world.character" withCharacter:@"Guest"];
                        [newPrefs setPreference:pass forKey:@"atlantis.world.password" withCharacter:@"Guest"];
                    }
                }
                
                [self addWorld:newPrefs];
                NSString *worldName = 
                    [newPrefs uuid];
                
                if (worldName) {
                    NSString *filename = 
                    [NSString stringWithFormat:@"~/Library/Application Support/Atlantis/worlds/%@.awd",
                        worldName];
                    
                    filename = [filename stringByExpandingTildeInPath];
                    [self createDirectoriesToFile:filename];
                    
                    [NSKeyedArchiver archiveRootObject:newPrefs toFile:filename];
                }
                
                return newPrefs;
            }
        }
    }
    
    // Unable to load file, display alert somehow?
    
    return nil;
}

@end
