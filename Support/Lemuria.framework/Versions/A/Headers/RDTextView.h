//
//  RDTextView.h
//  RDControlsTest
//
//  Created by Rachel Blackman on 9/17/05.
//  Copyright 2005 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RDTextView : NSTextView {

	NSPanel *				_rdRollOverWindow;
	NSTextField *           _rdRollOverText;
	NSTrackingRectTag       _rdRollOverTracker;
	
	unsigned				_rdMaxBufferLines;
	NSRect					_rdOldDocumentRect;
	NSRect					_rdOldVisibleRect;

    IBOutlet NSView *       _rdRedirectFocusOnKeyTo;

    NSString*               _rdLastSearch;
    unsigned long           _rdLastEndPos;
    
    unsigned                _rdTotalLines;
    float                   _rdHeightEaten;
    
    id                      _rdTooltipDelegate;
    
    NSCursor *              _rdBaseCursor;
    NSCursor *              _rdHandCursor;   
    
    BOOL                    _rdInEditBlock;
    NSDate *                _rdEditBlockBegan;
    NSDate *                _rdLastSelector;
    NSMutableAttributedString* _rdEditBuffer;
}

- (void) setUp;
- (BOOL) commit;

- (void) performScrollToEnd;
- (void) appendString:(NSAttributedString *) string;

- (BOOL) becomeFirstResponder;
- (BOOL) resignFirstResponder;

- (void) appChanged:(NSNotification *) notification;
- (void) frameChanged:(NSNotification *) notification;

- (void) setMaxLines:(unsigned) maxLines;

- (void) showCustomTooltip;
- (void) hideCustomTooltip;
- (void) testForCustomTooltip;

- (IBAction) searchForString:(id) sender;
- (IBAction) clearSearchString:(id) sender;

- (void) setTooltipDelegate:(id) delegate;

- (void) clearTextView;

@end
