#import <Lemuria/Lemuria.h>
//#import <DTCVersionManager/DTCVersionManager.h>
#import <SystemConfiguration/SystemConfiguration.h>
//#import <CamelBones/CamelBones.h>
#import <OgreKit/OgreKit.h>
#import "RDAtlantisMainController.h"
//#include "BugReporter.h"
#import "NSDictionary+XMLPersistence.h"

#import "ToolbarCollection.h"
#import "ToolbarUserEvent.h"

#import "HotkeyCollection.h"
#import "HotkeyEvent.h"
#import "ActionClasses.h"
#import "ConditionClasses.h"

#import "RDAnsiFilter.h"
#import "RDCompressionFilter.h"
#import "RDTelnetFilter.h"
#import "RDURLFilter.h"
#import "RDEmailFilter.h"
#import "RDMCPFilter.h"

#import "RDFormattedText.h"
#import "RDPlainText.h"
#import "RDHTMLLog.h"

#import "Actions.h"
#import "Conditions.h"

#import "HighlightEvent.h"
#import "WorldEvent.h"

#import "PTKeyCombo.h"
#import "RDAtlantisSpawn.h"
#import "RDSpawnConfigRecord.h"

#import "WorldMainEditor.h"
#import "WorldInfoEditor.h"
#import "WorldFormattingEditor.h"
#import "WorldHighlightEditor.h"
#import "WorldSpawnEditor.h"
#import "WorldEventEditor.h"
#import "WorldAliasEditor.h"
#import "WorldUserconfEditor.h"

#import "WorldConfigurationEditor.h"
#import "WorldCollection.h"
#import "AddressBook.h"

#import "RenameWindowPanel.h"

#import "AtlantisPreferenceController.h"
#import "WorldDefaults.h"
#import "HotkeyPreferences.h"
#import "ToolbarEventPreferences.h"
#import "GeneralPreferences.h"
#import "WindowingPreferences.h"
#import "NetworkPreferences.h"

#import "GrabCommand.h"
#import "GrabNameCommand.h"
#import "StackedCommand.h"
#import "UlCommand.h"
#import "QuoteCommand.h"
#import "ClearCommand.h"
#import "QuickConnectCommand.h"
#import "WaitCommand.h"
#import "LogsCommand.h"

#import "TextfileUploader.h"
#import "CodeUploader.h"

#import "ToolbarOption.h"
#import "ToolbarConnect.h"
#import "ToolbarConnection.h"
#import "ToolbarDisconnect.h"
#import "ToolbarSearch.h"
#import "ToolbarAddressBook.h"
#import "ToolbarWorldStatus.h"

#import "AtlantisState.h"
#import "MenuEvent.h"

#import "AtlantisAboutBox.h"
#import "RDAtlantisApplication.h"
#import "DockBadger.h"
#import "MUSHTextEditor.h"

#import "ScriptingDispatch.h"
#import "ScriptingEngine.h"
#import "PerlScriptingEngine.h"
#import "LuaScriptingEngine.h"

#import "MCPDispatch.h"
#import "MCPHandler.h"
#import "MCPNegotiateHandler.h"
#import "MCPEditHandler.h"
#import "MCPVMooClient.h"
#import "MCPIcecrewServer.h"

#import "CTBadge.h"

#import "ScriptEventAction.h"

static RDAtlantisMainController *s_rdController = nil;

static SCNetworkReachabilityRef s_reachabilityRef = nil;

@interface RDAtlantisMainController (Private)
- (void) setDefaultKeyBindings;
- (void) setDefaultGlobals;
- (void) saveAllData;

- (void) activityForSpawn:(NSNotification *)notification;
- (void) noActivityForSpawn:(NSNotification *)notification;
- (void) computerWillSleep:(NSNotification *)notification;
- (void) computerWillShutdown:(NSNotification *)notification;

- (void) eventsTimerFired:(NSTimer *)timer;

- (void) appBecameActive:(NSNotification *)notification;
- (void) appBecameInactive:(NSNotification *)notification;

@end

@implementation RDAtlantisMainController

#pragma mark Initialization

+ (RDAtlantisMainController *) controller
{
    return s_rdController;
}

+ (BOOL) networkAvailable
{
    SCNetworkConnectionFlags flags;
    SCNetworkReachabilityGetFlags(s_reachabilityRef, &flags);

    return ((flags & kSCNetworkFlagsReachable) && (!(flags & kSCNetworkFlagsConnectionRequired) || (flags & kSCNetworkFlagsConnectionAutomatic)));
}

static void networkReachabilityChangedCallback(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void *info)
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.network.drop"]) {
        if ([RDAtlantisMainController networkAvailable]) {
            [[RDAtlantisMainController controller] reconnectAllNeeded];
        }
        else {
            [[RDAtlantisMainController controller] markAndDisconnectAll:@"Network connection lost."];
        }
    }
}

- (void) computerWillSleep:(NSNotification *) notification
{
    [self saveDirtyWorlds];
    [self markAndDisconnectAll:@"Computer going to sleep."];
}

- (void) computerWillShutdown:(NSNotification *) notification
{
    [self saveAllData];
    [self markAndDisconnectAll:@"System shutting down."];
    [NSApp terminate:self];
}


- (void) awakeFromNib
{
//    NSString *bugReporterPropertyList;
//    NSString *bugReporterPropertyListFilename;
//
//    bugReporterPropertyListFilename = [[NSBundle mainBundle] pathForResource:@"bugreporter" ofType:@"plist"];
//    if (bugReporterPropertyListFilename) {
//        bugReporterPropertyList = [NSString stringWithContentsOfFile:bugReporterPropertyListFilename];
//        if (bugReporterPropertyList) {
//            BRStatus theErr;
//            theErr = EnableBugReporter((CFStringRef)bugReporterPropertyList);
//            if (theErr != kBRNoErr)
//                exit(theErr);
//        }
//    }
//
    [NSApp setDelegate:self];
}

- (void) applicationDidFinishLaunching:(NSNotification *)notification
{
#ifndef _ATLANTIS_DEBUG
    [_rdWorlds doAutoconnects];
#endif
    
    if (![_rdConnectedWorlds count]) {
        BOOL openAddressBook = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.startup.openBook"];
        if (openAddressBook)
            [self addressBook:self];
    }
}

- (void) application:(NSApplication *)app openFile:(NSString *)filename
{
    
    if ([[[filename pathExtension] lowercaseString] isEqualToString:@"axworld"]) {    
        RDAtlantisWorldPreferences *newPref = [_rdWorlds importWorldXML:filename];
        if (newPref) {
            [_rdAddressBook refreshWorldCollection];
            [_rdAddressBook focusWorld:newPref forCharacter:nil];
        }
    }
    else {
        NSDictionary *testMe = [NSDictionary dictionaryWithContentsOfXMLFile:filename];
        NSArray *keys = [testMe allKeys];
        if (keys && ([keys count] == 1)) {
            NSString *testKey = [keys objectAtIndex:0];
            NSArray *pieces = [testKey componentsSeparatedByString:@" "];
            NSString *testString = [[pieces objectAtIndex:0] lowercaseString];
            if ([testString isEqualToString:@"doctype"]) {
                testMe = [testMe objectForKey:testKey];
                keys = [testMe allKeys];
                testKey = [keys objectAtIndex:0];
                pieces = [testKey componentsSeparatedByString:@" "];
                testString = [[pieces objectAtIndex:0] lowercaseString];
            }
            
            if ([testString isEqualToString:@"world"]) {
                RDAtlantisWorldPreferences *newPref = [_rdWorlds importWorldXML:filename];
                if (newPref) {
                    [_rdAddressBook refreshWorldCollection];
                    [_rdAddressBook focusWorld:newPref forCharacter:nil];
                }
            }
            else if ([testString isEqualToString:@"shortcut"]) {
                NSDictionary *shortcut = [testMe objectForKey:testKey];
                NSString *worldUUID = [shortcut objectForKey:@"world"];
                NSString *charUUID = [shortcut objectForKey:@"character"];
                
                if (worldUUID) {
                    RDAtlantisWorldPreferences *pref = [_rdWorlds worldForUUID:worldUUID];
                    if (pref) {
                        NSString *character = nil;
                        if (charUUID) {
                            NSArray *charArray = [pref characters];
                            NSEnumerator *charEnum = [charArray objectEnumerator];
                            NSString *charwalk;
                            
                            while (charwalk = [charEnum nextObject]) {
                                if ([[pref uuidForCharacter:charwalk] isEqualToString:charUUID]) {
                                    character = charwalk;
                                }
                            }
                        }
                        
                        RDAtlantisWorldInstance *charInstance =                        
                            [[RDAtlantisWorldInstance alloc] initWithWorld:pref forCharacter:character withBasePath:[pref basePathForCharacter:character]];
                            
                        [charInstance connect];
                    }
                }
            }
        }
    }
}

- (void) application:(NSApplication *)app openFiles:(NSArray *)filenames
{
    NSEnumerator *fileEnum = [filenames objectEnumerator];
    NSString *filename;
    
    while (filename = [fileEnum nextObject]) {
        [self application:app openFile:filename];
    }
}

