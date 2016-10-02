//
//  HotkeyPreferences.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "HotkeyPreferences.h"
#import "EventEditor.h"
#import "HotkeyCollection.h"
#import "PTKeyCombo.h"
#import "PTKeyComboPanel.h"
#import "HotkeyEvent.h"
#import "RDAtlantisMainController.h"

#import "ActionPicker.h"
#import "BaseAction.h"
#import "ActionClasses.h"

static NSImage *s_rdKeyIcon = nil;

@implementation HotkeyPreferences

- (id) initForCollection:(HotkeyCollection *) collection
{
    self = [super init];
    if (self) {
        _rdEventEditor = [[EventEditor alloc] init];
        
        NSButtonCell *buttonCell = [NSButtonCell new];
        [buttonCell setButtonType:NSSwitchButton];
        [buttonCell setImagePosition:NSImageOnly];
        [buttonCell setType:NSImageCellType];
        
        [_rdEventEditor setNameColumnTitle:@"Key"];
        [_rdEventEditor addExtraDataColumn:@"eventGlobal" withTitle:@"Global" andCell:buttonCell atIndex:1];
        
        _rdHotkeyCollection = [collection retain];
        [_rdEventEditor setDataRepresentation:_rdHotkeyCollection];
        [_rdEventEditor setDelegate:self];        
        [_rdEventEditor setForEventType:[[HotkeyEvent alloc] init]];
        [[_rdEventEditor editorView] setFrame:NSMakeRect(0,0,800,500)];
    }
    return self;
}

- (void) dealloc
{
    [_rdEventEditor release];
    [_rdHotkeyCollection release];
    [super dealloc];
}

- (void)preferencePaneCommit
{
    NSString *filename = @"~/Library/Application Support/Atlantis/hotkeys.akb";
    filename = [filename stringByExpandingTildeInPath];
    [NSKeyedArchiver archiveRootObject:_rdHotkeyCollection toFile:filename];
}

- (NSString *) preferencePaneName
{
    return @"Hotkeys";
}

- (NSImage *) preferencePaneImage
{
    if (!s_rdKeyIcon)
        s_rdKeyIcon = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"PTKeyboardIcon"]];
    
    return s_rdKeyIcon;
}

- (NSView *) preferencePaneView
{
    return [_rdEventEditor editorView];
}

#pragma mark Event Editor Delegate

- (void) newActionPicked:(BaseAction *)action context:(void *) context
{
    id <EventDataProtocol> event = (id <EventDataProtocol>)context;
    
    if (event) {
        [event eventAddAction:action];
    }
    [_rdEventEditor updateDataRepresentation];
    [_rdEventEditor tableViewSelectionDidChange:nil];
}

- (NSArray *) conditions
{
    return [NSArray array];
}

- (NSArray *) actions
{
    return [[[RDAtlantisMainController controller] eventActions] actionsForType:AtlantisTypeUI];
}


- (void) addEventAction:(id <EventDataProtocol>)event
{
    ActionPicker *picker = [ActionPicker sharedPanel];

    NSArray *actions = [[[RDAtlantisMainController controller] eventActions] actionsForType:AtlantisTypeUI];
    
    [picker runSheetModalForWindow:[[_rdEventEditor editorView] window] actions:actions target:self contect:event];
}

- (void) addEventCondition:(id <EventDataProtocol>)event
{
    // Do nothing, this is empty
}

- (void) hotKeySheetDidEndWithReturnCode: (NSNumber *) returnCode
{
    if ([returnCode intValue] == NSOKButton) {
        PTKeyCombo *key = [[PTKeyComboPanel sharedPanel] keyCombo];

        if ([key isValidHotKeyCombo]) {
            HotkeyEvent *event = [[HotkeyEvent alloc] init];
            [event setKeyCombo:key];
            [event eventSetEnabled:YES];
            [_rdHotkeyCollection addEvent:event];
            [_rdEventEditor updateDataRepresentation];
            [_rdEventEditor selectEvent:event];
        } 
    }
}

- (void) addEvent
{
    PTKeyComboPanel *panel = [PTKeyComboPanel sharedPanel];
    PTKeyCombo *key = [[[PTKeyCombo alloc] init] autorelease];
    [panel setKeyCombo:key];
    [panel setKeyBindingName:@"Atlantis Hotkey Binding"];
    [panel runSheeetForModalWindow:[NSApp keyWindow] target:self];    
}



@end
