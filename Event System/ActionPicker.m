//
//  ActionPicker.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/3/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ActionPicker.h"
#import "BaseAction.h"

@interface ActionPickerDelegate
- (void) newActionPicked:(BaseAction *)action context:(void *)context;
- (void) addAction:(id) sender;
@end

static ActionPicker *s_Picker = nil;

@implementation ActionPicker

+ (ActionPicker *) sharedPanel
{
    if (!s_Picker) {
        s_Picker = [[ActionPicker alloc] init];
    }
    
    return s_Picker;
}

- (id) init
{
    self = [super init];
    if (self) {
        [NSBundle loadNibNamed:@"ActionPicker" owner:self];
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void)_sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSOKButton) {
        NSMenuItem *item = [_rdActionList selectedItem];
        unsigned position = [_rdActionList indexOfItem:item];
        
        if (position != NSNotFound) {
            Class aClass = [_rdActionClasses objectAtIndex:position];
            
            BaseAction *newAction = (BaseAction *)class_createInstance(aClass,0);
            
            [_rdDelegate newActionPicked:newAction context:_rdContext];
        }
    }
    
    _rdDelegate = nil;
    _rdContext = NULL;
    [_rdActionClasses release];
    [_rdActionPicker orderOut:self];
}

- (void) runSheetModalForWindow:(NSWindow *) mainWindow actions:(NSArray *) actions target:(id) obj contect:(void *) context
{
    if (_rdDelegate) {
        NSBeep();
        return;
    }
    
    _rdDelegate = obj;
    _rdActionClasses = [actions retain];
    _rdContext = context;
    
    [_rdActionList removeAllItems];
    
    NSEnumerator *actionEnum = [actions objectEnumerator];
    
    Class classWalk;
    
    while (classWalk = [actionEnum nextObject]) {
        NSString *result = objc_msgSend(classWalk,@selector(actionName));
        [_rdActionList addItemWithTitle:result];
    }
    
    [NSApp beginSheet:_rdActionPicker modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(_sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void) addAction:(id) sender
{
    [NSApp endSheet:_rdActionPicker returnCode:NSOKButton];
}

- (void) cancel:(id) sender
{
    [NSApp endSheet:_rdActionPicker returnCode:NSCancelButton];
}

- (NSMenu *) menuForActions:(NSArray *) actions withTarget:(id) obj
{
    NSMenu *myMenu;
    
    myMenu = [NSMenu new];
    
    NSEnumerator *actionEnum = [actions objectEnumerator];
    
    Class classWalk;
    
    while (classWalk = [actionEnum nextObject]) {
        NSString *result = objc_msgSend(classWalk,@selector(actionName));
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:result action:@selector(addAction:) keyEquivalent:@""];
        [item setTarget:obj];
        [item setRepresentedObject:classWalk];
        [myMenu addItem:item];
    }
    
    return myMenu;
}


@end