- (void) applicationWillFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameActive:) name:@"NSApplicationDidBecomeActiveNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameInactive:) name:@"NSApplicationDidResignActiveNotification" object:nil];

    NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    int lastVersion = [[NSUserDefaults standardUserDefaults] integerForKey:@"RDAtlantisVersion"];
    if (lastVersion == 0) {
        NSString *atlantisPlistFile = @"~/Library/Preferences/net.riverdark.Atlantis.plist";
        [NSUserDefaults resetStandardUserDefaults];
        [[NSFileManager defaultManager] removeFileAtPath:[atlantisPlistFile stringByExpandingTildeInPath] handler:NULL];
    }
    
    if (lastVersion < 65) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"atlantis.network.drop"];
    }
    if (lastVersion < 71) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"atlantis.network.compress"];
    }
    if (lastVersion < 78) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"atlantis.startup.openBook"];
    }
    if (lastVersion < 86) {
        NSString *lemuriaStyle = [[NSUserDefaults standardUserDefaults] objectForKey:@"lemuria.display.style"];
        if (lemuriaStyle && [lemuriaStyle isEqualToString:@"outline"])
            [[NSUserDefaults standardUserDefaults] setObject:@"source" forKey:@"lemuria.display.style"];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:[bundleVersion intValue] forKey:@"RDAtlantisVersion"];
    
    _rdStatusBarBottom = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.statusbar.bottom"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecameKey:) name:@"NSWindowDidBecomeKeyNotification" object:nil];
    _rdNestedViewSelected = NO;
    s_rdController = self;
    _rdInputFilters = [[[NSMutableArray alloc] init] retain];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityForSpawn:) name:@"RDLemuriaHasNewActivityNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noActivityForSpawn:) name:@"RDLemuriaHasNoActivityNotification" object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(computerWillSleep:) name:NSWorkspaceWillSleepNotification object:[NSWorkspace sharedWorkspace]];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(computerWillShutdown:) name:NSWorkspaceWillPowerOffNotification object:[NSWorkspace sharedWorkspace]];

    // TODO: Change Growl configuration stuff to work a little more nicely?
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    // Create hotkey collection
    _rdSessionStateItems = [[NSMutableDictionary alloc] init];
    _rdHotkeys = [[HotkeyCollection alloc] init];
    _rdActionTypes = [[ActionClasses alloc] init];
    _rdConditionTypes = [[ConditionClasses alloc] init];
    _rdConfigTabClasses = [[NSMutableArray alloc] init];
    _rdLogTypes = [[NSMutableArray alloc] init];
    _rdUploaderTypes = [[NSMutableArray alloc] init];
    _rdWorlds = [[WorldCollection alloc] init];
    _rdConnectedWorlds = [[NSMutableDictionary alloc] init];
    _rdCommands = [[NSMutableDictionary alloc] init];
    _rdToolbarOptions = [[NSMutableDictionary alloc] init];
    _rdToolbarEvents = [[ToolbarCollection alloc] init];
    _rdAddressBook = nil;
    _rdPreferenceWindow = [[AtlantisPreferenceController alloc] init];
    _rdScriptSystem = [[ScriptingDispatch alloc] init];
    _rdTempStateVars = [[NSMutableDictionary alloc] init];
    _rdMcpDispatch = [[MCPDispatch alloc] init];
    
    MCPNegotiateHandler *mcpNegotiate = [[MCPNegotiateHandler alloc] init];
    MCPEditHandler *mcpEditor = [[MCPEditHandler alloc] init];
    MCPVMooClient *mcpClient = [[MCPVMooClient alloc] init];
	MCPIcecrewServer *mcpIcecrew = [[MCPIcecrewServer alloc] init];
    [_rdMcpDispatch registerHandler:mcpNegotiate forNamespace:@"mcp-negotiate"];
    [_rdMcpDispatch registerHandler:mcpEditor forNamespace:@"dns-org-mud-moo-simpleedit"];
    [_rdMcpDispatch registerHandler:mcpClient forNamespace:@"dns-nl-vmoo-client"];
    [_rdMcpDispatch registerHandler:mcpClient forNamespace:@"dns-nl-vgmoo-client"];
    [_rdMcpDispatch registerHandler:mcpClient forNamespace:@"dns-com-vmoo-client"];
	[_rdMcpDispatch registerHandler:mcpIcecrew forNamespace:@"dns-nl-icecrew-serverinfo"];
    
    [_rdMcpDispatch registerHandler:[[[MCPHandler alloc] init] autorelease] forNamespace:@"mcp"];
    [mcpNegotiate autorelease];
    [mcpEditor autorelease];
    [mcpClient autorelease];

    _rdScriptedEvents = [[NSMutableArray alloc] init];

    [self addScriptingEngine:[[PerlScriptingEngine alloc] init]];
    [self addScriptingEngine:[[LuaScriptingEngine alloc] init]];

    [self addInputFilter:[RDCompressionFilter class]];
    [self addInputFilter:[RDAnsiFilter class]];
    [self addInputFilter:[RDTelnetFilter class]];
    [self addInputFilter:[RDMCPFilter class]];
    [self addInputFilter:[RDURLFilter class]];
    [self addInputFilter:[RDEmailFilter class]];

    [self addLogfileType:[RDPlainText class]];
    [self addLogfileType:[RDFormattedText class]];
    [self addLogfileType:[RDHTMLLog class]];
    
    [self addUploaderType:[TextfileUploader class]];
    [self addUploaderType:[CodeUploader class]];
    
    [self addToolbarOption:[[ToolbarConnection alloc] init]];
    [self addToolbarOption:[[ToolbarConnect alloc] init]];
    [self addToolbarOption:[[ToolbarDisconnect alloc] init]];
    [self addToolbarOption:[[ToolbarSearch alloc] init]];
    [self addToolbarOption:[[ToolbarAddressBook alloc] init]];
    [self addToolbarOption:[[ToolbarWorldStatus alloc] init]];

    [self addActionClass:[Action_AddressBook class]];
    [self addActionClass:[Action_AddressBookWorld class]];
    if ([self growlEnabled])
        [self addActionClass:[Action_Growl class]];
    [self addActionClass:[Action_DockBounce class]];
    [self addActionClass:[Action_HistoryNext class]];
    [self addActionClass:[Action_HistoryPrev class]];
    [self addActionClass:[Action_InputClear class]];
    [self addActionClass:[Action_InputCopy class]];
    [self addActionClass:[Action_InputConvertToMUSH class]];
    [self addActionClass:[Action_InputConvertFromMUSH class]];
    [self addActionClass:[Action_InputToHistory class]];
    [self addActionClass:[Action_LineClass class]];
    [self addActionClass:[Action_LogpanelClose class]];
    [self addActionClass:[Action_LogpanelOpen class]];
    [self addActionClass:[Action_NextSpawn class]];
    [self addActionClass:[Action_NextWorld class]];
    [self addActionClass:[Action_OutputCopy class]];
    [self addActionClass:[Action_OutputCopyInput class]];
    [self addActionClass:[Action_PrevWorld class]];
    [self addActionClass:[Action_SoundPlay class]];
    [self addActionClass:[Action_SpawnClose class]];
    [self addActionClass:[Action_SpawnFocus class]];
    [self addActionClass:[Action_StatusSend class]];
    [self addActionClass:[Action_TextHighlight class]];
    [self addActionClass:[Action_TextOmitActivity class]];
    [self addActionClass:[Action_TextOmitLog class]];
    [self addActionClass:[Action_TextOmitScreen class]];
    [self addActionClass:[Action_TextSpawn class]];
    [self addActionClass:[Action_TextSpeak class]];
    [self addActionClass:[Action_ToggleSpawnList class]];
    [self addActionClass:[Action_WindowClose class]];
    [self addActionClass:[Action_WorldDisconnect class]];
    [self addActionClass:[Action_WorldReconnect class]];
    [self addActionClass:[Action_WorldSend class]];
    
    [self addActionClass:[Action_CloseLogs class]];
    [self addActionClass:[Action_OpenLog class]];
    [self addActionClass:[Action_GlobalDisconnect class]];
    [self addActionClass:[Action_GlobalReconnect class]];
    [self addActionClass:[Action_UploadpanelOpen class]];
    
    [self addActionClass:[Action_OpenTextEditor class]];
    
    [self addActionClass:[Action_LastCommand class]];
    
    [self addActionClass:[Action_EatLinefeeds class]];
    [self addActionClass:[Action_PerlEval class]];
    
    [self addActionClass:[Action_SetTempVar class]];
    
    [self addActionClass:[Action_CloseFocused class]];
    
    [self addActionClass:[Action_ToggleDrag class]];
    [self addActionClass:[Action_ClearScreen class]];
    [self addActionClass:[Action_ClearSpawn class]];    
    [self addActionClass:[Action_StatusBarDisplay class]];
    [self addActionClass:[Action_Beep class]];
    
    [self addActionClass:[Action_Substitute class]];

    [self addActionClass:[Action_WorldNotesShow class]];
    [self addActionClass:[Action_ShrinkURL class]];

    [self addActionClass:[Action_SpawnPrefix class]];

    [self addConditionClass:[Condition_AtlantisFocus class]];
    [self addConditionClass:[Condition_AtlantisVisible class]];
    [self addConditionClass:[Condition_CharConnected class]];
    [self addConditionClass:[Condition_CollectedConditions class]];
    [self addConditionClass:[Condition_ComputerIdle class]];
    [self addConditionClass:[Condition_LineClass class]];
    [self addConditionClass:[Condition_HasRealWorld class]];
    [self addConditionClass:[Condition_HasWorld class]];
    [self addConditionClass:[Condition_Negate class]];
    [self addConditionClass:[Condition_SpawnActivity class]];
    [self addConditionClass:[Condition_StringMatch class]];
    [self addConditionClass:[Condition_Timer class]];
    [self addConditionClass:[Condition_VariableMatch class]];
    [self addConditionClass:[Condition_ViewActive class]];
    [self addConditionClass:[Condition_ViewName class]];
    [self addConditionClass:[Condition_WorldConnected class]];
    [self addConditionClass:[Condition_WorldDisconnected class]];
    [self addConditionClass:[Condition_WorldOpened class]];
    [self addConditionClass:[Condition_WorldClosed class]];
    [self addConditionClass:[Condition_WorldHasLogs class]];
    [self addConditionClass:[Condition_WorldIdle class]];
    [self addConditionClass:[Condition_WorldIsMUSH class]];
    [self addConditionClass:[Condition_WorldIsConnected class]];
    [self addConditionClass:[Condition_WorldIsDisconnected class]];    
        
    [self addConfigTabClass:[WorldMainEditor class]];
    [self addConfigTabClass:[WorldInfoEditor class]];
    [self addConfigTabClass:[WorldFormattingEditor class]];
    [self addConfigTabClass:[WorldHighlightEditor class]];
    [self addConfigTabClass:[WorldSpawnEditor class]];
    [self addConfigTabClass:[WorldEventEditor class]];
    [self addConfigTabClass:[WorldAliasEditor class]];
    [self addConfigTabClass:[WorldUserconfEditor class]];
    
    [self addCommand:[[GrabCommand alloc] init] forText:@"grab"];
    [self addCommand:[[StackedCommand alloc] init] forText:@"sc"];
    [self addCommand:[[UlCommand alloc] init] forText:@"ul"];
    [self addCommand:[[QuoteCommand alloc] init] forText:@"quote"];
    [self addCommand:[[ClearCommand alloc] init] forText:@"clear"];
    [self addCommand:[[QuickConnectCommand alloc] init] forText:@"qc"];
    [self addCommand:[[GrabNameCommand alloc] init] forText:@"gname"];
    [self addCommand:[[WaitCommand alloc] init] forText:@"wait"];
    [self addCommand:[[LogsCommand alloc] init] forText:@"logs"];
    
    [NSApp setDelegate:self];
    [[RDNestedViewManager manager] setDelegate:self];

    // Load things
    [self loadKeyBindings];
    [self loadGlobals];
    [self loadToolbarEvents];
    [self loadWorlds];
        
    [self addPreferencePane:[[GeneralPreferences alloc] init]];
    [self addPreferencePane:[[NetworkPreferences alloc] init]];
    [self addPreferencePane:[[WorldDefaults alloc] init]];
    [self addPreferencePane:[[HotkeyPreferences alloc] initForCollection:_rdHotkeys]];
    [self addPreferencePane:[[ToolbarEventPreferences alloc] initForEvents:_rdToolbarEvents]];
    [self addPreferencePane:[[WindowingPreferences alloc] init]];
    
    // Set up default menu goo
