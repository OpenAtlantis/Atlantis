//
//  ActionClasses.h
//  Atlantis
//
//  Created by Rachel Blackman on 3/1/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseAction.h"

@interface ActionClasses : NSObject {

    NSMutableArray              *_rdClasses;

}

- (void) registerActionClass:(Class) actionClass;
- (unsigned) actionClassCount;

- (Class) classAtIndex:(unsigned) index;
- (NSString *) stringForClassAtIndex:(unsigned) index;
- (BaseAction *) instanceOfClassAtIndex:(unsigned) index;

- (NSArray *) actionsForType:(AtlantisEventType) type;

@end
