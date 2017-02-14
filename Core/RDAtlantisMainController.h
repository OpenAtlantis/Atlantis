/* RDAtlantisMainController */

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@class HotkeyCollection;
@class ActionClasses;
@class ConditionClasses;
@class EventCollection;
@class RDAtlantisWorldInstance;
@class RDAtlantisWorldPreferences;
@class WorldCollection;
@class AddressBook;
@class AtlantisPreferenceController;
@protocol AtlantisPreferencePane;
@class BaseCommand;
@class RDMenuEvent;
@protocol ToolbarOption;
@class AtlantisAboutBox;
@class DockBadger;
@class ToolbarCollection;
@class MUSHTextEditor;
@class ScriptingDispatch;
@class ScriptingEngine;
@class MCPDispatch;
@class ToolbarWorldStatus;
@class CTBadge;
@class AtlantisState;

@interface RDAtlantisMainController : NSObject <GrowlApplicationBridgeDelegate>
{
    IBOutlet NSMenuItem*    _rdRenameMenuItem;
    IBOutlet NSMenuItem*    _rdCustomizeToolbarMenuItem;
    
    IBOutlet NSMenu *       _rdMainMenu;
    IBOutlet NSMenu *       _rdActiveSpawnsMenu;
    
    BOOL                    _rdNestedViewSelected;
    BOOL                    _rdStatusBarBottom;
    
    RDAtlantisWorldPreferences *_rdGlobalWorld;
    NSMutableDictionary     *_rdTempStateVars;
    
    NSMutableArray *        _rdInputFilters;
    NSMutableArray *        _rdLogTypes;
    NSMutableArray *        _rdUploaderTypes;
    ActionClasses  *        _rdActionTypes;
    ConditionClasses *      _rdConditionTypes;
    
    NSMutableArray *        _rdConfigTabClasses;
    
    NSMutableDictionary * _rdConnectedWorlds;
    
    NSMutableDictionary * _rdCommands;
    
    NSMutableDictionary * _rdToolbarOptions;
    
    NSMutableArray      * _rdScriptedEvents;
    
    HotkeyCollection *    _rdHotkeys;
    ToolbarCollection *   _rdToolbarEvents;
    
    WorldCollection *     _rdWorlds;
    AddressBook *         _rdAddressBook;
    
    AtlantisPreferenceController *  _rdPreferenceWindow;
    
    NSTimer              *_rdEventTimer;
    
    AtlantisAboutBox     *_rdAboutBox;
    
    CTBadge           *_rdBadger;    // MUSHROOM, MUSHROOM!
    MUSHTextEditor       *_rdTextEditor;// Many happy hours of descing ahead...
    
    MCPDispatch          *_rdMcpDispatch;
    
    NSMutableDictionary  *_rdSessionStateItems;
    ScriptingDispatch    *_rdScriptSystem;
}

+ (RDAtlantisMainController *) controller;
+ (BOOL) networkAvailable;

- (IBAction)renameWindow:(id)sender;
- (IBAction)customizeToolbar:(id)sender;
- (IBAction)aboutBox:(id) sender;
- (IBAction)addressBook:(id)sender;
- (IBAction)launchDocWiki:(id)sender;
- (void) openPrefsForWorld:(RDAtlantisWorldPreferences *)world onCharacter:(NSString *)character;

- (IBAction)openPreferences:(id) sender;
- (void) addressBookClosed;

- (IBAction)focusSpawn:(id) sender;

- (IBAction)checkForUpdates:(id) sender;

- (void) refreshBadge;
- (void) openMushEditorForWorld:(RDAtlantisWorldInstance *)world;

- (void) connectTemporaryWorld:(NSString *)hostname port:(int) port mush:(BOOL) isMush;

- (RDAtlantisWorldInstance *) connectedWorld:(NSString *)name;
- (void) addWorld:(RDAtlantisWorldInstance *) world;
- (void) removeWorld:(RDAtlantisWorldInstance *) world;
- (BOOL) worldsAreConnected;
- (void) reconnectAllNeeded;
- (void) markAndDisconnectAll:(NSString *) reason;
- (NSEnumerator *) worldWalk;
- (void) disconnectAllWorlds;
- (void) disconnectAllWorldsWithoutRemoving;

