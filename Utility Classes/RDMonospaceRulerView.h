//
//  RDMonospaceRulerView.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/3/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RDMonospaceRulerView : NSRulerView {

    float            _rdFontWidth;
    float            _rdIndent;
    NSFont          *_rdFont;
    NSDictionary    *_rdDrawAttributes;

}

- (void) setFont:(NSFont *)newFont;

@end
