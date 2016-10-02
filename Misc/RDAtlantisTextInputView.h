/* RDAtlantisTextInputView */

#import <Cocoa/Cocoa.h>

@interface RDAtlantisTextInputView : NSTextView
{
    IBOutlet NSTextView *               passInputsTo;
    
    NSCursor *                          _rdBaseCursor;
}
@end
