//
//  WorldConfigurationTab.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "WorldConfigurationTab.h"

@implementation WorldConfigurationTab

+(BOOL) globalTab
{
    return NO;
}

- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *) character
{
    self = [super init];
    if (self) {
        _rdPrefs = [prefs retain];
        if (character) {
            _rdCharacter = [[NSString stringWithString:character] retain];
        }
        else
            _rdCharacter = nil;
            
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(worldMustCommit:) name:@"RDAtlantisWorldShouldCommitNotification" object:_rdPrefs];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(worldWasUpdated:) name:@"RDAtlantisWorldDidUpdateNotification" object:_rdPrefs];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(characterWasUpdated:) name:@"RDAtlantisCharacterRenamedNotification" object:_rdPrefs];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self finalCommit];

    [_rdPrefs release];
    [_rdCharacter release];
    [super dealloc];
}

- (void) characterWasUpdated:(NSNotification *)notification
{
    NSString *oldCharacter = [[notification userInfo] objectForKey:@"RDAtlantisCharacterOld"];
    NSString *newCharacter = [[notification userInfo] objectForKey:@"RDAtlantisCharacterNew"];

    if ([self character] && [[self character] isEqualToString:oldCharacter]) {
        NSString *oldCharacter = _rdCharacter;
        _rdCharacter = [newCharacter retain];
        [oldCharacter release];
    }
}

- (void) worldMustCommit:(NSNotification *)notification
{
    NSString *testName;
    
    testName = [[notification userInfo] objectForKey:@"RDAtlantisCharacter"];
    if ((!testName && ![self character]) || (testName && [self character] && [testName isEqualToString:[self character]]))
        [self finalCommit];
}


- (void) worldWasUpdated:(NSNotification *)notification
{
    // Nothing, subclasses handle
}

- (RDAtlantisWorldPreferences *) preferences
{
    return _rdPrefs;
}

- (NSString *) character
{
    return _rdCharacter;
}

- (NSString *) configTabName
{
    return nil;
}

- (NSView *) configTabView
{
    return nil;
}

- (void) noteUpdate
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"RDAtlantisWorldDidUpdateNotification" object:_rdPrefs];
}

- (void) finalCommit
{
//    [self noteUpdate];
}

- (BOOL) shouldUpdateForNotification:(NSNotification *)notification
{
    BOOL update = NO;
    
    if (!notification)
        update = YES;
    else {
        NSDictionary *userInfo = [notification userInfo];
        if (userInfo) {
            NSArray *charUpdates = [userInfo objectForKey:@"RDCharacters"];
            if (charUpdates) {
                NSString *charTest = [self character];
                if (!charTest)
                    charTest = @"";
                
                if ([charUpdates containsObject:charTest])
                    update = YES;
            }
        }
    }

    return update;
}

@end

/* TEMPLATE

- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *) character
{
    self = [super initWithWorld:prefs forCharacter:character];
    if (self) {
        [NSBundle loadNibNamed:@"WorldConf_Whatever" owner:self];
    }
    return self;
}

- (NSString *) configTabName
{
    return @"Foo";
}

- (NSView *) configTabView
{
    return _rdConfigView;
}

- (void) worldWasUpdated:(NSNotification *)notification
{

}


 */