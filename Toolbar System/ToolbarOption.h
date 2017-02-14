//
//  ToolbarOption.h
//  Atlantis
//
//  Created by Rachel Blackman on 5/26/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AtlantisState;

@protocol ToolbarOption

- (BOOL) validForState:(AtlantisState *) state;
- (void) activateWithState:(AtlantisState *) state;

- (NSString *) toolbarItemIdentifier;
- (NSToolbarItem *) toolbarItemForState:(AtlantisState *)state;

@end
