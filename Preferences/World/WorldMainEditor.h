//
//  WorldMainEditor.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WorldConfigurationTab.h"

@interface WorldMainEditor : WorldConfigurationTab <NSTextFieldDelegate> {

    IBOutlet NSView                  *_rdConfigView;

    IBOutlet NSButton                *_rdAutoconnect;
    IBOutlet NSPopUpButton           *_rdAutopicker;

    IBOutlet NSTextField             *_rdWorldName;
    IBOutlet NSTextField             *_rdDisplayAs;
    IBOutlet NSPopUpButton           *_rdServerType;
    
    IBOutlet NSTextField             *_rdHostName;
    IBOutlet NSTextField             *_rdHostPort;
    IBOutlet NSButton                *_rdHostSSL;
    
    IBOutlet NSPopUpButton           *_rdKeepaliveLogic;
    
    IBOutlet NSTextField             *_rdCharacterInternal;
    IBOutlet NSTextField             *_rdCharacterName;
    IBOutlet NSTextField             *_rdCharacterPass;
    
    IBOutlet NSTextField             *_rdLastConnected;
    IBOutlet NSTextField             *_rdTotalConnections;
    
}

- (IBAction) serverTypeChanged:(id) sender;
- (IBAction) autoconnectChanged:(id) sender;
- (IBAction) autoconnectTypeChanged:(id) sender;
- (IBAction) hostSSLChanged:(id) sender;
- (IBAction) keepaliveChanged:(id) sender;

@end