//    RDMenuEvent *menuEvent = [[RDMenuEvent alloc] init];
//    [menuEvent eventAddAction:[[Action_AddressBook alloc] init]];
//    [self addMenuEvent:menuEvent toMenu:@"World" withTitle:@"Address Book..."];
  
    
    NSMenuItem *worldMenu = [_rdMainMenu itemWithTitle:@"World"];
    if (!worldMenu) {
        worldMenu = [[NSMenuItem alloc] initWithTitle:@"World" action:@selector(executeMenuItem:) keyEquivalent:@""];
        NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"World"];
        [worldMenu setSubmenu:subMenu];
        [_rdMainMenu insertItem:worldMenu atIndex:3];
    }
    NSMenuItem *worldList = [[NSMenuItem alloc] initWithTitle:@"Address Book" action:@selector(executeMenuItem:) keyEquivalent:@""];
    [worldList setSubmenu:[[[RDAtlantisMainController controller] worlds] worldMenu]];
    [[worldMenu submenu] addItem:worldList];
            
    [self addDividerToMenu:@"World"];

    [self addDividerToMenu:@"Edit"];
    RDMenuEvent * menuEvent = [[RDMenuEvent alloc] init];
    [menuEvent eventAddCondition:[[Condition_WorldIsMUSH alloc] init]];
    [menuEvent eventAddAction:[[Action_OpenTextEditor alloc] init]];
    [self addMenuEvent:menuEvent toMenu:@"Edit" inSubMenu:@"MUSH" withTitle:@"Open MUSH ANSI Text Editor..."];

    menuEvent = [[RDMenuEvent alloc] init];
    [menuEvent eventAddCondition:[[Condition_WorldIsMUSH alloc] init]];
    [menuEvent eventAddAction:[[Action_InputConvertToMUSH alloc] init]];
    [self addMenuEvent:menuEvent toMenu:@"Edit" inSubMenu:@"MUSH" withTitle:@"Convert Input to MUSH Format"];

    menuEvent = [[RDMenuEvent alloc] init];
    [menuEvent eventAddCondition:[[Condition_WorldIsMUSH alloc] init]];
    [menuEvent eventAddAction:[[Action_InputConvertFromMUSH alloc] init]];
    [self addMenuEvent:menuEvent toMenu:@"Edit" inSubMenu:@"MUSH" withTitle:@"Convert Input from MUSH Format"];
    
    menuEvent = [[RDMenuEvent alloc] init];
    [menuEvent eventAddCondition:[[Condition_HasWorld alloc] init]];
    [menuEvent eventAddAction:[[Action_WorldReconnect alloc] init]];
    [self addMenuEvent:menuEvent toMenu:@"World" withTitle:@"Reconnect"];

    menuEvent = [[RDMenuEvent alloc] init];
    [menuEvent eventAddCondition:[[Condition_HasWorld alloc] init]];
    [menuEvent eventAddAction:[[Action_WorldDisconnect alloc] init]];
    [self addMenuEvent:menuEvent toMenu:@"World" withTitle:@"Disconnect"];    

    [self addDividerToMenu:@"World"];
    menuEvent = [[RDMenuEvent alloc] init];
    [menuEvent eventAddCondition:[[Condition_HasRealWorld alloc] init]];
    [menuEvent eventAddAction:[[Action_AddressBookWorld alloc] init]];
    [self addMenuEvent:menuEvent toMenu:@"World" withTitle:@"Edit current world settings..."];

    menuEvent = [[RDMenuEvent alloc] init];
    [menuEvent eventAddCondition:[[Condition_HasRealWorld alloc] init]];
    [menuEvent eventAddAction:[[Action_WorldNotesShow alloc] init]];
    [self addMenuEvent:menuEvent toMenu:@"World" withTitle:@"Display world scratchpad..."];

    menuEvent = [[RDMenuEvent alloc] init];
    [menuEvent eventAddCondition:[[Condition_HasWorld alloc] init]];
    [menuEvent eventAddAction:[[Action_LogpanelOpen alloc] init]];
    [self addMenuEvent:menuEvent toMenu:@"Logs" withTitle:@"Open Log..."];

    menuEvent = [[RDMenuEvent alloc] init];
    [menuEvent eventAddCondition:[[Condition_HasWorld alloc] init]];
    [menuEvent eventAddCondition:[[Condition_WorldHasLogs alloc] init]];
    [menuEvent eventSetConditionsAnded:YES];
    [menuEvent eventAddAction:[[Action_LogpanelClose alloc] init]];
    [self addMenuEvent:menuEvent toMenu:@"Logs" withTitle:@"Close Log..."];

    [self addDividerToMenu:@"Logs"];

    menuEvent = [[RDMenuEvent alloc] init];
    [menuEvent eventAddCondition:[[Condition_HasWorld alloc] init]];
    [menuEvent eventAddAction:[[Action_UploadpanelOpen alloc] init]];
    [self addMenuEvent:menuEvent toMenu:@"Logs" withTitle:@"Upload File..."];


