//
//  WorldCollection.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RDAtlantisWorldPreferences;

@interface WorldCollection : NSObject {

    NSMutableArray              *_rdWorlds;

}

- (NSArray *) worlds;
- (unsigned) count;

- (void) addWorld:(RDAtlantisWorldPreferences *) world;
- (void) removeWorld:(RDAtlantisWorldPreferences *) world;
- (RDAtlantisWorldPreferences *) worldForName:(NSString *) name;
- (RDAtlantisWorldPreferences *) worldForUUID:(NSString *) uuid;

- (void) loadAllWorlds;
- (void) saveAllWorlds;
- (void) saveDirtyWorlds;
- (void) saveWorld:(RDAtlantisWorldPreferences *)world;

- (void) doAutoconnects;

- (RDAtlantisWorldPreferences *) importWorldXML:(NSString *)filename;

- (NSMenu *) worldMenu;

@end
