//
//  RDLogCloser.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/15/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AtlantisState.h"

@class RDHotkeyState;

@interface RDLogCloser : NSObject <NSTableViewDataSource> {

    IBOutlet NSPanel                    *_rdCloserView;
    IBOutlet NSTableView                *_rdTableView;
    
    NSArray                             *_rdLogfiles;
    
    AtlantisState                       *_rdState;

}

- (id) initWithState:(AtlantisState *) state;
- (id) initWithHotkeyState:(RDHotkeyState *)state;
- (void) openPanel;

- (IBAction) closeLogs:(id) sender;
- (IBAction) cancelLogs:(id) sender;

@end
