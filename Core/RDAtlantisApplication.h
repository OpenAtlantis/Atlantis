//
//  RDAtlantisApplication.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/15/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RDAtlantisApplication : NSApplication {

    BOOL                        _rdSpawnShortcut;

}

+ (BOOL) isTiger;
- (void) shortcutSpawns:(BOOL) shortcutOn;

@end
