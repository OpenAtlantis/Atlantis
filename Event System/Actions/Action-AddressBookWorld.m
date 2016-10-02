//
//  Action-AddressBookWorld.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/3/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-AddressBookWorld.h"
#import "RDAtlantisMainController.h"
#import "RDAtlantisWorldInstance.h"
#import "AtlantisState.h"

@implementation Action_AddressBookWorld


+ (NSString *) actionName
{
    // TODO: Localize
    return @"AddressBook: Open Address Book on Current World";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Open the Address Book and focus the current world.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    [[RDAtlantisMainController controller] openPrefsForWorld:[[state world] preferences] onCharacter:[[state world] character]];
    return NO;
}


@end
