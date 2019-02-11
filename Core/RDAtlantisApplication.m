//
//  RDAtlantisApplication.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/15/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDAtlantisApplication.h"
#import "RDAtlantisMainController.h"
#import "HotkeyCollection.h"
#import <Carbon/Carbon.h>
#import <Lemuria/Lemuria.h>

@implementation RDAtlantisApplication

- (id) init
{
    self = [super init];
    if (self) {
        _rdSpawnShortcut = FALSE;
    }
    return self;
}

- (void) shortcutSpawns:(BOOL) shortcutOn
{
    _rdSpawnShortcut = shortcutOn;
}

+ (BOOL) isTiger
{    
//    SInt32 MacVersion;
//    if (Gestalt(gestaltSystemVersion, &MacVersion) == noErr){
//        if (MacVersion >= 0x1040){
//            return YES;
//        }
//    }
//
    return YES;
}

- (long)cocoaModifiersAsCarbonModifiers: (long)cocoaModifiers
{
	static long cocoaToCarbon[6][2] =
	{
		{ NSCommandKeyMask, cmdKey},
		{ NSAlternateKeyMask, optionKey},
		{ NSControlKeyMask, controlKey},
		{ NSShiftKeyMask, shiftKey},
		{ NSFunctionKeyMask, rightControlKey},
		//{ NSAlphaShiftKeyMask, alphaLock }, //Ignore this?
	};

	long carbonModifiers = 0;
	int i;
	
	for( i = 0 ; i < 6; i++ )
		if( cocoaModifiers & cocoaToCarbon[i][0] )
			carbonModifiers += cocoaToCarbon[i][1];
	
	return carbonModifiers;
}

- (void) sendEvent:(NSEvent *)theEvent
{
    switch ([theEvent type]) {
    
        case NSKeyDown:
            {
                int keyCode = [theEvent keyCode];
                int modifiers = [self cocoaModifiersAsCarbonModifiers:[theEvent modifierFlags]];
                BOOL handled = NO;
                
                if ((keyCode == 48) && (modifiers == 4096)) {

                    NSWindow *window = [NSApp keyWindow];
                    if (window && [window isKindOfClass:[RDNestedViewWindow class]]) {
                        id <RDNestedViewDisplay> display = [(RDNestedViewWindow *)window displayView];
                        if (display) {
                            id <RDNestedViewDescriptor> nextView = [display nextView];
                            
                            if (nextView) {
                                handled = YES;
                                [[RDNestedViewManager manager] selectView:nextView];
                            }
                        }
                    }
                }                
                else if (_rdSpawnShortcut) {
                    NSWindow *window = [NSApp keyWindow];
                    if ((modifiers == cmdKey) && ([NSApp isActive] && [window isKindOfClass:[RDNestedViewWindow class]])) {
                        NSString *characters = [theEvent characters];
                        if (characters && ([characters length] == 1)) {
                            if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[characters characterAtIndex:0]]) {
                                handled = YES;
                            
                                int value = [characters intValue];
                                if (value == 0)
                                    value = 10;
                                    
                                RDNestedViewWindow *nestedWindow = (RDNestedViewWindow *)window;
                                
                                NSArray *array = [[[nestedWindow displayView] collection] realViewsFlattened];
                                if (array && ([array count] >= value)) {
                                    id <RDNestedViewDescriptor> view = [array objectAtIndex:(value - 1)];
                                    
                                    if (view) {
                                        [[RDNestedViewManager manager] selectView:view];
                                    }
                                    else
                                        NSBeep();
                                }
                                else
                                    NSBeep();
                            }
                        }
                    }
                }
                
                if (!handled) {
                    HotkeyCollection *hotkeys = [[RDAtlantisMainController controller] hotkeyBindings];
                
                    if ([hotkeys executeForKey:keyCode modifiers:modifiers])
                        handled = YES;
                }
                
                if (!handled) {
                    // Scripted hotkeys, whoo-ha!
                    handled = [[RDAtlantisMainController controller] fireScriptedEventsForKeycode:keyCode withModifiers:modifiers];                    
                }
                
                if (!handled) {
                    [super sendEvent:theEvent];
                }
            }
            break;
            
        default:
            [super sendEvent:theEvent];
            break;    
    }
}


@end
