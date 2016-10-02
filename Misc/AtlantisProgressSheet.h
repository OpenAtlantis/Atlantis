//
//  AtlantisProgressSheet.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/14/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AtlantisProgressSheet : NSObject {

    IBOutlet NSPanel                *_rdProgressSheet;
    IBOutlet NSProgressIndicator    *_rdProgressBar;
    IBOutlet NSTextField            *_rdProgressLabel;
    
    IBOutlet NSButton               *_rdCancelButton;
    
    NSModalSession                   _rdSheetSession;
    
    BOOL                             _rdOpen;
    BOOL                             _rdCancelled;
}

- (void) openPanel:(NSString *)label withMaxValue:(double)maxValue;
- (void) setMaxValue:(double) newMax;
- (void) setProgress:(double) newValue;
- (void) setLabel:(NSString *)label;
- (BOOL) modalRun;
- (void) closePanel;

- (IBAction) cancelButton:(id) sender;

@end
