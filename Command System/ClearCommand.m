//
//  ClearCommand.m
//  Atlantis
//
//  Created by Rachel Blackman on 8/2/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "ClearCommand.h"
#import "RDAtlantisSpawn.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"

@implementation ClearCommand

- (NSString *) checkOptionsForState:(AtlantisState *) state
{
    return nil;
}

- (void) executeForState:(AtlantisState *) state
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
                                                                         attributes:[NSDictionary dictionaryWithObjectsAndKeys:[[state world] displayFont],NSFontAttributeName,[[state world] formattingParagraphStyle],NSParagraphStyleAttributeName,[NSNumber numberWithInt:NSUTF8StringEncoding], NSCharacterEncodingDocumentAttribute, nil]];
        
        [spawn appendString:realString];
        [realString release];        
        [tempString release];
    }
}


@end
