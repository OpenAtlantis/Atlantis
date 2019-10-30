//
//  RDAtlantisSpawn.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/8/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDAtlantisSpawn.h"
#import "RDAtlantisMainController.h"

@interface RDAtlantisSpawn (Private)
- (void) refreshPreferencesFrom:(RDSpawnConfigRecord *)prefs;
- (void) worldConnected:(NSNotification *) notification;
- (void) worldDisconnected:(NSNotification *) notification;
- (void) worldChangedConfig:(NSNotification *) notification;
- (void) outputViewFrameChanged:(NSNotification *) notification;
- (void) statusBarSettingChanged:(NSNotification *) notification;
- (void) setAllowsNonContiguousLayout:(BOOL)layoutOptimize;
@end

@implementation RDAtlantisSpawn

static NSImage *s_globeImage = nil;
static NSImage *s_spawnImage = nil;

static NSImage *s_statusBarImage = nil;

static NSImage *s_statusLockImage = nil;
static NSImage *s_statusLockGreyImage = nil;

#pragma mark Initialization

- (id) initWithPath:(NSString *)path forInstance:(RDAtlantisWorldInstance *) instance withPrefs:(RDSpawnConfigRecord *)prefs
{
    self = [super init];
    if (self) {
        _rdSubviews = [[NSMutableArray alloc] init];

        _rdPath = [path retain];
        _rdName = [[[path componentsSeparatedByString:@":"] lastObject] retain];
        _rdUID = [[NSString stringWithFormat:@"Atlantis.spawn:%@", path] retain];        
        _rdFont = [[NSFont userFixedPitchFontOfSize:10.0f] retain];
        _rdWeight = 1;
        _rdLines = 0;
        _rdActiveExceptions = nil;
        _rdDefaultsActive = YES;
        _rdBackgroundColor = [[NSColor blackColor] retain];
        _rdInputColor = [[NSColor whiteColor] retain];
        _rdConsoleColor = [[NSColor yellowColor] retain];
        _rdShowTimestamps = NO;
        _rdSpawnPrefix = nil;
        _rdHasText = NO;
        _rdLastNewline = YES;
        _rdWorldIcon = nil;
        
        if (prefs)
            [self refreshPreferencesFrom:prefs];
            
        if (!s_statusBarImage) {
            s_statusBarImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"StatusBarBackground"]];
        }            

        if (!s_statusLockImage) {
            s_statusLockImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"statusLockedSelected"]];
            s_statusLockGreyImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"statusLocked"]];
        }            

        if ([NSBundle loadNibNamed:@"SpawnView" owner:self])
        {
            [_rdStatusBar setBackgroundImage:s_statusBarImage];
            [self updateStatusBar];
        
            [[RDNestedViewManager manager] addView:self];
            [_rdInputView setBackgroundColor:_rdBackgroundColor];
            [_rdInputView setTextColor:[NSColor colorWithCalibratedRed:0.8f green:0.8f blue:0.8f alpha:1.0f]];
            [_rdInputView setInsertionPointColor:_rdInputColor];
            [_rdInputView setDelegate:self];
            [_rdInputView setFont:_rdFont];
            [_rdOutputView setMaxLines:_rdLines];
            [_rdOutputView setBackgroundColor:_rdBackgroundColor];
            [_rdOutputView setTextColor:_rdInputColor];
            [_rdOutputView setFont:_rdFont];
            [_rdOutputView turnOffKerning:self];
            [_rdOutputView turnOffLigatures:self];
            [_rdInputView setAutomaticDashSubstitutionEnabled:NO];
            [_rdInputView setAutomaticSpellingCorrectionEnabled:NO];
            [_rdInputView setAutomaticTextReplacementEnabled:NO];
            [_rdInputView setAutomaticQuoteSubstitutionEnabled:NO];
            [_rdInputView setAutomaticLinkDetectionEnabled:NO];
            [_rdInputView turnOffKerning:self];
            [_rdInputView turnOffLigatures:self];

            if ([_rdOutputView respondsToSelector:@selector(setAllowsNonContiguousLayout:)]) {
                [(id)_rdOutputView setAllowsNonContiguousLayout:YES];
            }
            
            [_rdSplitView setAutosaveName:[self viewPath] recursively:NO];
            [_rdSplitView restoreState:YES];
            
            NSImage *tempImage = [[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"spawn-dimple"]] autorelease];
            [_rdSplitView setDivider:tempImage];
            
            tempImage = [[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"spawn-splitter"]] autorelease];
            [tempImage setFlipped:YES];
            [_rdSplitView setDividerBackground:tempImage];
            [_rdSplitView setDividerThickness:8.0f];

            _rdResizeTooltip = [[NSPanel alloc] initWithContentRect:NSMakeRect(0,0,100,25)
                                                           styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
            [_rdResizeTooltip setFloatingPanel:YES];
            [_rdResizeTooltip setHidesOnDeactivate:NO];
            [_rdResizeTooltip setBackgroundColor:[NSColor colorWithCalibratedRed:1.000 green:1.000 blue:0.800 alpha:1.0]];
            [_rdResizeTooltip setAlphaValue:0.9];
            [_rdResizeTooltip setHasShadow:YES];	
            
            _rdResizeTextfield = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,100,25)];
            [_rdResizeTextfield setFont:[NSFont labelFontOfSize:11]];
            [_rdResizeTextfield setBordered:NO];
            [_rdResizeTextfield setBezeled:NO];
            [_rdResizeTextfield setSelectable:NO];
            [_rdResizeTextfield setDrawsBackground:NO];	
            
            [(NSView *)[_rdResizeTooltip contentView] addSubview:_rdResizeTextfield];            
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(worldConnected:) name:@"RDAtlantisConnectionDidConnectNotification" object:instance];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(worldDisconnected:) name:@"RDAtlantisConnectionDidDisconnectNotification" object:instance];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(worldChangedConfig:) name:@"RDAtlantisConnectionDidRefreshConfigNotification" object:instance];            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputViewFrameChanged:) name:@"NSSplitViewDidResizeSubviewsNotification" object:_rdSplitView];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputViewFrameChanged:) name:@"NSViewFrameDidChangeNotification" object:[_rdOutputView enclosingScrollView]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarSettingChanged:) name:@"RDAtlantisStatusBarDidChangeNotification" object:nil];
            
            [_rdOutputView setTooltipDelegate:self];

            [self setStatusBarBottom:[[RDAtlantisMainController controller] statusBarBottom]];            
            
            [self outputViewFrameChanged:nil];
        }
        
        _rdWorld = [instance retain];
        _rdInternalPath = nil;
        [self refreshPreferencesFrom:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_rdResizeTooltip release];
    [_rdResizeTextfield release];
    [_rdSpawnPrefix release];
    [_rdConsoleColor release];
    [_rdInputColor release];
    [_rdBackgroundColor release];
    [_rdSubviews release];
    [_rdWorld release];
    [_rdFont release];
    [_rdPath release];
    [_rdName release];
    [_rdUID release];
    [_rdInternalPath release];
    [_rdActiveExceptions release];
    [super dealloc];
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<RDAtlantisSpawn: %@ (%u)>", _rdPath, _rdWeight];
}