//    BOOL skipCheck = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.update.skipcheck"];
//
//    if (!skipCheck) {
//        [DTCVersionManager checkVersionAt:@"http://www.riverdark.net/atlantis/atlantis_versions.plist"
//                      withProductPage:@"http://www.riverdark.net/atlantis/downloads/"
//                     andApplyToWindow:nil
//                           showAlerts:NO];
//    }
//
    SCNetworkReachabilityContext reachabilityContext = {
                .version = 0,
                .info = NULL,
                .release = NULL,
                .copyDescription = NULL
        };

    s_reachabilityRef = SCNetworkReachabilityCreateWithName(NULL,"www.google.com");
        
    SCNetworkReachabilitySetCallback(s_reachabilityRef, networkReachabilityChangedCallback, &reachabilityContext);
    SCNetworkReachabilityScheduleWithRunLoop(s_reachabilityRef,CFRunLoopGetCurrent(),kCFRunLoopDefaultMode);
                           
    _rdEventTimer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(eventsTimerFired:) userInfo:nil repeats:YES] retain];    
    
    _rdAboutBox = [[[AtlantisAboutBox alloc] init] retain];
    _rdBadger = [[CTBadge systemBadge] retain];
    
    _rdTextEditor = [[MUSHTextEditor alloc] init];
    
    [(RDAtlantisApplication *)NSApp shortcutSpawns:[[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.shortcut.spawns"]];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self saveAllData];

    [_rdMcpDispatch release];

    [_rdTempStateVars release];

    [_rdTextEditor release];
    [_rdBadger release];
    [_rdAboutBox release];

    [_rdEventTimer invalidate];
    [_rdEventTimer release];

    [_rdConnectedWorlds release];
    
    [_rdSessionStateItems release];
    
    [_rdHotkeys release];
    [_rdAddressBook release];
    
    [_rdCommands release];
    [_rdToolbarEvents release];
    [_rdToolbarOptions release];

    [_rdInputFilters release];
    [_rdLogTypes release];
    [_rdUploaderTypes release];
    [_rdActionTypes release];
    [_rdConditionTypes release];
    [_rdConfigTabClasses release];

    [_rdPreferenceWindow release];

    [_rdScriptSystem release];
    [_rdScriptedEvents release];

    [super dealloc];
//    
//    DisableBugReporter();
}

#pragma mark Notification

- (void) windowBecameKey:(NSNotification *) notification
{
    NSWindow *window = [notification object];    
    _rdNestedViewSelected = [window isKindOfClass:[RDNestedViewWindow class]];
}

#pragma mark Validation

- (AtlantisState *) generateStateForCause:(NSString *)cause subcause:(id)subcause
{
    RDAtlantisWorldInstance *world = nil;
    RDAtlantisSpawn *spawn = nil;
    
    id <RDNestedViewDescriptor> curView = [[RDNestedViewManager manager] currentFocusedView];

    if (curView && [(NSObject *)curView isKindOfClass:[RDAtlantisSpawn class]]) {
        spawn = (RDAtlantisSpawn *)curView;
    }
    
    if (spawn) {
        world = [spawn world];
    }
    
    AtlantisState *state;
    
    if ([cause isEqualToString:@"line"])
        state = [[AtlantisState alloc] initWithString:(NSMutableAttributedString*)subcause inWorld:world forSpawn:spawn];
    else
        state = [[AtlantisState alloc] initWithString:nil inWorld:world forSpawn:spawn];
    
    [state setExtraData:[NSString stringWithString:cause] forKey:@"event.cause"];
    if ([cause isEqualToString:@"line"]) {
        [state setExtraData:[NSString stringWithString:[subcause string]] forKey:@"event.line"];
    }
    else if ([cause isEqualToString:@"statechange"]) {
        [state setExtraData:[NSString stringWithString:[subcause string]] forKey:@"event.statechange"];
    }
    else if ([cause isEqualToString:@"toolbar"]) {
        [state setExtraData:[NSString stringWithString:[subcause string]] forKey:@"toolbar.windowUID"];
    }
    
    return state;
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    if (item == _rdRenameMenuItem) {
        return _rdNestedViewSelected;
    }
    else if (item == _rdCustomizeToolbarMenuItem) {
        return _rdNestedViewSelected;
    }
    else {
        id menuObject = [item representedObject];
        
        if (menuObject && [menuObject isKindOfClass:[RDMenuEvent class]]) {
            RDMenuEvent *menuEvent = (RDMenuEvent *)menuObject;
            
            AtlantisState *state = [self generateStateForCause:@"menu" subcause:nil];
        
            BOOL result = [menuEvent shouldExecute:state];
            [state release];
            
            return result;
        }
        else 
            return YES;
    }
    
    return YES;
}

- (void) executeMenuItem:(id) sender
{
    id menuObject = [sender representedObject];
    
    if (menuObject && [menuObject isKindOfClass:[RDMenuEvent class]]) {
        RDMenuEvent *menuEvent = (RDMenuEvent *)menuObject;
        
        AtlantisState *state = [self generateStateForCause:@"menu" subcause:nil];
        
        return [menuEvent executeForState:state];
    }
}

- (void) addMenuEvent:(RDMenuEvent *)event toMenu:(NSString *)menu withTitle:(NSString *)title
{
    [self addMenuEvent:event toMenu:menu inSubMenu:nil withTitle:title];
}

- (void) addMenuEvent:(RDMenuEvent *)event toMenu:(NSString *)menu inSubMenu:(NSString *)subMenu withTitle:(NSString *)title
{
    NSMenuItem *item = [_rdMainMenu itemWithTitle:menu];
    if (!item) {
        item = [[NSMenuItem alloc] initWithTitle:menu action:@selector(executeMenuItem:) keyEquivalent:@""];
        NSMenu *subMenu = [[NSMenu alloc] initWithTitle:menu];
        [item setSubmenu:subMenu];
        [_rdMainMenu insertItem:item atIndex:3];
    }
    if (subMenu) {
        NSMenuItem *subitem = [[item submenu] itemWithTitle:subMenu];
        if (!subitem) {
            subitem = [[NSMenuItem alloc] initWithTitle:subMenu action:@selector(executeMenuItem:) keyEquivalent:@""];
            NSMenu *subMenu2 = [[NSMenu alloc] initWithTitle:subMenu];
            [subitem setSubmenu:subMenu2];
            [[item submenu] addItem:subitem];
        }
        item = subitem;
    }
    
    NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(executeMenuItem:) keyEquivalent:@""];
    [newItem setRepresentedObject:event];
    [[item submenu] addItem:newItem]; 
}

- (void) addDividerToMenu:(NSString *)menu
{
    [self addDividerToMenu:menu inSubMenu:nil];
}

- (void) addDividerToMenu:(NSString *)menu inSubMenu:(NSString *)submenu
{
    NSMenuItem *item = [_rdMainMenu itemWithTitle:menu];
    if (item) {
        if (submenu) {
            item = [[item submenu] itemWithTitle:submenu];
            [[item submenu] addItem:[NSMenuItem separatorItem]];
        }
        else {
            [[item submenu] addItem:[NSMenuItem separatorItem]];
        }
    }
}


#pragma mark Toolbar delegate

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar *) toolbar
{
    NSMutableArray *array = [[[_rdToolbarOptions allKeys] mutableCopy] autorelease];
    [array addObjectsFromArray:[_rdToolbarEvents identifiers]];
    [array addObject:NSToolbarFlexibleSpaceItemIdentifier];
    [array addObject:NSToolbarCustomizeToolbarItemIdentifier];
    [array addObject:NSToolbarSeparatorItemIdentifier];
    [array addObject:NSToolbarSpaceItemIdentifier];
    return array;
}

- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *) toolbar
{
    return [NSArray arrayWithObjects:@"addressBook",NSToolbarSeparatorItemIdentifier,@"worldConnection",NSToolbarFlexibleSpaceItemIdentifier,@"spawnSearch",nil];
}

- (id <ToolbarOption>) toolbarOptionForIdentifier:(NSString *) identifier
{
    id <ToolbarOption> getme = [_rdToolbarOptions objectForKey:identifier];
    
    if (!getme) {
        getme = [_rdToolbarEvents eventForIdentifier:identifier];
    }
    
    return getme;
}

- (BOOL) validateToolbarItem:(NSToolbarItem *) toolbarItem
{
    id <ToolbarOption> getme = [self toolbarOptionForIdentifier:[toolbarItem itemIdentifier]];
    
    if (getme) {
        AtlantisState *state = [self generateStateForCause:@"toolbar" subcause:[toolbarItem itemIdentifier]];
        [state setExtraData:toolbarItem forKey:@"RDToolbarItem"];
    
        return [getme validForState:state];
    }
    
    return NO;
}

- (void) toolbarItemClicked:(NSToolbarItem *) item
{
    id <ToolbarOption> getme = [self toolbarOptionForIdentifier:[item itemIdentifier]];
    
    if (getme) {
        AtlantisState *state = [self generateStateForCause:@"toolbar" subcause:[item label]];
        [state setExtraData:item forKey:@"RDToolbarItem"];
        
        [getme activateWithState:state];
    }
}

- (NSToolbarItem *) toolbar:(NSToolbar *) toolbar itemForItemIdentifier:(NSString *) identifier willBeInsertedIntoToolbar:(BOOL) insert
{
    id <ToolbarOption> getme = [self toolbarOptionForIdentifier:identifier];
    
    if (getme) {
        AtlantisState *state = nil;
        if (insert) {
            state = [self generateStateForCause:@"toolbar" subcause:[toolbar identifier]];
        }
        
        NSToolbarItem *item = [getme toolbarItemForState:state];
        [item setTarget:self];
        [item setAction:@selector(toolbarItemClicked:)];
        return item;
    }
    
    return nil;
}

