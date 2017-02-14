//
//  Action-AddressBook.m
//  Atlantis
//
//  Created by Rachel Blackman on 3/14/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-AddressBook.h"
#import "RDAtlantisMainController.h"

@implementation Action_AddressBook

+ (NSString *) actionName
{
    // TODO: Localize
    return @"AddressBook: Open Address Book";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Open the Address Book.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    [[RDAtlantisMainController controller] addressBook:self];
    return NO;
}


@end
