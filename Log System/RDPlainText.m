//
//  RDPlainText.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/14/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDPlainText.h"

@implementation RDPlainText


+ (NSString *) logtypeName
{
    // TODO: Localize
    return @"Plain Text";
}

+ (NSString *) shortTypeName
{
    // TODO: Localize
    return @"Text";
}

+ (BOOL) canAppendToLog
{
    return YES;
}

- (id) initWithFilename:(NSString *)filename forSpawn:(NSString *)spawnPath inWorld:(RDAtlantisWorldInstance *)world
{
    self = [super initWithFilename:filename forSpawn:spawnPath inWorld:world];
    if (self) {
    
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (BOOL) openFile 
{
    if ([super openFile]) {
        return YES;
    }
    return NO;
}

- (BOOL) closeFile
{
    if ([self isOpen]) {

    }
    return [super closeFile];
}

- (void) writeString:(NSAttributedString *)string withState:(AtlantisState *)state
{
    NSString *realString = [string string];

    // If this line is marked 'omit from logs,' we, well, omit it from logs.
    if ([realString length]) {
        NSRange effRange;
        NSDictionary *attrs = [string attributesAtIndex:0 effectiveRange:&effRange];
        if ([attrs objectForKey:@"RDLogOmitLine"])
            return;
    }
 
    if ([realString length] && ([realString characterAtIndex:[realString length] - 1] == '\n')) {
        realString = [realString substringWithRange:NSMakeRange(0,[string length] - 1)];
    }
    
    if ([realString length]) {
        if ([self writeTimestamps])  {
            NSRange tempRange;
            NSDictionary *attrs;
            
            attrs = [string attributesAtIndex:0 effectiveRange:&tempRange];
            NSDate *timestamp = [attrs objectForKey:@"RDTimeStamp"];
                
            if (timestamp) {
                [self writeStringToFile:[NSString stringWithFormat:@"[%@] %@\n",
                    [timestamp descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil], realString]];
            }
            else 
                [self writeStringToFile:[NSString stringWithFormat:@"%@\n", realString]];
        }
        else
            [self writeStringToFile:[NSString stringWithFormat:@"%@\n", realString]];
    }
}

@end
