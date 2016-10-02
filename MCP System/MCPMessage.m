//
//  MCPMessage.m
//  Atlantis
//
//  Created by Rachel Blackman on 8/6/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "MCPMessage.h"

static unsigned long s_dataCounter = 0;

@implementation MCPMessage

- (id) initWithNamespace:(NSString *) mcpNamespace command:(NSString *)command
{
    self = [super init];
    if (self) {
        _rdNamespace = [mcpNamespace retain]; 
        _rdCommand = [command retain];
        _rdAttributes = [[NSMutableDictionary alloc] init];
        _rdAttributeOrder = [[NSMutableArray alloc] init];
        _rdFinished = NO;
        _rdCompat10 = NO;
    }
    return self;
}

- (void) dealloc
{
    [_rdAttributeOrder release];
    [_rdAttributes release];
    [_rdNamespace release];
    [_rdCommand release];
    [super dealloc];
}

- (NSString *) namespace
{
    return _rdNamespace;
}

- (NSString *) command
{
    return _rdCommand;
}

- (void) setSessionKey:(NSString *)key
{
    [_rdSessionKey release];
    _rdSessionKey = [key copy];
}

- (void) addText:(NSString *)text toAttribute:(NSString *) attribute
{
    NSObject *attrVal = [_rdAttributes objectForKey:attribute];
    
    if (attrVal) {
        if ([attrVal isKindOfClass:[NSMutableArray class]]) {
            [(NSMutableArray *)attrVal addObject:text];
        }
        else if ([attrVal isKindOfClass:[NSString class]]) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            [tempArray addObject:attrVal];
            [tempArray addObject:text];
            [_rdAttributes setObject:tempArray forKey:attribute];
            [tempArray release];
        }
    }
    else {
        [_rdAttributes setObject:text forKey:attribute];
    }
    
    if (![_rdAttributeOrder containsObject:attribute]) {
        [_rdAttributeOrder addObject:attribute];
    }
}

- (void) makeAttributeMultiline:(NSString *) attribute
{
    NSObject *attrVal = [_rdAttributes objectForKey:attribute];
    
    if (attrVal) {
        if ([attrVal isKindOfClass:[NSString class]]) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            [tempArray addObject:attrVal];
            [_rdAttributes setObject:tempArray forKey:attribute];
            [tempArray release];
        }
    }
    else {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [tempArray addObject:@""];
        [_rdAttributes setObject:tempArray forKey:attribute];
        [tempArray release];
    }
}

- (void) removeAttribute:(NSString *) attribute
{
    [_rdAttributes removeObjectForKey:attribute];
    [_rdAttributeOrder removeObject:attribute];
}

- (BOOL) attributeIsMultiline:(NSString *)attribute
{
    NSObject *attrVal = [_rdAttributes objectForKey:attribute];
    
    if (attrVal && [attrVal isKindOfClass:[NSMutableArray class]])
        return YES;
        
    return NO;
}

- (NSArray *) attributeLines:(NSString *)attribute
{
    NSObject *attrVal = [_rdAttributes objectForKey:attribute];
    
    if (attrVal && [attrVal isKindOfClass:[NSMutableArray class]])
        return (NSArray *)attrVal;
        
    return nil;
}

- (NSString *) attributeText:(NSString *) attribute
{
    NSObject *attrVal = [_rdAttributes objectForKey:attribute];
    
    if (attrVal && [attrVal isKindOfClass:[NSMutableArray class]]) {
    
        NSMutableString *tempString = [[NSMutableString alloc] init];
        
        NSEnumerator *lineEnum = [(NSArray *)attrVal objectEnumerator];
        
        NSString *lineWalk;
        
        while (lineWalk = [lineEnum nextObject]) {
            [tempString appendString:lineWalk];
            [tempString appendString:@" "];
        }
        
        return [tempString autorelease];
    }
    else
        return (NSString *)attrVal;
}

