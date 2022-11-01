//
//  AddressBook.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WorldCollection;
@class RDAtlantisWorldPreferences;

@interface AddressBook : NSWindowController <NSOutlineViewDelegate, NSOutlineViewDataSource, NSWindowDelegate> {

    IBOutlet NSOutlineView          *_rdWorldList;
    IBOutlet NSTabView              *_rdConfigContent;
    
    IBOutlet NSButton               *_rdRemoveWorldButton;
    IBOutlet NSButton               *_rdAddCharacterButton;
    IBOutlet NSButton               *_rdRemoveCharacterButton;
    IBOutlet NSButton               *_rdConnectButton;
    IBOutlet NSButton               *_rdShortcutButton;

    NSMutableDictionary             *_rdWorldPreferenceViews;
    NSMutableArray                  *_rdWorldRecords;
    
    WorldCollection                 *_rdWorlds;
    
    BOOL                             _rdExpanding;
    
    NSImage                         *_rdGreenLightImage;
    NSImage                         *_rdWhiteLightImage;

}

- (void) setWorldCollection:(WorldCollection *)collection;
- (void) refreshWorldCollection;
- (void) display;

- (IBAction) connectWorld:(id) sender;
- (IBAction) addWorld:(id) sender;
- (IBAction) removeWorld:(id) sender;
- (IBAction) addCharacter:(id) sender;
- (IBAction) removeCharacter:(id) sender;

- (IBAction) createShortcut:(id) sender;

- (void) focusWorld:(RDAtlantisWorldPreferences *)world forCharacter:(NSString *)character;

@end