#pragma mark Lemuria delegate

- (NSToolbar *) nestedWindowToolbar:(NSString *)windowUID;
{
    NSToolbar *toolbar = 
        [[NSToolbar alloc] initWithIdentifier:windowUID];
        
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    [toolbar setSizeMode:NSToolbarSizeModeDefault];

    return toolbar;
}


- (unsigned) weightForView:(NSString *)string
{
    NSRange testRange;
    NSString *worldPart;
    NSString *spawnPart;
    
    testRange = [string rangeOfString:@":"];
    if (testRange.length) {
        worldPart = [string substringWithRange:NSMakeRange(0,testRange.location)];
        int spawnStart = testRange.location + testRange.length;
        spawnPart = [string substringWithRange:NSMakeRange(spawnStart,[string length] - spawnStart)];
    }
    else {
        worldPart = string;
        spawnPart = @"";
    }
    
    if (worldPart && spawnPart) {
        RDAtlantisWorldInstance *instance = [self connectedWorld:worldPart];
        if (instance) {
            RDSpawnConfigRecord *record = [instance configForSpawn:spawnPart];
            if (record)
                return [record weight];
        }
    }
    else if (worldPart && !spawnPart) {
        RDAtlantisWorldPreferences *prefs = 
            [_rdWorlds worldForName:worldPart];
            
        if (prefs) {
            NSNumber *weight = [prefs preferenceForKey:@"atlantis.mainview.weight" withCharacter:nil fallback:NO];
            
            if (weight)
                return [weight intValue];
        }
    }
    
    return 0;
}

#pragma mark Growl

- (NSDictionary *) registrationDictionaryForGrowl
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSString *userDefined = [NSString stringWithString:@"User Defined"];
    
    [dictionary setObject:[NSArray arrayWithObjects:userDefined,nil] forKey:GROWL_NOTIFICATIONS_ALL];
    [dictionary setObject:[NSArray arrayWithObjects:userDefined,nil] forKey:GROWL_NOTIFICATIONS_DEFAULT];
    
    return dictionary;
}

- (NSString *) applicationNameForGrowl
{
    return @"Atlantis";
}

- (BOOL) growlEnabled
{
    return [GrowlApplicationBridge isGrowlRunning];
}

- (void) growlNotificationWasClicked:(id)context
{
    if (context && [context isKindOfClass:[NSDictionary class]]) {
        NSString * spawn = [context objectForKey:@"spawn"];
        if (spawn) {
            id view = [[RDNestedViewManager manager] viewByPath:spawn];
            if (view)
                [[RDNestedViewManager manager] selectView:view];
        }
    }
}

- (void) growlNotificationTimedOut:(id)clickContext
{
    // Do nothing.  La.
}

#pragma mark Data Dispatch Methods

- (NSArray *) inputFilters
{
    return _rdInputFilters;
}

- (RDAtlantisWorldPreferences *) globalWorld
{
    return _rdGlobalWorld;
}

- (NSArray *) globalEvents
{
    EventCollection *eventColl = [_rdGlobalWorld preferenceForKey:@"atlantis.events" withCharacter:nil fallback:NO];
    
    if (eventColl)
        return [eventColl events];
    else
        return nil;
}

- (NSArray *) globalAliases
{
    EventCollection *eventColl = [_rdGlobalWorld preferenceForKey:@"atlantis.aliases" withCharacter:nil fallback:NO];

    if (eventColl)
        return [eventColl events];
    else
        return nil;
}


- (NSArray *) globalHighlights
{
    return [_rdGlobalWorld preferenceForKey:@"atlantis.highlights" withCharacter:nil fallback:NO];
}

- (WorldCollection *) worlds
{
    return _rdWorlds;
}

#pragma mark Registration of Types

- (NSArray *) logTypes
{
    return _rdLogTypes;
}

- (NSArray *) uploaderTypes
{
    return _rdUploaderTypes;
}

- (NSArray *) configTabs
{
    return _rdConfigTabClasses;
}

- (void) addConditionClass:(Class) conditionClass
{
    [_rdConditionTypes registerConditionClass:conditionClass];
}

- (void) addActionClass:(Class) actionClass
{
    [_rdActionTypes registerActionClass:actionClass];
}

- (void) addInputFilter:(Class) filterClass
{
    [_rdInputFilters addObject:filterClass];
}

- (void) addLogfileType:(Class) logfileClass
{
    [_rdLogTypes addObject:logfileClass];
}

- (void) addUploaderType:(Class) logfileClass
{
    [_rdUploaderTypes addObject:logfileClass];
}

- (void) addConfigTabClass:(Class) configClass
{
    [_rdConfigTabClasses addObject:configClass];
}

- (void) addPreferencePane:(id <AtlantisPreferencePane>) pane
{
    [_rdPreferenceWindow addPane:pane];
}

- (void) addToolbarOption:(id <ToolbarOption>) option
{
    [_rdToolbarOptions setObject:option forKey:[option toolbarItemIdentifier]];
}

- (void) addCommand:(BaseCommand *) command forText:(NSString *) text
{
    [_rdCommands setObject:command forKey:[text lowercaseString]];
}

- (BaseCommand *) commandForText:(NSString *) text
{
    return [_rdCommands objectForKey:[text lowercaseString]];
}

- (HotkeyCollection *) hotkeyBindings
{
    return _rdHotkeys;
}

- (ToolbarCollection *) toolbarUserEvents
{
    return _rdToolbarEvents;
}

- (ActionClasses *) eventActions
{
    return _rdActionTypes;
}

- (ConditionClasses *) eventConditions
{
    return _rdConditionTypes;
}

- (RDAtlantisWorldInstance *) connectedWorld:(NSString *) name
{
    return [_rdConnectedWorlds objectForKey:[name lowercaseString]];
}

- (void) addWorld:(RDAtlantisWorldInstance *)world
{
    [_rdConnectedWorlds setObject:world forKey:[[world basePath] lowercaseString]];
}

- (void) removeWorld:(RDAtlantisWorldInstance *)world
{
    [_rdConnectedWorlds removeObjectForKey:[[world basePath] lowercaseString]];
}

- (BOOL) worldsAreConnected
{
    BOOL result = NO;
    NSEnumerator *worldEnumerator = [_rdConnectedWorlds objectEnumerator];
    
    RDAtlantisWorldInstance *worldWalk;
    
    while (!result && (worldWalk = [worldEnumerator nextObject])) {
        result = result || [worldWalk isConnected];
    }
    
    return result;
}

- (void) disconnectAllWorldsWithoutRemoving
{
    NSEnumerator *worldEnumerator = [_rdConnectedWorlds objectEnumerator];
    
    RDAtlantisWorldInstance *worldWalk;
    
    while (worldWalk = [worldEnumerator nextObject]) {
        [worldWalk disconnect];
    }
}


- (void) disconnectAllWorlds
{
    NSEnumerator *worldEnumerator = [_rdConnectedWorlds objectEnumerator];
    
    RDAtlantisWorldInstance *worldWalk;
    
    while (worldWalk = [worldEnumerator nextObject]) {
        [worldWalk closeAndRemove];
    }
}

- (void) saveAllData
{
    [self saveKeyBindings];
    [self saveToolbarEvents];
    [self saveGlobals];
    [self saveWorlds];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) eventsTimerFired:(NSTimer *) timer
{
    NSEnumerator *worldEnum = [_rdConnectedWorlds objectEnumerator];
    RDAtlantisWorldInstance *worldWalk;
    
    while (worldWalk = [worldEnum nextObject]) {
        [worldWalk netsync];
        if ([worldWalk isConnected]) {
            [worldWalk fireTimerEvents];
        }
    }
}

- (void) markAndDisconnectAll:(NSString *) reason
{
    NSEnumerator *worldEnum = [_rdConnectedWorlds objectEnumerator];
    RDAtlantisWorldInstance *walk;
    
    while (walk = [worldEnum nextObject]) {
        if ([walk isConnected]) {
            [walk setShouldReconnect:YES];
            [walk disconnectWithMessage:reason];
        }
    }
}

- (void) reconnectAllNeeded
{
    NSEnumerator *worldEnum = [_rdConnectedWorlds objectEnumerator];
    RDAtlantisWorldInstance *walk;
    
    while (walk = [worldEnum nextObject]) {
        if (![walk isConnected] && [walk shouldReconnect]) {
            [walk connect];
        }
    }
    
}

- (NSEnumerator *) worldWalk
{
    return [_rdConnectedWorlds objectEnumerator];
}