#pragma mark NAWS Support

- (void) hideTooltip
{
    [_rdResizeTooltip orderOut:self];
}

- (void) displayTooltip
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTooltip) object:nil];

    NSString *screenDescription = [NSString stringWithFormat:@"%d cols x %d rows", _rdScreenWidth, _rdScreenHeight];
    [_rdResizeTextfield setStringValue:screenDescription];
    [_rdResizeTextfield sizeToFit];
    
    NSRect tooltipRect;
    
	NSPoint mouseLoc;	
	mouseLoc = [NSEvent mouseLocation];
    tooltipRect.origin = mouseLoc;
    tooltipRect.origin.x += 10;
    tooltipRect.size = [_rdResizeTextfield bounds].size;

    [_rdResizeTooltip setFrame:tooltipRect display:YES];
    [_rdResizeTooltip orderFront:self];
    
    [self performSelector:@selector(hideTooltip) withObject:nil afterDelay:2];
}

- (BOOL) shouldShowTooltipFor:(RDTextView *)view
{
    if (view == _rdOutputView) {
        if ([[RDNestedViewManager manager] currentFocusedView] == self)
            return YES;
        else
            return NO;
    }
    
    return NO;
}

- (void) updateStatusBar
{
    NSString *connectTime;
    
    if (![_rdWorld isConnected])
        connectTime = @"offline";
    else {
        NSDate *then = [_rdWorld connectedSince];
        NSDate *now = [NSDate date];
        
        if (then) {
            NSTimeInterval connectedFor = [now timeIntervalSinceDate:then];
            unsigned int total = connectedFor;
            unsigned char secs = total % 60;
            total = total / 60;
            unsigned char mins = total % 60;
            total = total / 60;
        
            connectTime = [NSString stringWithFormat:@"%02d:%02d:%02d", total, mins, secs];
        }
        else 
            connectTime = @"00:00:00";    
            
    }
    [_rdTimerField setStringValue:connectTime];

    NSString *encoding = @"default";
    if ([_rdWorld stringEncoding] != -1) {
        encoding = [NSString localizedNameOfStringEncoding:[_rdWorld stringEncoding]];
        if (![encoding length])
            encoding = @"unknown";
    }
        
    NSString *dimensions = [NSString stringWithFormat:@"%dx%d", _rdScreenWidth, _rdScreenHeight];
    
    NSMutableString *tooltip = [[NSString stringWithFormat:@"World is %@\n%@ encoding\n%@ screen size", [_rdWorld isConnected] ? @"online" : @"offline",
                                            encoding, dimensions] mutableCopy];

    if ([_rdWorld isSSL]) {
        [_rdSSLImage setImage:s_statusLockImage];
        [tooltip appendString:@"\nSSL encryption enabled"];
    }
    else {
        [_rdSSLImage setImage:s_statusLockGreyImage];
    }
                                            
    if ([_rdWorld isCompressing]) {
        [tooltip appendString:@"\nNetwork compression enabled"];
    }
    if ([_rdWorld supportsMCP]) {
        [tooltip appendString:@"\nMCP extensions enabled"];
    }

    [_rdStatusBar setToolTip:tooltip];
    [tooltip release];
}

