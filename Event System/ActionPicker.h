//
//  ActionPicker.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/3/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ActionPicker : NSWindowController {

    IBOutlet NSPopUpButton      *_rdActionList;
    IBOutlet NSPanel            *_rdActionPicker;
    
    id                           _rdDelegate;
    NSArray                     *_rdActionClasses;
    
    void                        *_rdContext;

}

+ (ActionPicker *) sharedPanel;
- (void) runSheetModalForWindow:(NSWindow *) window actions:(NSArray *) actions target:(id) obj contect:(void *) context;

- (NSMenu *) menuForActions:(NSArray *) actions withTarget:(id) obj;

- (IBAction) addAction:(id) sender;
- (IBAction) cancel:(id) sender;


@end
