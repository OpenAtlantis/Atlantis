//
//  Action-ClearScreen.m
//  Atlantis
//
//  Created by Rachel Blackman on 8/18/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Action-ClearScreen.h"
#import "AtlantisState.h"
#import "RDAtlantisSpawn.h"

@implementation Action_ClearScreen


+ (NSString *) actionName
{
    // TODO: Localize
    return @"Spawn: Clear Screen";
}

+ (NSString *) actionDescription
{
    // TODO: Localize
    return @"Clear the currently active spawn of visible text by adding blank lines, like /clear.";
}

+ (NSNumber *) validForType:(AtlantisEventType) type
{
    if (type == AtlantisTypeUI)
        return [NSNumber numberWithBool:YES];
        
    return [NSNumber numberWithBool:NO];
}

- (BOOL) executeForState:(AtlantisState *) state
{
    RDAtlantisSpawn *spawn = [state spawn];
    if (spawn) {
        int height = [spawn screenHeight];
        int loop;
        NSMutableString *tempString = [[NSMutableString alloc] init];
        for (loop = 0; loop < height; loop++) {
            [tempString appendString:@"\n"];
        }
        
        NSAttributedString *realString = [[NSAttributedString alloc] initWithString:tempString  
                                                                         attributes:[NSDictionary dictionaryWithObjectsAndKeys:[[state world] displayFont],NSFontAttributeName,[[state world] formattingParagraphStyle],NSParagraphStyleAttributeName,nil]];
        
        [spawn appendString:realString];
        [realString release];        
        [tempString release];
    }
    
    return NO;
}


@end