- (void) setStatusBarHidden:(BOOL) hidden
{
    if (hidden == [self statusBarHidden])
        return;

    float heightChange = [_rdStatusBar frame].size.height;
    if (!hidden)
        heightChange *= -1;

    NSView *mainView = _rdSplitView;
    NSRect mainFrame = [mainView frame];
    NSSize oldSize = mainFrame.size;
    mainFrame.size.height += heightChange;
    [_rdStatusBar setHidden:hidden];

    if ([self statusBarBottom]) {
        mainFrame.origin.y = hidden ? 0 : [_rdStatusBar frame].size.height;
    }

    [mainView setFrame:mainFrame];
    [mainView resizeSubviewsWithOldSize:oldSize];
    [_rdStatusBar setNeedsDisplay:YES];
    [[self view] setNeedsDisplay:YES];
}

- (BOOL) statusBarHidden
{
    return [_rdStatusBar isHidden];
}

- (void) setStatusBarBottom:(BOOL) bottom
{
    if (bottom != _rdStatusBarBottom) {
        NSRect statusFrame = [_rdStatusBar frame];
        NSRect mainFrame = [_rdSplitView frame];
        _rdStatusBarBottom = bottom;

        if (![self statusBarHidden]) {
            if (bottom) {
                statusFrame.origin.y = 0;
                mainFrame.origin.y += statusFrame.size.height;
                [_rdStatusBar setAutoresizingMask:(NSViewWidthSizable | NSViewMaxYMargin)];
                [_rdStatusBar setFrame:statusFrame];
                [_rdSplitView setFrame:mainFrame];
                [_rdStatusBar setNeedsDisplay:YES];
                [[self view] setNeedsDisplay:YES];
            }
            else {
                mainFrame.origin.y = 0;
                statusFrame.origin.y = [[self view] frame].size.height - statusFrame.size.height;
                [_rdStatusBar setAutoresizingMask:(NSViewWidthSizable | NSViewMinYMargin)];
                [_rdStatusBar setFrame:statusFrame];
                [_rdSplitView setFrame:mainFrame];
                [_rdStatusBar setNeedsDisplay:YES];
                [[self view] setNeedsDisplay:YES];
            }
        }
    }
}

