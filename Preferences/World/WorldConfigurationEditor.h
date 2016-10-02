//
//  WorldConfigurationEditor.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RDAtlantisWorldPreferences;

@interface WorldConfigurationEditor : NSObject {

    NSTabView                   *_rdConfigTabView;

    NSMutableArray              *_rdConfigPages;

    NSString                    *_rdCharacter;
    RDAtlantisWorldPreferences  *_rdPrefs;

}

- (id) initWithGlobalWorld;
- (id) initWithWorld:(RDAtlantisWorldPreferences *)prefs forCharacter:(NSString *)character;
- (NSView *) configView;

- (void) commitAll;

@end