- (BOOL) createDirectoriesToFile:(NSString *) filename
{
    NSArray *pathComponents = [[[filename stringByExpandingTildeInPath] stringByDeletingLastPathComponent] pathComponents];
    
    NSString *currentPath = @"";
    NSFileManager *fileman = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    NSEnumerator *pathEnum = [pathComponents objectEnumerator];
    NSString *pathFragment = @"/";
    
    do {
        currentPath = [currentPath stringByAppendingPathComponent:pathFragment];
        if ([fileman fileExistsAtPath:currentPath isDirectory:&isDirectory]) {
            if (!isDirectory)
                return NO;
        }
        else {
            if (![fileman createDirectoryAtPath:currentPath attributes:nil])
                return NO;
        }
    } while (pathFragment = [pathEnum nextObject]);

    return YES;
}

- (void) setDefaultGlobals
{
    NSMutableArray *tempArray;
    EventCollection *events;
    HighlightEvent *highlight;
    RDStringPattern *pattern;

    tempArray = [[NSMutableArray alloc] init];

    highlight = [[HighlightEvent alloc] 
            initWithPattern:[RDStringPattern patternWithString:@"From afar, " type:RDPatternBeginsWith] 
            foreground:[NSColor yellowColor]
            background:[NSColor blackColor]];
    [tempArray addObject:highlight];
    highlight = [[HighlightEvent alloc] 
            initWithPattern:[RDStringPattern patternWithString:@"Long distance to " type:RDPatternBeginsWith] 
            foreground:[NSColor yellowColor]
            background:[NSColor blackColor]];
    [tempArray addObject:highlight];
    highlight = [[HighlightEvent alloc] 
            initWithPattern:[RDStringPattern patternWithString:@"You page" type:RDPatternBeginsWith] 
            foreground:[NSColor yellowColor]
            background:[NSColor blackColor]];
    [tempArray addObject:highlight];
    highlight = [[HighlightEvent alloc] 
            initWithPattern:[RDStringPattern patternWithString:@"^[^<>\\[\\]\\\"\\+\\|]* pages[:,] .*" type:RDPatternRegexp] 
            foreground:[NSColor yellowColor]
            background:[NSColor blackColor]];
    [tempArray addObject:highlight];
    [_rdGlobalWorld setPreference:tempArray forKey:@"atlantis.highlights" withCharacter:nil];

    events = [[EventCollection alloc] init];

    if ([self growlEnabled]) {
        WorldEvent *event = [[WorldEvent alloc] init];
        Condition_ViewActive *activeCondition = [[Condition_ViewActive alloc] initWantsActive:NO];
        Condition_AtlantisFocus *focusCondition = [[Condition_AtlantisFocus alloc] init];
        Condition_CollectedConditions *collection = [[Condition_CollectedConditions alloc] initWithConditions:[NSArray arrayWithObjects:activeCondition,focusCondition,nil] anded:NO];
        [event eventAddCondition:collection];
        
        tempArray = [[NSMutableArray alloc] init];
        pattern = [RDStringPattern patternWithString:@"From afar," type:RDPatternBeginsWith];
        Condition_StringMatch *stringCondition = [[Condition_StringMatch alloc] initWithPattern:pattern];
        [tempArray addObject:stringCondition];
        pattern = [RDStringPattern patternWithString:@"^[^<>\\[\\]]* pages[:,] .*" type:RDPatternRegexp];
        stringCondition = [[Condition_StringMatch alloc] initWithPattern:pattern];
        [tempArray addObject:stringCondition];
        collection = [[Condition_CollectedConditions alloc] initWithConditions:[NSArray arrayWithArray:tempArray] anded:NO];
        [event eventAddCondition:collection];
        [event eventSetConditionsAnded:YES];

        Action_Growl *growlEvent = [[Action_Growl alloc] initWithString:@"%{event.line}" title:@"Page for %{world.character} on %{world.game}"];
        [event eventAddAction:growlEvent];
        [event eventSetEnabled:YES];
        [event eventSetName:@"Growl Unseen Pages"];
        [event eventSetDescription:@"Display unseen pages via Growl"];
        [events addEvent:event];
    }
    [_rdGlobalWorld setPreference:events forKey:@"atlantis.events" withCharacter:nil];
    
    NSFont *realFont = [NSFont userFixedPitchFontOfSize:10.0f];
    [_rdGlobalWorld setPreference:realFont forKey:@"atlantis.formatting.font" withCharacter:nil];
}

- (void) setDefaultKeyBindings
{
    PTKeyCombo *key = [[PTKeyCombo alloc] initWithKeyCode:13 modifiers:256];
    HotkeyEvent *binding = [[HotkeyEvent alloc] initWithActions:[NSArray arrayWithObject:[[Action_CloseFocused alloc] init]] forKey:key global:NO];
    [_rdHotkeys addEvent:binding];

    key = [[PTKeyCombo alloc] initWithKeyCode:0 modifiers:768];
    binding = [[HotkeyEvent alloc] initWithActions:[NSArray arrayWithObject:[[Action_NextSpawn alloc] init]] forKey:key global:NO];
    [_rdHotkeys addEvent:binding];

    key = [[PTKeyCombo alloc] initWithKeyCode:53 modifiers:512];
    Action_InputCopy *copyAct = [[Action_InputCopy alloc] init];
    Action_InputClear *clearAct = [[Action_InputClear alloc] init];
    binding = [[HotkeyEvent alloc] initWithActions:[NSArray arrayWithObjects:copyAct,clearAct,nil] forKey:key global:NO];
    [_rdHotkeys addEvent:binding];
    
    key = [[PTKeyCombo alloc] initWithKeyCode:2 modifiers:256];
    binding = [[HotkeyEvent alloc] initWithActions: [NSArray arrayWithObject:[[Action_WorldDisconnect alloc] init]] forKey:key global:NO];
    [_rdHotkeys addEvent:binding];

    key = [[PTKeyCombo alloc] initWithKeyCode:5 modifiers:256];
    binding = [[HotkeyEvent alloc] initWithActions: [NSArray arrayWithObject:[[Action_WorldReconnect alloc] init]] forKey:key global:NO];
    [_rdHotkeys addEvent:binding];    
    
    key = [[PTKeyCombo alloc] initWithKeyCode:32 modifiers:4096];
    binding = [[HotkeyEvent alloc] initWithActions:[NSArray arrayWithObject:[[Action_InputClear alloc] init]] forKey:key global:NO];
    [_rdHotkeys addEvent:binding];   

    key = [[PTKeyCombo alloc] initWithKeyCode:45 modifiers:4096];
    binding = [[HotkeyEvent alloc] initWithActions:[NSArray arrayWithObject:[[Action_HistoryNext alloc] init]] forKey:key global:NO];
    [_rdHotkeys addEvent:binding];

    key = [[PTKeyCombo alloc] initWithKeyCode:35 modifiers:4096];
    binding = [[HotkeyEvent alloc] initWithActions:[NSArray arrayWithObject:[[Action_HistoryPrev alloc] init]] forKey:key global:NO];
    [_rdHotkeys addEvent:binding];

    key = [[PTKeyCombo alloc] initWithKeyCode:37 modifiers:256];
    binding = [[HotkeyEvent alloc] initWithActions:[NSArray arrayWithObject:[[Action_LogpanelOpen alloc] init]] forKey:key global:NO];
    [_rdHotkeys addEvent:binding];

    key = [[PTKeyCombo alloc] initWithKeyCode:40 modifiers:256];
    binding = [[HotkeyEvent alloc] initWithActions:[NSArray arrayWithObject:[[Action_LogpanelClose alloc] init]] forKey:key global:NO];
    [_rdHotkeys addEvent:binding]; 

    
}

- (void) loadKeyBindings
{
    NSString *hotkeyFile = @"~/Library/Application Support/Atlantis/hotkeys.akb";

    [_rdHotkeys release];
    _rdHotkeys = [[NSKeyedUnarchiver unarchiveObjectWithFile:[hotkeyFile stringByExpandingTildeInPath]] retain];
    
    if (!_rdHotkeys) {
        _rdHotkeys = [[[HotkeyCollection alloc] init] retain];
    }
    
    if (![_rdHotkeys eventsCount]) {
        [self setDefaultKeyBindings];
    }
}

- (void) saveKeyBindings
{
    NSString *hotkeyFile = @"~/Library/Application Support/Atlantis/hotkeys.akb";

    if ([self createDirectoriesToFile:hotkeyFile]) {
        [NSKeyedArchiver archiveRootObject:_rdHotkeys toFile:[hotkeyFile stringByExpandingTildeInPath]];
    }
}

- (void) loadToolbarEvents
{
    NSString *toolbarFile = @"~/Library/Application Support/Atlantis/toolbarEvents.atb";

    [_rdToolbarEvents release];
    _rdToolbarEvents = [[NSKeyedUnarchiver unarchiveObjectWithFile:[toolbarFile stringByExpandingTildeInPath]] retain];
    
    if (!_rdToolbarEvents) {
        _rdToolbarEvents = [[ToolbarCollection alloc] init];
    }
}

- (void) saveToolbarEvents
{
    NSString *toolbarFile = @"~/Library/Application Support/Atlantis/toolbarEvents.atb";

    if ([self createDirectoriesToFile:toolbarFile]) {
        [NSKeyedArchiver archiveRootObject:_rdToolbarEvents toFile:[toolbarFile stringByExpandingTildeInPath]];
    }
}


