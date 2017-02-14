//
//  AliasEvent.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "AliasEvent.h"
#import "EventActionProtocol.h"

@implementation AliasEvent

- (BOOL) eventCanEditDescription
{
    return NO;
}

- (void) eventSetName:(NSString *)name
{
    NSMutableString *tempString = [name mutableCopy];
    [tempString replaceOccurrencesOfString:@" " withString:@"_" options:0 range:NSMakeRange(0,[tempString length])];
    [super eventSetName:[NSString stringWithString:tempString]];
    [tempString release];
}

- (void) eventSetDescription:(NSString *) desc
{
    // Override to Do Nothing
}

- (BOOL) eventSupportsConditions
{
    return NO;
}

- (NSArray *) eventConditions
{
    return nil;
}

- (BOOL) eventConditionsAnded
{
    return NO;
}

- (void) eventSetConditionsAnded:(BOOL) anded
{
    // Do Nothing
}

- (void) eventAddCondition:(id <EventConditionProtocol>) condition
{
    // Do Nothing
}

- (void) eventRemoveCondition:(id <EventConditionProtocol>) condition
{
    // Do Nothing
}

- (NSString *) eventDescription
{
    int count = [_rdActions count];
    
    if (count == 1) {
        id <EventActionProtocol> action = [_rdActions objectAtIndex:0];
        return [action actionDescription];
    }
    else if (count == 0) {
        // TODO: Localize
        return @"<< No Actions Set >>";
    }
    else {
        // TODO: Localize
        NSMutableString *result = [[NSMutableString alloc] init];
        
        NSEnumerator *actionEnumerator = [_rdActions objectEnumerator];
        
        id <EventActionProtocol> actionWalk;
        
        while (actionWalk = [actionEnumerator nextObject]) {
            if ([result length]) {
                if ([result characterAtIndex:[result length] - 1] == '.') {
                    [result replaceCharactersInRange:NSMakeRange([result length] - 1, 1) withString:@", then "];
                }
                else {
                    [result appendString:@", then "];
                }
            }
            [result appendString:[actionWalk actionDescription]];
        }
        
        return [NSString stringWithString:result];
    }
}


@end
