//
//  ConditionPicker.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/6/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ConditionPicker : NSWindowController {

    IBOutlet NSPopUpButton      *_rdConditionList;
    IBOutlet NSPanel            *_rdConditionPicker;
    
    id                           _rdDelegate;
    NSArray                     *_rdConditionClasses;
    
    void                        *_rdContext;

}

+ (ConditionPicker *) sharedPanel;
- (void) runSheetModalForWindow:(NSWindow *) window conditions:(NSArray *) conditions target:(id) obj context:(void *) context;

- (NSMenu *) menuForConditions:(NSArray *) conditions withTarget:(id) obj;

- (IBAction) addCondition:(id) sender;
- (IBAction) cancel:(id) sender;


@end
