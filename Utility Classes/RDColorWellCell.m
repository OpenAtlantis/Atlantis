#import "RDColorWellCell.h"

@implementation RDColorWellCell

- (void) awakeFromNib
{
    [self setSendsActionOnEndEditing:YES];
}

- (NSColor *) colorValue
{
    return [self representedObject];
}

- (void) setColorValue:(NSColor *)color
{
    if ([self representedObject]) {
        // er... yeah, something here, later.
    }
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (_rdCurrentColor) {
        [[NSColor blackColor] set];
        NSRect innerFrame = NSInsetRect(cellFrame,2,2);
        NSRectFill(innerFrame);
        [_rdCurrentColor set];
        innerFrame = NSInsetRect(cellFrame,3,3);
        NSRectFill(innerFrame);
    }
/*    else {
        NSMutableDictionary *stringAttributes;
        NSString *tempString = [NSString stringWithString:@"none"];

        stringAttributes = [NSMutableDictionary dictionaryWithCapacity:2];
        [stringAttributes setObject:[NSFont fontWithName:@"Monaco" size:12.0] forKey:NSFontAttributeName];
        [stringAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
        [tempString drawAtPoint:NSMakePoint( NSMinX(cellFrame) + 6, [controlView isFlipped] ? NSMaxY(cellFrame) - 15: NSMinY(cellFrame) + 4) withAttributes:stringAttributes];
    } */
}

- (void)setObjectValue:(id <NSCopying>)object
{
    if (_rdCurrentColor) {
        [_rdCurrentColor release];
    }
    
    _rdCurrentColor = [object copyWithZone:nil];
    [_rdCurrentColor retain];
}

@end
