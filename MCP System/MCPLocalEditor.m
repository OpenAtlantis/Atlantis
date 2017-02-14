//
//  MCPLocalEditor.m
//  Atlantis
//
//  Created by Rachel Blackman on 9/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "MCPLocalEditor.h"
#import "RDAtlantisWorldInstance.h"
#import "MCPMessage.h"

@implementation MCPLocalEditor

- (id) initForMessage:(MCPMessage *) message withWorld:(RDAtlantisWorldInstance *)world
{
    self = [super init];
    if (self) {
        if([NSBundle loadNibNamed:@"MCPLocalEditor" owner:self]) {
            [[self window] setTitle:[message attributeText:@"name"]];
            NSString *content;
            
            NSString *type = [message attributeText:@"type"];
            if (type && [type isEqualToString:@"string"]) {
                // single-line
                content = [message attributeText:@"content"];
            }
            else {
                content = [message attributeTextLinefeed:@"content"];
            }
            if (content)
                [[[_rdTextEditor textStorage] mutableString] setString:content];            
            [_rdTextEditor setFont:[NSFont userFixedPitchFontOfSize:12.0f]];
        }
        _rdOriginMessage = [message retain];
        _rdWorld = world;
        [[self window] makeKeyAndOrderFront:self];
    }
    return self;
}

- (void) dealloc
{
    [_rdOriginMessage release];
    [super dealloc];
}

- (void) send:(id) sender
{
    if ([_rdOriginMessage compat10]) {
        [_rdOriginMessage removeAttribute:@"content"];
        NSArray *paragraphs = [[_rdTextEditor textStorage] paragraphs];
        NSEnumerator *paraEnum = [paragraphs objectEnumerator];
        NSAttributedString *paraWalk = nil;
        while (paraWalk = [paraEnum nextObject]) {
            NSMutableString *tempString = [[paraWalk string] mutableCopy];
            [tempString replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0,[tempString length])];
            [tempString replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:NSMakeRange(0,[tempString length])];
            [_rdOriginMessage addText:tempString toAttribute:@"content"];
            [tempString release];
        }
        
        NSString *messageString = [_rdOriginMessage messageString];
        [_rdWorld sendString:messageString];
    }
    else {
        MCPMessage *response = [[MCPMessage alloc] initWithNamespace:@"dns-org-mud-moo-simpleedit" command:@"set"];
        [response setSessionKey:[_rdWorld mcpSessionKey]];
        NSString *reference = [_rdOriginMessage attributeText:@"reference"];
        [response addText:reference toAttribute:@"reference"];
        
        NSString *type = [_rdOriginMessage attributeText:@"type"];
        [response addText:type toAttribute:@"type"];
        
        if ([type isEqualToString:@"string"]) {
            NSMutableString *tempString = [[[_rdTextEditor textStorage] string] mutableCopy];
            [tempString replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0,[tempString length])];
            [tempString replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:NSMakeRange(0,[tempString length])];            
            [response addText:tempString toAttribute:@"content"];
            [tempString release];
        }
        else {
            NSArray *paragraphs = [[_rdTextEditor textStorage] paragraphs];
            NSEnumerator *paraEnum = [paragraphs objectEnumerator];
            NSAttributedString *paraWalk = nil;
            while (paraWalk = [paraEnum nextObject]) {
                NSMutableString *tempString = [[paraWalk string] mutableCopy];
                [tempString replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0,[tempString length])];
                [tempString replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:NSMakeRange(0,[tempString length])];
                [response addText:tempString toAttribute:@"content"];
                [tempString release];
            }
        }        
        [response makeAttributeMultiline:@"content"];

        NSString *responseString = [response messageString];
        [_rdWorld sendString:responseString];
        [response release];
    }
}

- (void) cancel:(id) sender
{
    [[self window] close];
}

@end
