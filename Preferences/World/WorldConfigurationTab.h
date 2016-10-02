//
//  WorldConfigurationTab.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDAtlantisWorldPreferences.h"

@interface WorldConfigurationTab : NSObject {
    
    RDAtlantisWorldPreferences              *_rdPrefs;
    NSString                                *_rdCharacter;
    
}

+ (BOOL) globalTab;

- (id) initWithWorld:(RDAtlantisWorldPreferences *)preferences forCharacter:(NSString *) characterName;

- (NSString *) configTabName;
- (NSView *) configTabView;

- (RDAtlantisWorldPreferences *) preferences;
- (NSString *) character;

- (BOOL) shouldUpdateForNotification:(NSNotification *)notification;

- (void) worldMustCommit:(NSNotification *)notification;
- (void) worldWasUpdated:(NSNotification *)notification;
- (void) characterWasUpdated:(NSNotification *)notification;

- (void) finalCommit;
- (void) noteUpdate;

@end