- (AtlantisState *) stateForSession:(NSString *) sessionUID;
- (void) finishedSession:(NSString *)sessionUID;
- (void) addState:(AtlantisState*)state forSession:(NSString *) sessionUID;

- (HotkeyCollection *) hotkeyBindings;
- (ToolbarCollection *) toolbarUserEvents;

- (NSArray *) inputFilters;
- (NSArray *) logTypes;
- (NSArray *) uploaderTypes;

- (NSArray *) configTabs;

- (WorldCollection *) worlds;

- (RDAtlantisWorldPreferences *) globalWorld;
- (NSArray *) globalEvents;
- (NSArray *) globalHighlights;
- (NSArray *) globalAliases;

- (NSDictionary *) tempStateVars;
- (NSString *) tempStateVarForKey:(NSString *)key;
- (void) setStateVar:(NSString *) variable forKey:(NSString *)key;

- (ScriptingDispatch *) scriptDispatch;
- (MCPDispatch *) mcpDispatch;

- (void) addInputFilter:(Class) filterClass;
- (void) addLogfileType:(Class) logfileClass;
- (void) addUploaderType:(Class) uploaderClass;

- (void) addConditionClass:(Class) conditionClass;
- (void) addActionClass:(Class) actionClass;

- (void) addConfigTabClass:(Class) configClass;

- (void) addToolbarOption:(id <ToolbarOption>) option;

- (void) addPreferencePane:(id <AtlantisPreferencePane>) pane;

- (void) addScriptingEngine:(ScriptingEngine *)engine;

- (void) addCommand:(BaseCommand *) command forText:(NSString *)text;
- (BaseCommand *) commandForText:(NSString *) command;

- (void) addMenuEvent:(RDMenuEvent *)event toMenu:(NSString *)menu withTitle:(NSString *)title;
- (void) addMenuEvent:(RDMenuEvent *)event toMenu:(NSString *)menu inSubMenu:(NSString *)subMenu withTitle:(NSString *)title;
- (void) addDividerToMenu:(NSString *)menu;
- (void) addDividerToMenu:(NSString *)menu inSubMenu:(NSString *)submenu;

- (ActionClasses *) eventActions;
- (ConditionClasses *) eventConditions;

- (void) loadKeyBindings;
- (void) saveKeyBindings;

- (void) loadToolbarEvents;
- (void) saveToolbarEvents;

- (void) loadGlobals;
- (void) saveGlobals;

- (void) loadWorlds;
- (void) saveWorlds;
- (void) saveDirtyWorlds;
- (void) saveWorld:(RDAtlantisWorldPreferences *)world;

- (BOOL) growlEnabled;

- (BOOL) statusBarBottom;
- (void) setStatusBarBottom:(BOOL)bottom;

- (void) addScriptEvent:(NSString *)function inLanguage:(NSString *)language forType:(NSString *)eventType withWorld:(NSString *)world;
- (void) addScriptPattern:(NSString *)pattern withFunction:(NSString *)function inLanguage:(NSString *)language withWorld:(NSString *)world;
- (void) addScriptAlias:(NSString *)alias forFunction:(NSString *)function inLanguage:(NSString *)language withWorld:(NSString *)world;
- (void) addScriptHotkey:(int)keycode modifiers:(int)modifiers globally:(BOOL)registerGlobally forFunction:(NSString *)function inLanguage:(NSString *)language withWorld:(NSString *)world;
- (void) addScriptTimer:(NSString *)function inLanguage:(NSString *)language withWorld:(NSString *)world withInterval:(NSTimeInterval)seconds repeats:(int)repeats;
- (void) removeAllScriptedEventsForLanguage:(NSString *)language;
- (BOOL) fireScriptedEventsForState:(AtlantisState *)state;
- (BOOL) fireScriptedEventsForAlias:(NSString *)alias withState:(AtlantisState *)state;
- (BOOL) fireScriptedEventsForKeycode:(int)keycode withModifiers:(int)modifiers;

@end
