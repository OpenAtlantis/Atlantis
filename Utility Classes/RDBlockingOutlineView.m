//
//  RDBlockingOutlineView.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/13/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDBlockingOutlineView.h"

@interface RDBlockingOutlineView (Private)
- (BOOL) outlineView:(NSOutlineView *)outlineView clickedItem:(id) item inColumn:(NSTableColumn *)tableColumn;
- (void) outlineView:(NSOutlineView *)outlineView cannotHandleEvent:(NSEvent *)event;
@end

@implementation RDBlockingOutlineView

// make return and tab only end editing, and not cause other cells to edit

- (void) textDidEndEditing: (NSNotification *) notification
{
    NSDictionary *userInfo = [notification userInfo];

    int textMovement = [[userInfo valueForKey:@"NSTextMovement"] intValue];

    if (textMovement == NSReturnTextMovement
        || textMovement == NSTabTextMovement
        || textMovement == NSBacktabTextMovement) {

        NSMutableDictionary *newInfo;
        newInfo = [NSMutableDictionary dictionaryWithDictionary: userInfo];

        [newInfo setObject: [NSNumber numberWithInt: NSIllegalTextMovement]
                 forKey: @"NSTextMovement"];

        notification =
            [NSNotification notificationWithName: [notification name]
                                       object: [notification object]
                                       userInfo: newInfo];

    }

    [super textDidEndEditing: notification];
    [[self window] makeFirstResponder:self];

} // textDidEndEditing

- (void) mouseDown:(NSEvent *)theEvent
{
	NSEvent *nextEvent = [NSApp
		nextEventMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseUpMask
					untilDate:[NSDate distantFuture] // or perhaps some reasonable time-out
					   inMode:NSEventTrackingRunLoopMode
					  dequeue:NO];	// don't dequeue in case it's not a drag
	
	if ([nextEvent type] != NSLeftMouseDragged) {
        BOOL blockMe = NO;
        
        if ([nextEvent type] == NSLeftMouseUp) {
            NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            
            int row = [self rowAtPoint:clickPoint];
            int col = [self columnAtPoint:clickPoint];
            if (row != -1) {
                if ([[self delegate] respondsToSelector:@selector(outlineView:clickedItem:inColumn:)])
                    blockMe = [[self delegate] outlineView:self clickedItem:[self itemAtRow:row] inColumn:[[self tableColumns] objectAtIndex:col]];
            }
        }
        
        if (!blockMe)
            [super mouseDown:theEvent];
    }
    else
        [super mouseDown:theEvent];

}

@end
