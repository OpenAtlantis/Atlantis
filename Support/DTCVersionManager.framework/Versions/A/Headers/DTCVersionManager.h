#import <Cocoa/Cocoa.h>
#import <math.h>
#import <SystemConfiguration/SCNetwork.h>

/*
 *  DTCVersionManager v2.0 © 2004 Daniel Todd Currie
 *  Line of Sight Software - http://los.dtcurrie.net
 *
 *  Requires Mac OS X v10.2
 *
 *  ABSTRACT:
 *  DTCVersionManager allows a Cocoa/Objective-C programmer to easily 
 *  add robust version management functionality to their application.
 *
 *  CONTRIBUTORS:
 *  Karl Goiser
 *  Oliver Cameron
 *
 *  IMPLEMENTATION:
 *
 *  All that is needed for DTCVersionManager to work is a message 
 *  like this one:
 *  
 *      [DTCVersionManager checkVersionAt:versionPlistFileURLString
 *                        withProductPage:productPageURLString
 *                       andApplyToWindow:mainWindow
 *                             showAlerts:alerts]
 *
 *  DTCVersionManager checks for the latest version at your provided 
 *  URL, using a specific format for the plist file.  Check the file 
 *  at http://los.dtcurrie.net/code/dtcvm_version_english.plist for the proper 
 *  format.  This plist file is also included on the DTCVersionManager disk 
 *  image in the same directory as this header file.  versionPlistFileURLString
 *  is a string containing the URL for the plist file as it exists on
 *  your server.  productPageURLString is a string containing the URL
 *  for your application's download page.
 *
 *  The window to which the sheet will be attached is named mainWindow
 *  in this example application.  Passing nil instead of mainWindow will 
 *  cause the alert to be displayed as a panel.  alerts is a BOOL that
 *  allows you to choose whether or not the user is to be notified if
 *  their software is up to date or if the check was unsuccessful.
 *
 *  You may only want the version check to run in the
 *  -applicationDidFinishLaunching: method, however IBAction methods 
 *  are included for testing purposes.  If you press "Ignore This Version" 
 *  in the sheet/panel, you will need to throw out the preferences file
 *  in order to get the sheet/panel back.  This file can be found at:
 *  ~/Library/Preferences/net.dtcurrie.los.dtcvmexample.plist
 *
 *  THE "CFVersionNumber" FOR YOUR APP WILL NEED TO BE AN INTEGER VALUE 
 *  IN ORDER FOR THE VERSION COMPARISON TO WORK!!!
 *
 *  DTCVersionManager will create two NSUserDefaults entries in your
 *  application preferences.  These defaults use the following keys:
 *  
 *		@"DTCVMIgnoreVersion" - remembers the latest version that the user
 *			has set to be ignored
 *		@"DTCVMShowDetails" - remembers the state of the details disclosure
 *			triangle in the new version panel or sheet
 *
 *  You may also want to receive notifications on the results of the
 *  version check.  Do this by listening for notifications under
 *  the name @"DTCVMResultNotification", like this:
 *
 *		[[NSNotificationCenter defaultCenter] addObserver:self
 *												 selector:@selector(versionResultReceived:)
 *													 name:@"DTCVMResultNotification"
 *												   object:nil];
 *
 *  The notifications that DTCVM sends have the following NSString objects
 *  for key @"versionResult" in the notification's userInfo dictionary:
 *
 *		@"DTCVMUnsuccessful" - network failure
 *		@"DTCVMCurrent" - the software is current
 *		@"DTCVMIgnored" - the new version has previously been ignored
 *		@"DTCVMNew" - a new version is available
 *		@"DTCVMUserIgnore" - the user chose to ignore this version
 *		@"DTCVMUserRemind" - the user chose to be reminded later
 *		@"DTCVMUserDownload" - the user chose to visit the product URL
 *  
 *  Feel free to contact me at los@dtcurrie.net with any other
 *  comments or questions.
 */

@interface DTCVersionManager : NSObject
{
    IBOutlet NSWindow *newVersionWindow;
    IBOutlet NSImageView *iconImageView;
    IBOutlet NSBox *detailsLine;
    IBOutlet NSButton *detailsButton;
    IBOutlet NSTextView *detailsTextView;
	IBOutlet NSTextView *messageTextView;
    
    BOOL isShowingDetails;
	BOOL windowIsResizable;
	BOOL useSheet;
    
    NSWindow *windowForSheet;
    NSString *productPage;
    BOOL alerts;
    UInt16 webVersionLatestInt;
	NSView *detailsSuperview;
	NSScrollView *detailsScrollView;
	NSScrollView *messageScrollView;
}

#pragma mark -

+ (void)checkVersionAt:(NSString *)versionURLString
       withProductPage:(NSString *)productPageURL
      andApplyToWindow:(NSWindow *)versionAlertWindow
            showAlerts:(BOOL)alerts;

#pragma mark -

- (IBAction)showDetails:(id)sender;
- (IBAction)ignoreThisVersion:(id)sender;
- (IBAction)remindMeLater:(id)sender;
- (IBAction)downloadNewVersion:(id)sender;

@end