- (BOOL) statusBarBottom
{
    return _rdStatusBarBottom;
}


- (void) setStatusBarUserText:(NSAttributedString *) text
{
    [_rdStatusField setAttributedStringValue:text];
}

- (NSString *) statusBarUserText
{
    return [_rdStatusField stringValue];
}

- (void) outputViewFrameChanged:(NSNotification *) notification
{
    NSSize advance = [_rdFont maximumAdvancement];
    float lineheight = [[_rdOutputView layoutManager] defaultLineHeightForFont:_rdFont];
    
    NSRect fontRect = [_rdFont boundingRectForFont];
    
    float cellwidth = (fontRect.size.width + fontRect.origin.x);
    
    int oldWidth = _rdScreenWidth;
    int oldHeight = _rdScreenHeight;
    
    NSRect outputRect = [_rdOutputView visibleRect];
    float extraTextPadding = [[_rdOutputView textContainer] lineFragmentPadding];
    NSSize textContainerInset = [_rdOutputView textContainerInset];

    NSSize viewSize = outputRect.size;
    viewSize.width -= textContainerInset.width * 2;
    viewSize.width -= extraTextPadding * 2;

    _rdScreenWidth = (int)roundf((viewSize.width / roundf(cellwidth)));
    _rdScreenHeight = (int)truncf((viewSize.height / lineheight));
    
    if (_rdScreenWidth < 1)
        _rdScreenWidth = 1;
    if (_rdScreenHeight < 1)
        _rdScreenHeight = 1;
        
    if (_rdShowTimestamps)
        _rdScreenWidth -= 11;

    if ((oldWidth != _rdScreenWidth) || (oldHeight != _rdScreenHeight)) {
        if ([_rdPath isEqualToString:[_rdWorld basePath]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RDAtlantisMainScreenDidChangeNotification" object:_rdWorld];
        }
        
        NSEvent *currentEvent = [NSApp currentEvent];
        if ([currentEvent type] != NSLeftMouseDragged)
            return;
     
        [self displayTooltip];
    }
    [_rdStatusBar setNeedsDisplay:YES];
    [self updateStatusBar];
}

- (void) statusBarSettingChanged:(NSNotification *) notification
{
    [self setStatusBarBottom:[[RDAtlantisMainController controller] statusBarBottom]];
    BOOL killstatus = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.statusbar.kill"];
    if (killstatus) {
        [self setStatusBarHidden:YES];
    }
    else {
        [self worldChangedConfig:nil];
    }
}

#pragma mark Nested View Protocol

- (NSView *) view
{
    return _rdSpawnContentView;
}

- (NSString *) viewUID
{
    return _rdUID;
}

- (NSString *) viewPath
{
    return _rdPath;
}

- (NSString *) viewName
{
    return _rdName;
}

- (NSUInteger) viewWeight
{
    return _rdWeight;
}

- (NSImage *) viewIcon
{
    BOOL isMain = [_rdPath isEqualToString:[_rdWorld basePath]];

    if (isMain) {
        if (_rdWorldIcon) {
            return _rdWorldIcon;
        }
        else {
            if (!s_globeImage) {
                s_globeImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"connect"]];
            }
            return s_globeImage;
        }
    }
    else {
        if (!s_spawnImage) {
            s_spawnImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"terminal"]];
        }
        return s_spawnImage;    
    }
}

extern NSInteger compareViews(id view1, id view2, void *context);

- (BOOL) addSubview:(id <RDNestedViewDescriptor>) aView
{
    [_rdSubviews addObject:aView];
    [_rdSubviews sortUsingFunction:compareViews context:nil];
    return YES;
}

