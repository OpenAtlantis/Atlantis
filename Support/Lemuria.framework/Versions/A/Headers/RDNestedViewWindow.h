/* RDNestedViewWindow */

#import <Cocoa/Cocoa.h>
#import <Lemuria/RDNestedViewCollection.h>
#import <Lemuria/RDNestedViewDisplay.h>

@interface RDNestedViewWindow : NSWindow
{
    NSString                *_rdWindowUID;
    BOOL                     _rdIsDragSource;
    BOOL                     _rdIsClosing;
}

- (id) initWithUID:(NSString*) uid contentRect:(NSRect) rect styleMask:(int) style backing:(NSBackingStoreType) backing defer:(BOOL)defer;

- (NSString *) windowUID;

- (void) setDisplayView:(NSView<RDNestedViewDisplay> *) displayView;
- (NSView <RDNestedViewDisplay> *) displayView;

- (BOOL) isDragSource;
- (void) setIsDragSource:(BOOL) isDrag;

- (BOOL) isClosing;
- (void) setIsClosing:(BOOL) isClosing;

@end
