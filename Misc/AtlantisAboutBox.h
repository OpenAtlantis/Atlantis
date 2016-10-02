//
//  AtlantisAboutBox.h
//  Atlantis
//
//  Created by Rachel Blackman on 5/26/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AtlantisAboutBox : NSObject {

    IBOutlet NSWindow           *_rdAboutBox;
    IBOutlet NSTextField        *_rdBuildInfo1;
    IBOutlet NSTextField        *_rdBuildInfo2;
    IBOutlet NSTextView         *_rdCreditInfo;    

}

- (void) addCreditProduct:(NSString *)prodName version:(NSString *)version copyright:(NSString *)copyright;
- (void) display;

@end