- (BOOL) removeSubview:(id <RDNestedViewDescriptor>) aView
{
    [_rdSubviews removeObject:aView];
    return YES;
}

- (void) sortSubviews
{
    NSEnumerator *subEnum = [_rdSubviews objectEnumerator];
    id <RDNestedViewDescriptor> walk;
    
    while (walk = [subEnum nextObject]) {
        [walk sortSubviews];
    }
    [_rdSubviews sortUsingFunction:compareViews context:nil];
}

- (NSArray *) subviewDescriptors
{
    return _rdSubviews;
}

- (BOOL) isFolder
{
    if ([_rdSubviews count] != 0)
        return YES;
    else
        return NO;
}

- (BOOL) isLive
{
    NSEnumerator *subviewEnum = [_rdSubviews objectEnumerator];
    
    id <RDNestedViewDescriptor> walk;
    
    BOOL result = NO;
    
    while (!result && (walk = [subviewEnum nextObject])) {
        result = [walk isLive];
    }
    
    if (!result)
        result = [self isLiveSelf];
        
    return result;
}

- (BOOL) isLiveSelf
{
    return [_rdWorld isConnected];
}

- (void) close
{
    BOOL isMain = [_rdPath isEqualToString:[_rdWorld basePath]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (isMain) {
        [_rdWorld closeAndRemove];
    }
    else {
        [_rdWorld spawnWasClosed:self];
    }
}

- (NSString *) closeInfoString
{
    // TODO: Get localized versions of actual information based on world instance state
    BOOL isMain = [_rdPath isEqualToString:[_rdWorld basePath]];
    
    if (isMain)
        // TODO: Localize
        return @"Closing this view will disconnect this world, and close its other views.";
    else
        // TODO: Localize
        return @"";
}

- (void) viewWasFocused
{
    if (![NSApp isActive])
        return;

    [[_rdInputView window] makeFirstResponder:_rdInputView];        
    
    [_rdOutputView testForCustomTooltip];
}

- (void) viewWasUnfocused
{
    [_rdOutputView hideCustomTooltip];
}

#pragma mark General Spawn Management

- (void) refreshPreferencesFrom:(RDSpawnConfigRecord *) prefs
{
    [_rdOutputView commit];

    BOOL killstatus = [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.statusbar.kill"];

    if (prefs) {
        _rdWeight = [prefs weight];
        _rdLines = [prefs maxLines];
        _rdDefaultsActive = [prefs defaultActive];
        [_rdActiveExceptions release];
        _rdActiveExceptions = nil;
        if ([prefs activeExceptions])
            _rdActiveExceptions = [[NSArray arrayWithArray:[prefs activeExceptions]] retain];
        if (_rdOutputView)
            [_rdOutputView setMaxLines:_rdLines];
        if ([prefs prefix]) {
            [_rdSpawnPrefix release];
            _rdSpawnPrefix = [[prefs prefix] retain];
        }
        if (!killstatus)
            [self setStatusBarHidden:![prefs statusBar]];
        else
            [self setStatusBarHidden:YES];
    }
    
    if (_rdWorld) {
        NSColor *tempColor = [_rdWorld preferenceForKey:@"atlantis.colors.background"];
        if (tempColor) {
            [_rdBackgroundColor release];
            _rdBackgroundColor = [tempColor retain];
            [_rdOutputView setEditable:YES];
            [_rdOutputView setBackgroundColor:_rdBackgroundColor];
            [_rdOutputView setEditable:NO];
            [_rdInputView setBackgroundColor:_rdBackgroundColor];
        }

        tempColor = [_rdWorld preferenceForKey:@"atlantis.colors.default"];
        
        if (!tempColor) {
            NSArray *ansiColors = [_rdWorld preferenceForKey:@"atlantis.colors.ansi"];
            if (ansiColors) {
                tempColor = [ansiColors objectAtIndex:7];
            }
        }
        if (tempColor) {
            [_rdInputColor release];
            _rdInputColor = [tempColor retain];
            [_rdInputView setTextColor:_rdInputColor];
            [_rdInputView setInsertionPointColor:_rdInputColor];
        }

        tempColor = [_rdWorld preferenceForKey:@"atlantis.colors.selection"];
        if (tempColor) {    
            NSDictionary *selectDict =
            [NSDictionary dictionaryWithObjectsAndKeys:
                tempColor,NSBackgroundColorAttributeName,
                nil];
            [_rdInputView setSelectedTextAttributes:selectDict];
            [_rdOutputView setSelectedTextAttributes:selectDict];
        }
        
        
        tempColor = [_rdWorld preferenceForKey:@"atlantis.colors.system"];
        if (tempColor) {
            [_rdConsoleColor release];
            _rdConsoleColor = [tempColor retain];
        }
        
        NSFont *font = [_rdWorld displayFont];
        if (font && (font != _rdFont)) {
            [self setFont:font];
        }
        
        _rdShowTimestamps = [[_rdWorld preferenceForKey:@"atlantis.formatting.timestamps"] boolValue];
        
        _rdWorldIcon = [_rdWorld preferenceForKey:@"atlantis.info.icon"];        
    }
}

- (void) worldChangedConfig:(NSNotification *) notification
{
    RDSpawnConfigRecord *tempSpawn = [_rdWorld configForSpawn:_rdInternalPath];
    
    if (tempSpawn)
        [self refreshPreferencesFrom:tempSpawn];
}

- (NSString *) prefix
{
    return _rdSpawnPrefix;
}

- (void) setPrefix:(NSString *)prefix
{
    [_rdSpawnPrefix release];
    _rdSpawnPrefix = [prefix retain];
}

- (void) textView:(NSTextView *)view committedInput:(NSAttributedString *)input
{
    if (view == _rdInputView) {
        NSMutableAttributedString *finalInput = [input mutableCopy];
        if (_rdSpawnPrefix) {
            if (([finalInput length] < [_rdSpawnPrefix length]) || ![[[finalInput string] substringWithRange:NSMakeRange(0,[_rdSpawnPrefix length])] isEqualToString:_rdSpawnPrefix]) {
                if ([_rdSpawnPrefix length] && ([_rdSpawnPrefix characterAtIndex:([_rdSpawnPrefix length] - 1)] != ' '))
                    [finalInput replaceCharactersInRange:NSMakeRange(0,0) withString:@" "];
                [finalInput replaceCharactersInRange:NSMakeRange(0,0) withString:_rdSpawnPrefix];
            }
        }
        [_rdWorld handleLocalInput:finalInput onSpawn:self];
        [finalInput release];
    }
}

- (void) searchForString:(id) sender
{
    [_rdOutputView searchForString:sender];
}

- (void) clearSearchString:(id) sender
{
    [_rdOutputView clearSearchString:sender];
}

- (void) stringIntoInput:(NSString *)string
{
    NSMutableString *mutString = [[_rdInputView textStorage] mutableString];
    [mutString setString:string];
    [_rdInputView setBackgroundColor:_rdBackgroundColor];
    [_rdInputView setTextColor:_rdInputColor];
    [_rdInputView setInsertionPointColor:_rdInputColor];
    [_rdInputView setFont:_rdFont];
}

- (void) stringInsertIntoInput:(NSString *) string
{
    if (string)
        [_rdInputView insertText:string];
}

- (NSString *) stringFromInput
{
    return [[_rdInputView textStorage] string];
}

- (NSString *) stringFromInputSelection
{
    NSRange selectedRange = [_rdInputView selectedRange];
    if (selectedRange.length != 0) {
        NSString *selectedString = [[[_rdInputView textStorage] string] substringWithRange:selectedRange];
        return selectedString;
    }
    else
        return nil;
}

- (NSString *) stringFromOutputSelection
{
    NSRange selectedRange = [_rdOutputView selectedRange];
    if (selectedRange.length != 0) {
        NSString *selectedString = [[[_rdOutputView textStorage] string] substringWithRange:selectedRange];
        return selectedString;
    }
    else
        return nil;
}

- (void) appendStringNoTimestamp:(NSAttributedString *)string
{
    NSRange effRange;

    if (![string length]) 
        return;
        
    NSDictionary *attrs = [string attributesAtIndex:0 effectiveRange:&effRange];
    if ([attrs objectForKey:@"RDScreenOmitLine"])
        return;
    
    [_rdOutputView appendString:string];
}

- (void) ensureNewline
{
    if (!_rdLastNewline) {
        NSAttributedString *tempString = [[NSAttributedString alloc] initWithString:@"\n"];
        [_rdOutputView appendString:tempString];
        [tempString release];
        _rdLastNewline = YES;
    }
}

- (void) appendString:(NSAttributedString *)string
{
    NSRange effRange;
    
    if (![string length])
        return;
    
    NSDictionary *attrs = [string attributesAtIndex:0 effectiveRange:&effRange];
    if ([attrs objectForKey:@"RDScreenOmitLine"])
        return;
        
    if (!_rdHasText) {
        _rdHasText = YES;
        [self outputViewFrameChanged:nil];
    }

    if (_rdShowTimestamps && _rdLastNewline) {
        NSString *dateString = [[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"[%H:%M:%S] "];
        NSMutableAttributedString *dateAttrString = [[NSMutableAttributedString alloc] initWithString:dateString attributes:[NSDictionary dictionaryWithObjectsAndKeys:_rdFont,NSFontAttributeName,[[self world] paragraphStyle],NSParagraphStyleAttributeName,[NSNumber numberWithBool:YES],@"RDOmitSpan",_rdConsoleColor,NSForegroundColorAttributeName,_rdBackgroundColor,NSBackgroundColorAttributeName,nil]];
        
        [dateAttrString appendAttributedString:string];
        [_rdOutputView appendString:dateAttrString];
        [dateAttrString release];
    }
    else         
        [_rdOutputView appendString:string];

    NSString *testString = [string string];
    if ([testString length]) {
        if ([testString characterAtIndex:[testString length] - 1] == '\n') {
            _rdLastNewline = YES;
        }
        else {
            _rdLastNewline = NO;
        }
    }        
}

- (BOOL) wantsActiveFor:(NSString *)string
{
    BOOL result = _rdDefaultsActive;

    if (_rdActiveExceptions) {
        NSEnumerator *patternEnum = [_rdActiveExceptions objectEnumerator];
        
        RDStringPattern *patternWalk;
        
        while ((result == _rdDefaultsActive) && (patternWalk = [patternEnum nextObject])) {
            if ([patternWalk patternMatchesString:string]) 
                result = !_rdDefaultsActive;
        }
    }
    
    return result;
}

- (void) setInternalPath:(NSString *)path
{
    [_rdInternalPath release];
    if (path)
        _rdInternalPath = [path retain];
}

- (NSString *) internalPath
{
    return _rdInternalPath;
}

- (void) setFont:(NSFont *)font
{
    [_rdInputView setFont:font];
    [_rdOutputView setFont:font];
    if (_rdFont)
        [_rdFont release];
    _rdFont = [font retain];
}

- (void) setParagraphStyle:(NSParagraphStyle *)paraStyle
{
    [_rdOutputView setDefaultParagraphStyle:paraStyle];
}

- (void) setLinkStyle:(NSDictionary *)linkAttrs
{
    [_rdOutputView setLinkTextAttributes:linkAttrs];
}

- (void) worldConnected:(NSNotification *)notification
{
//    [_rdConnectButton setState:NSOnState];
}

- (void) worldDisconnected:(NSNotification *)notification
{
//    [_rdConnectButton setState:NSOffState];
}

- (RDAtlantisWorldInstance *) world
{
    return _rdWorld;
}

- (NSArray *) scrollbackData
{
    return [[_rdOutputView textStorage] paragraphs];
}

- (int) screenWidth
{
    return _rdScreenWidth;
}

- (int) screenHeight
{
    return _rdScreenHeight;
}

- (void) clearScrollback
{
    [_rdOutputView clearTextView];
}

@end
