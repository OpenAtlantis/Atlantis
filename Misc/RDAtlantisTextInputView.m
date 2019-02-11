#import "RDAtlantisTextInputView.h"
#import "RDAtlantisApplication.h"

@protocol RDTextInputViewDelegate
- (void) textView:(NSTextView *)view committedInput:(NSAttributedString *)string;
@end

@implementation RDAtlantisTextInputView


- (id) initWithFrame:(NSRect) frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _rdBaseCursor = nil;
    }
    return self;
}

- (void) dealloc
{
    [_rdBaseCursor release];
    [super dealloc];
}

- (void) insertNewline:(id) sender
{ 
    BOOL rawEnter = YES;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent modifierFlags] & NSShiftKeyMask)
        rawEnter = NO;

    if (rawEnter && [[self delegate] respondsToSelector:@selector(textView:committedInput:)]) {
        NSAttributedString *currentString = [[NSAttributedString alloc] initWithAttributedString:[self textStorage]];
        [[self delegate] textView:self committedInput:currentString];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.text.retainOnCommit"]) {
            [self setSelectedRange:NSMakeRange(0,[[self textStorage] length])];
        }
        else
            [[self textStorage] setAttributedString:[[NSAttributedString alloc] init]];
    }
    else {
        [super insertNewline:sender];
    }
}

// TinyURL engine guts
- (NSString *) shrinkURL:(NSString *)input
{
    NSString *escaped = [(NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  (CFStringRef)input, NULL,  CFSTR(":/?=&+#"), kCFStringEncodingUTF8) autorelease];	
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@", escaped]];
    NSData *data = [url resourceDataUsingCache:YES];
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    return result;
}

- (BOOL) isURLSelected
{
    NSRange selected = [self selectedRange];
    if (!selected.length)
        return NO;
    
    NSString *urlString = [[[self textStorage] attributedSubstringFromRange:selected] string];
    if (([urlString length] > 8) && ([[[urlString substringToIndex:7] lowercaseString] isEqualToString:@"http://"] ||
        [[[urlString substringToIndex:8] lowercaseString] isEqualToString:@"https://"]))
        return YES;

    return NO;
}


- (void) replaceURL:(id) sender
{
    NSRange selected = [self selectedRange];
    if (!selected.length) {
        NSBeep();
        return;
    }
        
    NSString *urlString = [[[self textStorage] attributedSubstringFromRange:selected] string];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        NSBeep();
        return;
    }
    
    NSString *newURL = [self shrinkURL:urlString];
    if (newURL) {
        [[self textStorage] replaceCharactersInRange:selected withString:newURL];
    }
}

- (NSMenu *) menuForEvent:(NSEvent *) theEvent
{
    NSMenu *result = [super menuForEvent:theEvent];

    if (![self isURLSelected])
        return result;

    NSRange selected = [self selectedRange];
    if (!selected.length)
        return result;
    
    NSMenu *result2 = [result copy];
    NSMenuItem *shrinkItem = [[NSMenuItem alloc] initWithTitle:@"Shrink URL" action:@selector(replaceURL:) keyEquivalent:@""];
    [result2 insertItem:shrinkItem atIndex:0];
    [shrinkItem autorelease];
    [result2 autorelease];
    return result2;
}

- (void)recolorCursor
{
//    if ([RDAtlantisApplication isTiger]) {
        if (!_rdBaseCursor) {
            NSCursor *iBeam = [[NSCursor IBeamCursor] retain];
            NSImage *iBeamImg = [[iBeam image] copy];
            NSRect imgRect = {NSZeroPoint, [iBeamImg size]};
            [iBeamImg lockFocus];
            
            NSColor *tempBackground = [[self backgroundColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

            float backgroundRed = [tempBackground redComponent];
            float backgroundGreen = [tempBackground blueComponent];
            float backgroundBlue = [tempBackground greenComponent];
            
            NSColor *tempColor = [NSColor colorWithCalibratedRed:(1.0 - backgroundRed) green:(1.0 - backgroundGreen) blue:(1.0 - backgroundBlue) alpha:1.0];            
            [tempColor set];

            NSRectFillUsingOperation(imgRect,NSCompositeSourceAtop);
            [iBeamImg unlockFocus];
            _rdBaseCursor = [[NSCursor alloc] initWithImage:iBeamImg hotSpot:[iBeam hotSpot]];
            [_rdBaseCursor setOnMouseEntered:YES];
            [iBeam release];
            [iBeamImg release];
        }
        [[self enclosingScrollView] setDocumentCursor:_rdBaseCursor];
        [self addCursorRect:[self visibleRect] cursor:_rdBaseCursor];
//    }
}

- (void) setBackgroundColor:(NSColor *)color
{
    [super setBackgroundColor:color];
    [_rdBaseCursor release];
    _rdBaseCursor = nil;
    [self recolorCursor];
}

- (void)resetCursorRects
{
    [super resetCursorRects];
    [self recolorCursor];
}

- (void) mouseEntered:(NSEvent *)theEvent
{
    [self recolorCursor];
}

- (void) mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    [self recolorCursor];
}

- (void) mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
    [self recolorCursor];
}

- (void) doCommandBySelector:(SEL)selector
{
    if (passInputsTo && 
        ((selector == @selector(scrollPageUp:)) ||
         (selector == @selector(scrollPageDown:)) ||
         (selector == @selector(scrollToBeginningOfDocument:)) ||
         (selector == @selector(scrollToEndOfDocument:)))) {
        
        [passInputsTo doCommandBySelector:selector];
    }
    else
        [super doCommandBySelector:selector];
}

@end