- (void) loadGlobals
{
    NSString *globalsFile = @"~/Library/Application Support/Atlantis/globals.awd";

    _rdGlobalWorld = [[NSKeyedUnarchiver unarchiveObjectWithFile:[globalsFile stringByExpandingTildeInPath]] retain];
    
    if (!_rdGlobalWorld) {
        _rdGlobalWorld = [[[RDAtlantisWorldPreferences alloc] init] retain];
        [self setDefaultGlobals];
    }

    if (![_rdGlobalWorld preferenceForKey:@"atlantis.colors.ansi" withCharacter:nil]) {
        NSMutableArray * ansiColorArray = [[NSMutableArray alloc] initWithCapacity:16];
        
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.000 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.800 green:0.000 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.800 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.800 green:0.800 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.000 blue:0.800 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.800 green:0.000 blue:0.800 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.800 blue:0.800 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.800 green:0.800 blue:0.800 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.500 green:0.500 blue:0.500 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:1.000 green:0.000 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:1.000 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:1.000 green:1.000 blue:0.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:0.000 blue:1.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:1.000 green:0.000 blue:1.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:0.000 green:1.000 blue:1.000 alpha:1.0]];
        [ansiColorArray addObject:[NSColor colorWithCalibratedRed:1.000 green:1.000 blue:1.000 alpha:1.0]];
        
        [_rdGlobalWorld setPreference:[NSArray arrayWithArray:ansiColorArray] forKey:@"atlantis.colors.ansi" withCharacter:nil];
    }
    
    if (![_rdGlobalWorld preferenceForKey:@"atlantis.colors.url" withCharacter:nil]) {
        [_rdGlobalWorld setPreference:[NSColor cyanColor] forKey:@"atlantis.colors.url" withCharacter:nil];
    }
    
    if (![_rdGlobalWorld preferenceForKey:@"atlantis.colors.system" withCharacter:nil]) {
        [_rdGlobalWorld setPreference:[NSColor yellowColor] forKey:@"atlantis.colors.system" withCharacter:nil];
    }
    
    if (![_rdGlobalWorld preferenceForKey:@"atlantis.grab.password" withCharacter:nil]) {
        [_rdGlobalWorld setPreference:@"SimpleMUUser" forKey:@"atlantis.grab.password" withCharacter:nil];
    }
}

- (void) saveGlobals
{
    NSString *globalsFile = @"~/Library/Application Support/Atlantis/globals.awd";

    if ([self createDirectoriesToFile:globalsFile]) {
        [NSKeyedArchiver archiveRootObject:_rdGlobalWorld toFile:[globalsFile stringByExpandingTildeInPath]];
    }
}

- (void) loadWorlds
{
    [_rdWorlds loadAllWorlds];
    _rdAddressBook = [[AddressBook alloc] init];
    [_rdAddressBook setWorldCollection:_rdWorlds];    
}

- (void) saveWorlds
{
    [_rdWorlds saveAllWorlds];
}

- (void) saveDirtyWorlds
{
    [_rdWorlds saveDirtyWorlds];
}

- (void) saveWorld:(RDAtlantisWorldPreferences *)world
{
    [_rdWorlds saveWorld:world];
}

#pragma mark Application Stuff

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AtlantisReopenedNotification" object:self];
    return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    BOOL hasOpen = [self worldsAreConnected];

    [[RDAtlantisMainController controller] saveAllData];
    
    if (hasOpen) {
        // TODO: Localize
        NSAlert *alert =
            [NSAlert alertWithMessageText:@"Really Quit?" defaultButton:@"Quit" alternateButton:@"Don't Quit" otherButton:nil informativeTextWithFormat:@"There are still connected worlds.  Are you sure you want to quit?"];
            
        NSArray *buttons = [alert buttons];
        NSButton *noButton = [buttons objectAtIndex:1];
        [noButton setKeyEquivalent:@"\e"];        
            
        int result = [alert runModal];
        
        if (result == NSAlertAlternateReturn)
            return NSTerminateCancel;
        else {
            [[RDAtlantisMainController controller] disconnectAllWorlds];
//            [_rdBadger badgeWithText:@""];
//            [_rdBadger badgeWithActive:0];
            [NSApp setApplicationIconImage:[NSImage imageNamed:@"NSApplicationIcon"]];
            return NSTerminateNow;
        }
    }
    else {
        [NSApp setApplicationIconImage:[NSImage imageNamed:@"NSApplicationIcon"]];
//        [_rdBadger badgeWithText:@""];
//        [_rdBadger badgeWithActive:0];
        
        return NSTerminateNow;
    }
}

- (void) connectTemporaryWorld:(NSString *)hostname port:(int)port mush:(BOOL) isMush
{
    RDAtlantisWorldPreferences *tempPrefs = [[RDAtlantisWorldPreferences alloc] init];
    [tempPrefs setPreference:hostname forKey:@"atlantis.world.host" withCharacter:nil];
    [tempPrefs setPreference:[NSNumber numberWithInt:port] forKey:@"atlantis.world.port" withCharacter:nil];

    if (isMush) {
        [tempPrefs setPreference:[NSNumber numberWithInt:AtlantisServerTinyMU] forKey:@"atlantis.world.codebase" withCharacter:nil];
    }
    else {
        [tempPrefs setPreference:[NSNumber numberWithInt:AtlantisServerMud] forKey:@"atlantis.world.codebase" withCharacter:nil];    
    }
    
    BOOL done = NO;
    int counter = 0;

    NSString *tempName = nil;
    
    while (!done) {
        counter++;
        tempName = [NSString stringWithFormat:@"TempWorld%02d", counter];
        if (![self connectedWorld:tempName]) {
            [tempPrefs setPreference:tempName forKey:@"atlantis.world.displayName" withCharacter:nil];
            [tempPrefs setPreference:[NSString stringWithFormat:@"Temporary %02d", counter] forKey:@"atlantis.world.name" withCharacter:nil];
            [tempPrefs setPreference:[NSNumber numberWithBool:YES] forKey:@"atlantis.world.temporary" withCharacter:nil];
            done = YES;
        } 
    }
    
    RDAtlantisWorldInstance *world = [[RDAtlantisWorldInstance alloc] initWithWorld:tempPrefs forCharacter:nil withBasePath:tempName];
    [world connectAndFocus];
    [world setTemp:YES];
    [world release];
    [tempPrefs release];
}

- (ScriptingDispatch *) scriptDispatch
{
    return _rdScriptSystem;
}

- (void) addScriptingEngine:(ScriptingEngine *) engine
{
    [_rdScriptSystem addScriptingEngine:engine];
}

- (NSDictionary *) tempStateVars
{
    return _rdTempStateVars;
}

- (NSString *) tempStateVarForKey:(NSString *) key
{
    id object = [_rdTempStateVars objectForKey:key];
    
    if ([(NSObject *)object isKindOfClass:[NSString class]]) 
        return (NSString *)object;        
    else
        return [(NSObject *)object description];
}

- (void) setStateVar:(NSString *) variable forKey:(NSString *)key
{
    [_rdTempStateVars setObject:variable forKey:key];
}

- (AtlantisState *) stateForSession:(NSString *) sessionUID
{
    return [_rdSessionStateItems objectForKey:sessionUID];
}

- (void) finishedSession:(NSString *)sessionUID
{
    [_rdSessionStateItems removeObjectForKey:sessionUID];
}

- (void) addState:(AtlantisState*)state forSession:(NSString *) sessionUID
{
    [_rdSessionStateItems setObject:state forKey:sessionUID];
}


- (void) addScriptEvent:(NSString *)function inLanguage:(NSString *)language forType:(NSString *)eventType withWorld:(NSString *)world
{
    ScriptEventAction *newAction;
    
    newAction = [[ScriptEventAction alloc] initForType:eventType withLanguage:language inWorld:world withFunction:function withInterval:0 repeatCount:-1];
    [_rdScriptedEvents addObject:newAction];
    [newAction release];
}

- (void) addScriptPattern:(NSString *)pattern withFunction:(NSString *)function inLanguage:(NSString *)language withWorld:(NSString *)world
{
    ScriptEventAction *newAction;
    
    newAction = [[ScriptEventAction alloc] initForLine:pattern withLanguage:language inWorld:world withFunction:function withInterval:0 repeatCount:-1];
    [_rdScriptedEvents addObject:newAction];
    [newAction release];
}


- (void) addScriptTimer:(NSString *)function inLanguage:(NSString *)language withWorld:(NSString *)world withInterval:(NSTimeInterval)seconds repeats:(int)repeats
{
    ScriptEventAction *newAction;
    
    newAction = [[ScriptEventAction alloc] initForType:@"timer" withLanguage:language inWorld:world withFunction:function withInterval:seconds repeatCount:repeats];
    [_rdScriptedEvents addObject:newAction];
    [newAction release];
}


