//
//  MUSHTextEditor.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDMonospaceRulerView.h"
#import "RDMonospaceLayoutManager.h"

@class RDAtlantisWorldInstance;

@interface MUSHTextEditor : NSWindowController {

    IBOutlet NSTextView                     *_rdEditorView;
    IBOutlet NSTextView                     *_rdSourceView;
    
    IBOutlet NSMatrix                       *_rdColorPicker;
    IBOutlet NSMatrix                       *_rdAnsiTypePicker;

    IBOutlet NSButton                       *_rdCurrentColor;
    IBOutlet NSButton                       *_rdCurrentBackground;
    
    IBOutlet NSButton                       *_rdUnderline;
    IBOutlet NSButton                       *_rdInvertColors;

    RDAtlantisWorldInstance                 *_rdWorld;
    NSFont                                  *_rdFont;

    RDMonospaceRulerView                    *_rdRuler;
    RDMonospaceLayoutManager                *_rdLayoutManager;
    
    BOOL                                     _rdIsBackground;

    int                                      _rdForegroundColor;
    int                                      _rdBackgroundColor;

}

- (IBAction) colorPicked:(id) sender;
- (IBAction) ansiPicked:(id) sender;

- (IBAction) clearEditor:(id) sender;

- (IBAction) switchContext:(id) sender;

- (IBAction) toggleUnderline:(id) sender;
- (IBAction) toggleInverse:(id) sender;
- (IBAction) doConversion:(id) sender;

- (void) setupForWorld:(RDAtlantisWorldInstance *) world;

- (void) display;
- (BOOL) isInUse;

@end
