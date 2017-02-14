//
//  NSBezierPathExtensions.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/15/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (CocoaDevCategory)
+ (NSBezierPath *)bezierPathWithJaggedOvalInRect:(NSRect)r spacing:(float)spacing;
+ (NSBezierPath *)bezierPathWithJaggedPillInRect:(NSRect)r spacing:(float)spacing;
+ (NSBezierPath*)bezierPathWithRoundRectInRect:(NSRect)aRect radius:(float)radius;
+ (NSBezierPath *)bezierPathWithTriangleInRect:(NSRect)r edge:(NSRectEdge)edge;
@end
