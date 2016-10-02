/* RDColorWellCell */

#import <Cocoa/Cocoa.h>

@interface RDColorWellCell : NSButtonCell
{
    NSColor*         _rdCurrentColor;
}

- (NSColor *) colorValue;
- (void) setColorValue:(NSColor *)color;
- (void)setObjectValue:(id <NSCopying>)object;

@end