- (NSString *) attributeTextLinefeed:(NSString *) attribute
{
    NSObject *attrVal = [_rdAttributes objectForKey:attribute];
    
    if (attrVal && [attrVal isKindOfClass:[NSMutableArray class]]) {
    
        NSMutableString *tempString = [[NSMutableString alloc] init];
        
        NSEnumerator *lineEnum = [(NSArray *)attrVal objectEnumerator];
        
        NSString *lineWalk;
        
        while (lineWalk = [lineEnum nextObject]) {
            [tempString appendString:lineWalk];
            [tempString appendString:@"\n"];
        }
        
        return [tempString autorelease];
    }
    else
        return (NSString *)attrVal;
}


- (NSArray *) attributes
{
    return _rdAttributeOrder;
}

- (BOOL) finished
{
    return _rdFinished;
}

- (void) setFinished:(BOOL) finished
{
    _rdFinished = finished;
}

- (BOOL) compat10
{
    return _rdCompat10;
}

- (void) setCompat10:(BOOL) compat10
{
    _rdCompat10 = compat10;
}

- (NSString *) messageString
{
    if (![self compat10]) {
        NSMutableString *output = [[NSMutableString alloc] init];
        NSString *dataTag = nil;
        
        [output appendString:@"#$#"];
        [output appendString:_rdNamespace];
        if ([self command]) {
            [output appendString:@"-"];
            [output appendString:[self command]];
        }
        [output appendString:@" "];
        if (_rdSessionKey) {
            [output appendString:_rdSessionKey];
            [output appendString:@" "];
        }
        
        NSEnumerator *attrEnum = [[self attributes] objectEnumerator];
        NSString *attrWalk;
        
        while (attrWalk = [attrEnum nextObject]) {
            [output appendString:@" "];
            [output appendString:attrWalk];
            if ([self attributeIsMultiline:attrWalk]) {
                [output appendString:@"*: \"\""];
                if (!dataTag) {
                    dataTag = [NSString stringWithFormat:@"atl%0.4x", s_dataCounter];
                    s_dataCounter++;
                }
            }
            else {
                NSString *value = [self attributeText:attrWalk];
                NSMutableString *tempvalue = [value mutableCopy];
                [tempvalue replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0,[tempvalue length])];
                [output appendString:@": "];
                int words = [[tempvalue componentsSeparatedByString:@" "] count];
                if (words > 1) {
                    [output appendString:[NSString stringWithFormat:@"\"%@\"", tempvalue]];
                }
                else if (words == 0) {
                    [output appendString:@"\"\""];
                }
                else {
                    [output appendString:tempvalue];
                }
                [tempvalue release];
            }
        }
        
        if (dataTag) {
            [output appendString:[NSString stringWithFormat:@" _data-tag: %@\n", dataTag]];
            attrEnum = [_rdAttributes keyEnumerator];
            while (attrWalk = [attrEnum nextObject]) {
                if ([self attributeIsMultiline:attrWalk]) {
                    NSArray *attrLines = [self attributeLines:attrWalk];
                    
                    NSEnumerator *lineEnum = [attrLines objectEnumerator];
                    NSString *lineWalk;
                    NSMutableString *tempvalue;
                    while (lineWalk = [lineEnum nextObject]) {
                        tempvalue = [lineWalk mutableCopy];
//                        [tempvalue replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0,[tempvalue length])];
                        [output appendString:@"#$#* "];
                        [output appendString:[NSString stringWithFormat:@"%@ %@: %@\n", dataTag, attrWalk, tempvalue]];
                        [tempvalue release];
                        tempvalue = nil;
                    }
                }
            }
            [output appendString:[NSString stringWithFormat:@"#$#: %@\n", dataTag]];
        }
        
        return [output autorelease];
    }
    else {
        NSMutableString *output = [[NSMutableString alloc] init];
        
        [output appendString:[self attributeText:@"upload"]];
        [output appendString:@"\n"];
        NSArray *lines = [self attributeLines:@"content"];
        
        NSEnumerator *lineEnum = [lines objectEnumerator];
        NSString *walk;
        
        while (walk = [lineEnum nextObject]) {
            [output appendString:walk];
            [output appendString:@"\n"];
        }
        
        [output appendString:@".\n"];
        
        return [output autorelease];
    }
}

@end
