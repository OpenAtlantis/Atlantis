//
//  WorldNotesView.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/3/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import "WorldNotesView.h"

static NSImage *s_notebookImage = nil;

@implementation WorldNotesView

- (id) initForWorld:(RDAtlantisWorldInstance *)world
{
    if (self = [super init]) {
        _rdWorld = world;

        _rdPath = [[NSString alloc] initWithFormat:@"%@:Notepad", [_rdWorld basePath]];
        _rdUID = [[NSString stringWithFormat:@"Atlantis.notepad:%@", _rdPath] retain];        
        
        if ([NSBundle loadNibNamed:@"WorldNotepad" owner:self])
        {
            NSFont *font = [NSFont userFixedPitchFontOfSize:11.0f];
            
            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
        
            NSString *notesValue = [[_rdWorld preferences] preferenceForKey:@"atlantis.notes.default" withCharacter:[_rdWorld character] fallback:NO];
            if (notesValue) {
                NSAttributedString *notesTemp = [[[NSAttributedString alloc] initWithString:notesValue attributes:attrs] autorelease];
                [[_rdNotesText textStorage] setAttributedString:notesTemp];
            }
            else {
                NSAttributedString *notesTemp = [[[NSAttributedString alloc] initWithString:@"" attributes:attrs] autorelease];
                [[_rdNotesText textStorage] setAttributedString:notesTemp];
            }
            
            [_rdNotesText setFont:font];
            [_rdNotesText setDelegate:self];
            [[RDNestedViewManager manager] addView:self];
        }
    }
    
    return self;
}

#pragma mark Nested View Protocol

- (NSView *) view
{
    return _rdNotesView;
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
    return @"Notepad";
}

- (NSUInteger) viewWeight
{
    return 0;
}

- (NSImage *) viewIcon
{
    if (!s_notebookImage) {
        s_notebookImage = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"notebook"]];
    }
    return s_notebookImage;
}

extern int compareViews(id view1, id view2, void *context);

- (BOOL) addSubview:(id <RDNestedViewDescriptor>) aView
{
    return NO;
}

- (BOOL) removeSubview:(id <RDNestedViewDescriptor>) aView
{
    return NO;
}

- (void) sortSubviews
{
    // Do nothing
}

- (NSArray *) subviewDescriptors
{
    return nil;
}

- (BOOL) isFolder
{
    return NO;
}

- (BOOL) isLive
{
    return NO;
}

- (BOOL) isLiveSelf
{
    return NO;
}

- (void) close
{
    NSString *notesString = [[_rdNotesText textStorage] string];
    
    [[_rdWorld preferences] setPreference:notesString forKey:@"atlantis.notes.default" withCharacter:[_rdWorld character]];   
    [_rdWorld notesClose]; 
}

- (NSString *) closeInfoString
{
    return @"";
}

- (void)textDidEndEditing:(NSNotification *)aNotification
{
    NSString *notesString = [[_rdNotesText textStorage] string];
    
    [[_rdWorld preferences] setPreference:notesString forKey:@"atlantis.notes.default" withCharacter:[_rdWorld character]];    
}

- (void) viewWasFocused
{

}

- (void) viewWasUnfocused
{
    NSString *notesString = [[_rdNotesText textStorage] string];
    
    [[_rdWorld preferences] setPreference:notesString forKey:@"atlantis.notes.default" withCharacter:[_rdWorld character]];    
}


@end
