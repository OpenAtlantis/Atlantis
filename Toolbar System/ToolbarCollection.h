//
//  ToolbarCollection.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/4/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EventCollection.h"
@class ToolbarUserEvent;

@interface ToolbarCollection : EventCollection {

}

- (NSArray *) identifiers;
- (ToolbarUserEvent *) eventForIdentifier:(NSString *)identifier;

@end
