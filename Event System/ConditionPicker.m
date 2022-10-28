//
//  ConditionPicker.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/6/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ConditionPicker.h"
#import "BaseCondition.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface ConditionPickerDelegate
- (void) newConditionPicked:(BaseCondition *)action context:(void *)context;
- (void) addCondition:(id) sender;
@end

static ConditionPicker *s_cPicker = nil;

@implementation ConditionPicker

+ (ConditionPicker *) sharedPanel
{
    if (!s_cPicker) {
        s_cPicker = [[ConditionPicker alloc] init];
    }
    
    return s_cPicker;
}

- (id) init
{
    self = [super init];
    if (self) {
        [NSBundle loadNibNamed:@"ConditionPicker" owner:self];
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
        NSMenuItem *item = [_rdConditionList selectedItem];
        unsigned position = [_rdConditionList indexOfItem:item];
        
        if (position != NSNotFound) {
            Class aClass = [_rdConditionClasses objectAtIndex:position];
            
            BaseCondition *newCondition = (BaseCondition *)class_createInstance(aClass,0);
            
            [_rdDelegate newConditionPicked:newCondition context:_rdContext];
        }
    }
    
    _rdDelegate = nil;
    _rdContext = NULL;
    [_rdConditionClasses release];
    [_rdConditionPicker orderOut:self];
}

- (void) runSheetModalForWindow:(NSWindow *) mainWindow conditions:(NSArray *) conditions target:(id) obj context:(void *) context
{
    if (_rdDelegate) {
        NSBeep();
        return;
    }

    _rdDelegate = obj;
    _rdConditionClasses = [conditions retain];
    _rdContext = context;
    
    [_rdConditionList removeAllItems];
    
    NSEnumerator *conditionEnum = [conditions objectEnumerator];
    
    Class classWalk;
    
    NSString* (*SendReturningString)(id, SEL) = (NSString* (*)(id, SEL))objc_msgSend;
    
    while (classWalk = [conditionEnum nextObject]) {
        NSString *result = SendReturningString(classWalk,@selector(conditionName));
        [_rdConditionList addItemWithTitle:result];
    }
    
    [NSApp beginSheet:_rdConditionPicker modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(_sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void) addCondition:(id) sender
{
    [NSApp endSheet:_rdConditionPicker returnCode:NSOKButton];
}

- (void) cancel:(id) sender
{
    [NSApp endSheet:_rdConditionPicker returnCode:NSCancelButton];
}

- (NSMenu *) menuForConditions:(NSArray *) conditions withTarget:(id) obj
{
    NSMenu *myMenu;
    
    myMenu = [NSMenu new];
    
    NSEnumerator *conditionEnum = [conditions objectEnumerator];
    
    Class classWalk;

    NSString* (*SendReturningString)(id, SEL) = (NSString* (*)(id, SEL))objc_msgSend;
    
    while (classWalk = [conditionEnum nextObject]) {
        NSString *result = SendReturningString(classWalk,@selector(conditionName));
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:result action:@selector(addCondition:) keyEquivalent:@""];
        [item setTarget:obj];
        [item setRepresentedObject:classWalk];
        [myMenu addItem:item];
    }
    
    return myMenu;
}

@end
