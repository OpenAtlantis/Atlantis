//
//  RDAtlantisSpawn.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/8/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lemuria/Lemuria.h>
#import <Lemuria/RBSplitView.h>
#import "RDAtlantisWorldInstance.h"
#import "RDSpawnConfigRecord.h"
#import "ImageBackgroundView.h"

@interface RDAtlantisSpawn : NSObject <RDNestedViewDescriptor> {

    // View elements
    IBOutlet NSView     *        _rdSpawnContentView;
    IBOutlet RBSplitView*        _rdSplitView;
    IBOutlet RDTextView *        _rdOutputView;
    IBOutlet NSTextView *        _rdInputView;    

    IBOutlet NSTextField *       _rdTimerField;
    IBOutlet NSTextField *       _rdStatusField;
    IBOutlet ImageBackgroundView *_rdStatusBar;
    
    IBOutlet NSImageView *       _rdSSLImage;

    NSPanel             *        _rdResizeTooltip;
    NSTextField         *        _rdResizeTextfield;

    // NestedView data
    NSMutableArray      *        _rdSubviews;
    NSString            *        _rdPath;
    NSString            *        _rdName;
    NSString            *        _rdUID;
    NSString            *        _rdInternalPath;
    unsigned                     _rdWeight;
    
    int                          _rdScreenWidth;
    int                          _rdScreenHeight;
   
    // Atlantis world data
    RDAtlantisWorldInstance *   _rdWorld;
    NSFont                  *   _rdFont;
    unsigned                    _rdLines;   
    BOOL                        _rdDefaultsActive;
    NSArray                 *   _rdActiveExceptions;
    
    NSColor                 *   _rdBackgroundColor;
    NSColor                 *   _rdInputColor;
    NSColor                 *   _rdConsoleColor;
    
    NSString                *   _rdSpawnPrefix;
    
    NSImage                 *   _rdWorldIcon;
    
    BOOL                        _rdShowTimestamps;
    BOOL                        _rdHasText;
    BOOL                        _rdLastNewline;
    
    BOOL                        _rdStatusBarBottom;
}

- (id) initWithPath:(NSString *)path forInstance:(RDAtlantisWorldInstance *) instance withPrefs:(RDSpawnConfigRecord *)prefs;

- (void) setFont:(NSFont *) newFont;
- (void) setParagraphStyle:(NSParagraphStyle *) newParaStyle;
- (void) setLinkStyle:(NSDictionary *)linkAttrs;

- (void) updateStatusBar;
- (void) setStatusBarHidden:(BOOL) display;
- (BOOL) statusBarHidden;
- (void) setStatusBarBottom:(BOOL) bottom;
- (BOOL) statusBarBottom;
- (void) setStatusBarUserText:(NSAttributedString *)text;
- (NSString *) statusBarUserText;

- (void) appendString:(NSAttributedString *) string;
- (void) appendStringNoTimestamp:(NSAttributedString *) string;
- (void) ensureNewline;
- (void) stringIntoInput:(NSString *) string;
- (void) stringInsertIntoInput:(NSString *) string;
- (NSString *) stringFromInput;
- (NSString *) stringFromInputSelection;
- (NSString *) stringFromOutputSelection;
- (BOOL) wantsActiveFor:(NSString *) string;

- (void) setInternalPath:(NSString *)path;
- (NSString *) internalPath;

- (NSString *) prefix;
- (void) setPrefix:(NSString *)prefix;

- (void) clearSearchString:(id) sender;
- (void) searchForString:(id) sender;

- (RDAtlantisWorldInstance *) world;

- (NSArray *) scrollbackData;
- (int) screenWidth;
- (int) screenHeight;

- (void) clearScrollback;

@end
