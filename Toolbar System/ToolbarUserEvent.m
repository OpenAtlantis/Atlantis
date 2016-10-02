//
//  ToolbarUserEvent.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ToolbarUserEvent.h"
#import "AtlantisState.h"


@implementation ToolbarUserEvent

NSString *generateToolbarUUID()
{
    CFUUIDRef   uuid;
    CFStringRef string;
 
    uuid = CFUUIDCreate( NULL );
    string = CFUUIDCreateString( NULL, uuid );
    
    NSString *result = [NSString stringWithString:(NSString *)string];
    CFRelease(string);

    return (NSString *)result;
}

- (id) init
{
    self = [super init];
    if (self) {
        _rdToolbarIcon = nil;
        _rdToolbarItem = nil;
        _rdUUID = generateToolbarUUID();
        _rdToolbarItemDict = [[NSMutableDictionary alloc] init];
        [_rdUUID retain];
        _rdDirty = YES;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSImage *temp = [coder decodeObjectForKey:@"toolbar.icon"];
        if (temp) {
            _rdToolbarIcon = [temp retain];
        }
        _rdUUID = [[coder decodeObjectForKey:@"toolbar.uuid"] retain];
        _rdToolbarItemDict = [[NSMutableDictionary alloc] init];
        _rdToolbarItem = nil;
        _rdDirty = YES;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_rdUUID forKey:@"toolbar.uuid"];
    if (_rdToolbarIcon)
        [coder encodeObject:_rdToolbarIcon forKey:@"toolbar.icon"];
}

- (void) dealloc
{
    [_rdToolbarItemDict release];
    [_rdToolbarItem release];
    [_rdToolbarIcon release];
    [_rdUUID release];
    [super dealloc];
}

#pragma mark Event Data

- (id) eventExtraData:(NSString *) dataName
{
    if ([dataName isEqualToString:@"eventIcon"])
        return _rdToolbarIcon;
        
    return nil;
}

- (void) eventSetExtraData:(id) data forName:(NSString *) dataName
{
    if ([dataName isEqualToString:@"eventIcon"]) {
        NSImage *newIcon = (NSImage *)[data retain];
        [_rdToolbarIcon release];
        _rdToolbarIcon = newIcon;
        _rdDirty = YES;        
    }
}

- (void) eventSetName:(NSString *) name
{
    [super eventSetName:name];
    _rdDirty = YES;
}

- (void) eventSetDescription:(NSString *) desc
{
    [super eventSetDescription:desc];
    _rdDirty = YES;
}

- (BOOL) eventCanEditExtraDataSpecial
{
    return YES;
}

- (void) eventEditExtraDataHook:(NSString *) dataName
{
    if ([dataName isEqualToString:@"eventIcon"]) {
        _rdDirty = YES;
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        
        NSString *imagePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"atlantis.image.path"];
        if (!imagePath) {
            imagePath = @"~/Pictures";
            imagePath = [imagePath stringByExpandingTildeInPath];
        }
        
        [panel setAllowsMultipleSelection:NO];
        int result = [panel runModalForDirectory:imagePath file:nil];
        if (result == NSOKButton) {
            NSString *directory = [panel directory];
            NSString *filename = [panel filename];
            
            [[NSUserDefaults standardUserDefaults] setObject:directory forKey:@"atlantis.image.path"];
            NSImage *image = [[NSImage alloc] initByReferencingFile:filename];
            if (image) {
                [_rdToolbarIcon release];
                _rdToolbarIcon = image;
            }
        }
    }
}

#pragma mark Toolbar Option Protocol

- (BOOL) validForState:(AtlantisState *) state
{
    if ([[self eventConditions] count] == 0)
        return YES;

    return [self shouldExecute:state];
}

- (void) activateWithState:(AtlantisState *) state
{
    [self executeForState:state];
}

- (NSToolbarItem *) toolbarItemForState:(AtlantisState *)state
{
    NSToolbarItem *item = nil;
    
    if (!state) {
        if (!_rdToolbarItem) {
            _rdToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:[self toolbarItemIdentifier]];
            _rdDirty = YES;
        }
        item = _rdToolbarItem;        
    }
    else {
        NSString *windowUID = [state extraDataForKey:@"application.windowUID"];
        if (windowUID) {
            item = [_rdToolbarItemDict objectForKey:windowUID];
            if (!item) {
                item = [[NSToolbarItem alloc] initWithItemIdentifier:[self toolbarItemIdentifier]];
                [_rdToolbarItemDict setObject:item forKey:windowUID];
                _rdDirty = YES;
//                [item autorelease];
            }
        }
    }
    
    if (item) {
        [item setLabel:[self eventName]];
        [item setPaletteLabel:[self eventDescription]];
        [item setImage:_rdToolbarIcon];
        _rdDirty = FALSE;
    }
    
    return item;
}

- (NSString *) toolbarItemIdentifier
{
    return _rdUUID;
}

@end
