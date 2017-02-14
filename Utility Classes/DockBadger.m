//
//  DockBadger.m
//  Atlantis
//
//  Created by Rachel Blackman on 6/25/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "DockBadger.h"
#import "NSBezierPathExtensions.h"

@implementation DockBadger

- (id) init
{
    self = [super init];
    if (self) {
        _rdActiveSpawns = 0;
        _rdBadgeString = nil;
        _rdBaseIcon = [[NSApp applicationIconImage] copy];
        
        NSShadow *tempShadow = [[NSShadow alloc] init];
        [tempShadow setShadowBlurRadius:4.0f];
        [tempShadow setShadowOffset:NSMakeSize(2.0,-2.0)];
        
        _rdTextAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSColor whiteColor], NSForegroundColorAttributeName,
            [NSFont fontWithName: @"Helvetica-Bold" size: 28.0], NSFontAttributeName,
            tempShadow, NSShadowAttributeName, nil];
            
        [tempShadow release];
        
    }
    return self;
}

- (void) dealloc
{
    [_rdBadgeString release];
    [_rdTextAttrs release];
    [_rdBaseIcon release];
    [super dealloc];
}

- (void) badgeWithActive:(int) active
{
    _rdActiveSpawns = active;
    [self refreshDockIcon];
}

- (void) badgeWithText:(NSString *) string
{
    [_rdBadgeString release];
    _rdBadgeString = [string retain];
    [self refreshDockIcon];
}

- (void) refreshDockIcon
{
    NSImage *dockImage = [_rdBaseIcon copy];
    [dockImage lockFocus];

    BOOL shouldDisplay = YES;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.badge.inactive"] == YES)
        shouldDisplay = ![NSApp isActive];

    if (shouldDisplay && (_rdActiveSpawns > 0)) {
        NSString *activeString = [NSString stringWithFormat:@"%d", _rdActiveSpawns];
        
        NSSize activeSize = [activeString sizeWithAttributes:_rdTextAttrs];
        NSRect activeRect = NSMakeRect(120 - activeSize.width - 10, 
                                       120 - activeSize.height, 
                                       activeSize.width + 5, 
                                       activeSize.height + 5);
                                       
        if (activeRect.size.width < activeRect.size.height) {
            activeRect.size.width = activeRect.size.height;
            activeRect.origin.x = 120 - activeSize.height - 10;
        }
        
#if 0
        int minX = NSMinX(activeRect);
        int midX = NSMidX(activeRect);
        int maxX = NSMaxX(activeRect);
        int minY = NSMinY(activeRect);
        int midY = NSMidY(activeRect);
        int maxY = NSMaxY(activeRect);
        
        float radius = 20.0;
        NSBezierPath *bgPath = [NSBezierPath bezierPath];
        
        // Bottom edge and bottom-right curve
        [bgPath moveToPoint:NSMakePoint(midX, minY)];
        [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) 
                                         toPoint:NSMakePoint(maxX, midY) 
                                          radius:radius];
        
        // Right edge and top-right curve
        [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) 
                                         toPoint:NSMakePoint(midX, maxY) 
                                          radius:radius];
        
        // Top edge and top-left curve
        [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) 
                                         toPoint:NSMakePoint(minX, midY) 
                                          radius:radius];
        
        // Left edge and bottom-left curve
        [bgPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY) 
                                         toPoint:NSMakePoint(midX, minY) 
                                          radius:radius];
        [bgPath closePath];
#else
        NSBezierPath *bgPath = [NSBezierPath bezierPathWithJaggedPillInRect:activeRect spacing:2.0f];

#endif
        
        
        // Draw solid color background
        [[NSColor redColor] set];
        [bgPath fill];  
        [[NSColor whiteColor] set];
        [bgPath setLineWidth:1.0f];
        [bgPath stroke];
        
        //string is in center of image
        NSRect rect = activeRect;
        rect.origin.x += (rect.size.width - activeSize.width) * 0.5;
        rect.origin.y += (rect.size.height - activeSize.height) * 0.5;
                        
        [activeString drawAtPoint: rect.origin withAttributes:_rdTextAttrs];
    }
    
    [dockImage unlockFocus];
    [NSApp setApplicationIconImage:dockImage];
    [dockImage release];
}

@end
