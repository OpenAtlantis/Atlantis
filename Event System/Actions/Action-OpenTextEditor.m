//
//  Action-OpenTextEditor.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/8/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-OpenTextEditor.h"
#import "AtlantisState.h"
#import "RDAtlantisMainController.h"

@implementation Action_OpenTextEditor

+ (NSString *) actionName
{
    // TODO: Localize
    return @"World: Open MUSH Text Editor";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Open the MUSH text editor.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if ((type == AtlantisTypeUI) || (type == AtlantisTypeAlias))
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    [[RDAtlantisMainController controller] openMushEditorForWorld:[state world]];
    return NO;
}



@end
