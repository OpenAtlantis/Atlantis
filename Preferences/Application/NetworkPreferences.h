//
//  NetworkPreferences.h
//  Atlantis
//
//  Created by Rachel Blackman on 9/20/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AtlantisPreferencePane.h"


@interface NetworkPreferences : NSObject<AtlantisPreferencePane> {

    IBOutlet NSView *                   _rdConfigView;

    IBOutlet NSPopUpButton *            _rdProxyType;
    IBOutlet NSTextField *              _rdProxyHost;
    IBOutlet NSTextField *              _rdProxyPort;
    IBOutlet NSTextField *              _rdProxyUser;
    IBOutlet NSTextField *              _rdProxyPass;
    
    IBOutlet  NSButton              *_rdDropNetOnLoss;
    IBOutlet  NSButton              *_rdCompressNet;    

}

@end