- (void) addScriptAlias:(NSString *)alias forFunction:(NSString *)function inLanguage:(NSString *)language withWorld:(NSString *)world
{
    ScriptEventAction *newAction;
    
    newAction = [[ScriptEventAction alloc] initForAlias:alias withLanguage:language inWorld:world withFunction:function withInterval:0];
    [_rdScriptedEvents addObject:newAction];
    [newAction release];
}

- (void) removeAllScriptedEventsForLanguage:(NSString *)language
{
    NSEnumerator *actionEnum = [_rdScriptedEvents objectEnumerator];
    
    ScriptEventAction *action;
    
    while (action = [actionEnum nextObject]) {
        if ([[[action eventLanguage] lowercaseString] isEqualToString:[language lowercaseString]]) {
            [action disable];
            [_rdScriptedEvents removeObject:action];
        }
    }
}

- (BOOL) fireScriptedEventsForState:(AtlantisState *)state
{
    BOOL result = NO;
    NSEnumerator *actionEnum = [_rdScriptedEvents objectEnumerator];
    NSString *world = [[state extraDataForKey:@"world.name"] lowercaseString];
    NSString *type = [[state extraDataForKey:@"event.cause"] lowercaseString];
    
    ScriptEventAction *action;
    
    while (action = [actionEnum nextObject]) {
        BOOL fire = NO;
        
        if ([[[action eventType] lowercaseString] isEqualToString:type] &&
            ((![action eventWorld] || [[action eventWorld] isEqualToString:@""]) || ([[[action eventWorld] lowercaseString] isEqualToString:world]))) {
            fire = YES;
        }
        
        if (fire && [[[action eventType] lowercaseString] isEqualToString:@"line"] && [action eventPattern]) {
            NSRange testRange = [[[state stringData] string] rangeOfRegularExpressionString:[action eventPattern]];
            if (testRange.location == NSNotFound)
                fire = NO;
        }

        if (fire) {
            [action executeForState:state];
            result = YES;
            
            if ([action countdown] == 0) {
                [_rdScriptedEvents removeObject:action];
            }
        }
    }

    return result;
}

- (BOOL) fireScriptedEventsForAlias:(NSString *)alias withState:(AtlantisState *)state
{
    NSEnumerator *actionEnum = [_rdScriptedEvents objectEnumerator];
    NSString *world = [[state extraDataForKey:@"world.name"] lowercaseString];
    NSString *realAlias = [alias lowercaseString];
    
    ScriptEventAction *action;
    BOOL handled = NO;
    
    while (!handled && (action = [actionEnum nextObject])) {
        if ([[[action alias] lowercaseString] isEqualToString:realAlias] &&
            ((![action eventWorld] || [[action eventWorld] isEqualToString:@""]) || ([[[action eventWorld] lowercaseString] isEqualToString:world]))) {
            [action executeForState:state];
            handled = YES;
        }
    }
    
    return handled;
}


- (void) addScriptHotkey:(int)keycode modifiers:(int)modifiers globally:(BOOL)registerGlobally forFunction:(NSString *)function inLanguage:(NSString *)language withWorld:(NSString *)world
{
    PTKeyCombo *combo = [[PTKeyCombo alloc] initWithKeyCode:keycode modifiers:modifiers];

    ScriptEventAction *newAction;
    
    newAction = [[ScriptEventAction alloc] initForHotkey:combo globally:registerGlobally withLanguage:language inWorld:world withFunction:function withInterval:0];
    [_rdScriptedEvents addObject:newAction];
    [newAction release];
}

- (BOOL) fireScriptedEventsForKeycode:(int)keycode withModifiers:(int)modifiers
{
    NSEnumerator *actionEnum = [_rdScriptedEvents objectEnumerator];
    
    ScriptEventAction *action;
    BOOL handled = NO;
    
    while (!handled && (action = [actionEnum nextObject])) {
        if ([[[action eventType] lowercaseString] isEqualToString:@"hotkey"]) {
        
            PTKeyCombo *testCombo = [action keyCode];
            if (([testCombo keyCode] == keycode) && ([testCombo modifiers] == modifiers)) {
                [action execute:self];
                handled = YES;
            }
        }
    }
    
    return handled;
}



#pragma mark UI Control Methods

- (void) renameWindow:(id)sender
{
    NSWindow *window = [NSApp keyWindow];
    if (window && [window isKindOfClass:[RDNestedViewWindow class]]) {
        RenameWindowPanel *panel = [RenameWindowPanel sharedPanel];
        if (panel) {
            [panel renameForWindow:(RDNestedViewWindow *)window];
        }
    }
}

- (void) customizeToolbar:(id) sender
{
    NSWindow *window = [NSApp keyWindow];
    if (window && [window isKindOfClass:[RDNestedViewWindow class]]) {
        NSToolbar *toolbar = [window toolbar];
        if (toolbar) {
            [toolbar runCustomizationPalette:self];
        }
    }
}

- (BOOL) statusBarBottom
{
    return _rdStatusBarBottom;
}

- (void) setStatusBarBottom:(BOOL)bottom
{
    _rdStatusBarBottom = bottom;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RDAtlantisStatusBarDidChangeNotification" object:self];
}

- (void) aboutBox:(id) sender
{
    if (_rdAboutBox) {
        [_rdAboutBox display];
    }
}

- (void) addressBook:(id) sender
{
    if (_rdAddressBook) {
        [_rdAddressBook display];
    }
    else {
        _rdAddressBook = [[AddressBook alloc] init];
        [_rdAddressBook setWorldCollection:_rdWorlds];
        [_rdAddressBook display];
    }
}

- (void) addressBookClosed
{
    [self saveWorlds];
}

- (void) openPreferences:(id) sender
{
    [_rdPreferenceWindow showPreferences];
}

- (void) focusSpawn:(id) sender
{
    if ([[sender representedObject] conformsToProtocol:@protocol(RDNestedViewDescriptor)]) {
        [[RDNestedViewManager manager] selectView:[sender representedObject]];
        if (![NSApp isActive]) {
            [NSApp activateIgnoringOtherApps:YES];
        }
    }
}

- (void) activityForSpawn:(NSNotification *) notification
{
    id view = [notification object];
    NSMenuItem *item = [_rdActiveSpawnsMenu itemWithTitle:[[notification object] viewPath]];
    if (item)
        return;
        
    item = [[NSMenuItem alloc] initWithTitle:[view viewPath] action:@selector(focusSpawn:) keyEquivalent:@""];
    
    [item setRepresentedObject:view];
    [item setEnabled:YES];
    [item setTarget:self];
    [_rdActiveSpawnsMenu addItem:item];  
    
    [self refreshBadge];
}

- (void) refreshBadge
{
    BOOL shouldDisplay = YES;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.badge.inactive"] == YES)
        shouldDisplay = ![NSApp isActive];
    
    if (shouldDisplay && [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.badge.visible"] == YES) {
        BOOL isVisible = NO;
        
        NSArray *windows = [NSApp windows];
        NSEnumerator *windowEnum = [windows objectEnumerator];
        NSWindow *windWalk;
        
        while (windWalk = [windowEnum nextObject]) {
            if ([windWalk isVisible] && ![windWalk isMiniaturized])
                isVisible = YES;
        }

        shouldDisplay = isVisible;
    }

    int activeCount = [[[RDNestedViewManager manager] activeViews] count];

    if (shouldDisplay && (activeCount > 0)) {        
        [_rdBadger badgeApplicationDockIconWithValue:activeCount insetX:3 y:0];        
    }
    else {
        [NSApp setApplicationIconImage:[NSImage imageNamed:@"NSApplicationIcon"]];
    }
}

- (void) noActivityForSpawn:(NSNotification *) notification
{
    NSMenuItem *item = [_rdActiveSpawnsMenu itemWithTitle:[[notification object] viewPath]];

    if (item) {
        [_rdActiveSpawnsMenu removeItem:item];
    }
    [self refreshBadge];
}

- (NSMenu *) applicationDockMenu:(NSApplication *)sender
{
    return _rdActiveSpawnsMenu;
}

- (void) appBecameActive:(NSNotification *)notification
{
    [self refreshBadge];
}

- (void) appBecameInactive:(NSNotification *)notification
{
    [self refreshBadge];
}

- (void) openPrefsForWorld:(RDAtlantisWorldPreferences *)world onCharacter:(NSString *)character
{
    [_rdAddressBook focusWorld:world forCharacter:character];
}

- (void) openMushEditorForWorld:(RDAtlantisWorldInstance *)world
{
    if (![_rdTextEditor isInUse]) {
        [_rdTextEditor setupForWorld:world];
    }
    [_rdTextEditor display];
}

- (MCPDispatch *) mcpDispatch
{
    return _rdMcpDispatch;
}

- (IBAction) checkForUpdates:(id) sender
{
//    [DTCVersionManager checkVersionAt:@"http://www.riverdark.net/atlantis/atlantis_versions.plist"
//                      withProductPage:@"http://www.riverdark.net/atlantis/downloads/"
//                     andApplyToWindow:nil
//                           showAlerts:YES];
}

- (IBAction) launchDocWiki:(id) sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://wiki.riverdark.net/"]];
}

@end
 
