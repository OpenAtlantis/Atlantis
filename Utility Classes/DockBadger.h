//
//  DockBadger.h
//  Atlantis
//
//  Created by Rachel Blackman on 6/25/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DockBadger : NSObject {

    NSImage             *_rdBaseIcon;
    NSDictionary        *_rdTextAttrs;
    
    int                  _rdActiveSpawns;
    NSString            *_rdBadgeString;

}

- (void) badgeWithActive:(int) active;
- (void) badgeWithText:(NSString *) string;

- (void) refreshDockIcon;

@end
