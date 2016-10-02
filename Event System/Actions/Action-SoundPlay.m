//
//  Action-SoundPlay.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/9/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-SoundPlay.h"


@implementation Action_SoundPlay


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Sound: Play Sound";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Play a WAV, AIFF or SND file.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeEvent))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (id) init
{
    self = [super init];
    if (self) {
        _rdSound = nil;
        _rdSoundFilename = nil;
        _rdPanelIsOpen = NO;
    }
    return self;
}

- (void) dealloc
{
    [_rdSound release];
    [_rdSoundFilename release];
    [super dealloc];
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdSoundFilename = [[coder decodeObjectForKey:@"action.sound"] retain];
        
        if (_rdSoundFilename) {
            _rdSound = [[NSMovie alloc] initWithURL:[NSURL fileURLWithPath:_rdSoundFilename] byReference:YES];
        }
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    if (_rdSoundFilename)
        [coder encodeObject:_rdSoundFilename forKey:@"action.sound"];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    if (!_rdSound && _rdSoundFilename) {
        _rdSound = [[NSMovie alloc] initWithURL:[NSURL fileURLWithPath:_rdSoundFilename] byReference:YES];
    }

    if (_rdSound && (IsMovieDone([_rdSound QTMovie]) || !GetMovieActive([_rdSound QTMovie]))) {
        GoToBeginningOfMovie([_rdSound QTMovie]);
        StartMovie([_rdSound QTMovie]);
    }

    return NO;
}

- (NSView *) actionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"ActionConf_PlaySound" owner:self];
    }

    if (_rdSoundFilename)
        [_rdSoundFilenameField setStringValue:_rdSoundFilename];
        
    return _rdInternalConfigurationView;
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
    if (returnCode == NSOKButton) {
        [[NSUserDefaults standardUserDefaults] setObject:[panel directory] forKey:@"action.sound.lastDirectory"];
        
        [_rdSoundFilename release];
        _rdSoundFilename = [[panel filename] retain];
        [_rdSound release];
        _rdSound = [[NSMovie alloc] initWithURL:[NSURL fileURLWithPath:_rdSoundFilename] byReference:YES];
        [_rdSoundFilenameField setStringValue:_rdSoundFilename];
    }    
    
    _rdPanelIsOpen = NO;
}


- (void) browseForFile:(id) sender
{
    if (_rdPanelIsOpen)
        return;
        
    NSString *lastPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"action.sound.lastDirectory"];
        
    if (!lastPath)
        lastPath = @"~/Documents";
        
    lastPath = [lastPath stringByExpandingTildeInPath];
        
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    NSArray *allowed = [NSArray arrayWithObjects:@"wav",@"aif",@"aiff",@"snd",@"mp3",@"aac",nil];
    _rdPanelIsOpen = YES;
    [panel beginSheetForDirectory:lastPath file:nil types:allowed modalForWindow:[_rdInternalConfigurationView window] modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

@end
