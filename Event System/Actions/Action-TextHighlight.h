//
//  Action-TextHighlight.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/5/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface Action_TextHighlight : BaseAction {

    NSColor                 *_rdFgColor;
    NSColor                 *_rdBgColor;

    IBOutlet NSView         *_rdInternalConfigurationView;
    IBOutlet NSButton       *_rdFgColorActive;
    IBOutlet NSColorWell    *_rdFgColorPicker;
    IBOutlet NSButton       *_rdBgColorActive;
    IBOutlet NSColorWell    *_rdBgColorPicker;

}

- (id) initWithFgColor:(NSColor *)fgColor bgColor:(NSColor *)bgColor;

- (IBAction) fgColorChanged:(id) sender;
- (IBAction) bgColorChanged:(id) sender;

- (IBAction) fgColorActive:(id) sender;
- (IBAction) bgColorActive:(id) sender;

@end
