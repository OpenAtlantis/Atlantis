//
//  RDMCPFilter.m
//  Atlantis
//
//  Created by Rachel Blackman on 8/6/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDMCPFilter.h"
#import "MCPMessage.h"
#import "MCPDispatch.h"
#import "AtlantisState.h"
#import "RDAtlantisMainController.h"

enum mcpParseStates { parsePreKey, parseKey, parsePreValue, parseValue };

@implementation RDMCPFilter

- (id) initWithWorld:(RDAtlantisWorldInstance *)world
{
    self = [super initWithWorld:world];
    if (self) {
        _rdIs10Grab = NO;
    }
    return self;
}


- (void) filterInput:(id) input
{
    if ([[self world] mcpDisabled]) {
        return;
    }

    if ([input isKindOfClass:[NSMutableAttributedString class]]) {
        NSMutableAttributedString *realString = (NSMutableAttributedString *)input;
        NSMutableString *tempString = [[[input string] mutableCopy] autorelease];
        [tempString replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0,[tempString length])];
        [tempString replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:NSMakeRange(0,[tempString length])];
        
        if (_rdIs10Grab) {
            MCPMessage *grabMessage = [[[self world] mcpPacketForTag:@"legacyEditInternal"] retain];
            if (grabMessage) {
                if ([tempString isEqualToString:@"."]) {
                    _rdIs10Grab = NO;
                    [grabMessage setFinished:YES];
                    [realString replaceCharactersInRange:NSMakeRange(0,[realString length]) withString:@""];
                }
                else {
                    [grabMessage addText:tempString toAttribute:@"content"];
                    [realString replaceCharactersInRange:NSMakeRange(0,[realString length]) withString:@""];
                }
                
                if ([grabMessage finished]) {
                    AtlantisState *state = [[AtlantisState alloc] initWithString:nil inWorld:[self world] forSpawn:nil];
                    [[[RDAtlantisMainController controller] mcpDispatch] dispatchMessage:grabMessage forState:state];
                    [state release];
                    [[self world] removeMcpPacket:grabMessage];
                    [grabMessage release];
                }
            }
        }
        else if (([tempString length] > 3) && [[tempString substringToIndex:3] isEqualToString:@"#$\""]) {
            [(NSMutableAttributedString *)input replaceCharactersInRange:NSMakeRange(0,3) withString:@""];
        }
        else if (([tempString length] > 3) && [[tempString substringToIndex:3] isEqualToString:@"#$#"]) {
            // Look, we're an MCP string!
            int position = 3;
            
            while ((position < [tempString length]) && isspace([tempString characterAtIndex:position]))
                position++;
                
            NSString *mcpLine = [tempString substringFromIndex:position];
            
            NSArray *tempArray = [mcpLine componentsSeparatedByString:@" "];
            NSString *mcpCommand = [tempArray objectAtIndex:0];

            MCPMessage *resultPacket = nil;
            
            BOOL packetIsDone = NO;
            BOOL singleParamLine = NO;
            
            if (!mcpCommand)
                return;
            
            if ([mcpCommand isEqualToString:@"edit"]) {
                // We are a legacy edit command!
                // We don't actually support MCP 1.0, but we WILL support MCP 1.0 local editing.  Whee.
                resultPacket = [[MCPMessage alloc] initWithNamespace:@"dns-org-mud-moo-simpleedit" command:@"legacyEdit"];
                [resultPacket setCompat10:YES];
                _rdIs10Grab = YES;
                [[self world] addMcpPacket:resultPacket];
                [[self world] mapMcpPacket:resultPacket toTag:@"legacyEditInternal"];
            }
            else if ([mcpCommand isEqualToString:@"mcp"]) {
                // Startup -- handle version stuff
            }
            else if ([mcpCommand isEqualToString:@"*"]) {
                // Multiline addition, parse parameters
                NSString *dataTag = [tempArray objectAtIndex:1];
                resultPacket = [[[self world] mcpPacketForTag:dataTag] retain];
                singleParamLine = YES;
                position += [dataTag length] + 1;
            }
            else if ([mcpCommand isEqualToString:@":"]) {
                // Multiline data addition done, fire off packet and return
                NSString *dataTag = [tempArray objectAtIndex:1];
                resultPacket = [[[self world] mcpPacketForTag:dataTag] retain];
                [resultPacket setFinished:YES];
                packetIsDone = YES;
            }
            else {
                // Check authentication, ignore anything not matching.
                NSString *authSequence = [tempArray objectAtIndex:1];
                if (authSequence) {
                    if (![authSequence isEqualToString:[[self world] mcpSessionKey]]) {
                        [realString replaceCharactersInRange:NSMakeRange(0,[realString length]) withString:@""];
                        [resultPacket release];                        
                        return;
                    }
                }
            }

            if (!packetIsDone) {
                NSString *mcpNamespace = nil;
                NSString *mcpSubcommand = nil;
                
                if (![resultPacket compat10]) {
                    NSEnumerator *handlerEnum = [[[[RDAtlantisMainController controller] mcpDispatch] namespaces] objectEnumerator];

                    int longestmatch = 0;
                    NSString *handlerWalk = nil;
                    while (handlerWalk = [handlerEnum nextObject]) {
                        if (([mcpCommand length] > [handlerWalk length]) && [[mcpCommand substringToIndex:[handlerWalk length]] isEqualToString:handlerWalk]) {
                            if ([handlerWalk length] > longestmatch) 
                                longestmatch = [handlerWalk length];
                        }
                    }
                    
                    if (longestmatch) {
                        mcpNamespace = [mcpCommand substringToIndex:longestmatch];
                        mcpSubcommand = [mcpCommand substringFromIndex:longestmatch + 1];
                    }
                    else {
                        mcpNamespace = mcpCommand;
                    }
                }
            
                if (!resultPacket)
                    resultPacket = [[MCPMessage alloc] initWithNamespace:mcpNamespace command:mcpSubcommand];
                    
                if (![mcpCommand isEqualToString:@"mcp"] && ![resultPacket compat10]) {
                    [resultPacket setSessionKey:[[self world] mcpSessionKey]];
                }
                
                BOOL paramIsQuoted = NO;
                BOOL escaped = NO;
                NSString *currentParam = nil;
                int lastMarker = -1;
                int state = parsePreKey;
                NSString *workString = tempString;
                position += [mcpCommand length];
                if (![resultPacket compat10]  && ![mcpCommand isEqualToString:@"mcp"] && ![mcpCommand isEqualToString:@"*"]) {
                    position += [[[self world] mcpSessionKey] length] + 1;
                }
                
                while (position < [workString length]) {
                    unichar curChar = [workString characterAtIndex:position];
                    switch (state) {
                        case parsePreKey:
                            if (!isspace(curChar)) {
                                lastMarker = position;
                                state = parseKey;
                            }
                            break;
                            
                        case parseKey:
                            if ((curChar == ':') || isspace(curChar)) {
                                currentParam = [workString substringWithRange:NSMakeRange(lastMarker,position - lastMarker)];
                                state = parsePreValue;
                            }
                            break;
                            
                        case parsePreValue:
                            if (singleParamLine) {
                                paramIsQuoted = NO;
                                lastMarker = position + 1;
                                state = parseValue;
                                position = [workString length] - 1;
                            }
                            else {
                                if (!isspace(curChar)) {
                                    if (curChar == '"') {
                                        if (!escaped) {
                                            paramIsQuoted = YES;
                                            lastMarker = position + 1;
                                        }
                                        else {
                                            paramIsQuoted = NO;
                                            lastMarker = position;
                                            if ([resultPacket compat10] && [currentParam isEqualToString:@"upload"])
                                                singleParamLine = YES;
                                        }
                                    }
                                    else if (curChar == '\\') {
                                        escaped = !escaped;
                                    }
                                    else {
                                        paramIsQuoted = NO;
                                        lastMarker = position;
                                        escaped = NO;
                                        if ([resultPacket compat10] && [currentParam isEqualToString:@"upload"])
                                            singleParamLine = YES;
                                    }
                                    state = parseValue;
                                }
                            }
                            break;
                            
                        case parseValue:
                            if (!singleParamLine) {
                                if ((isspace(curChar) && !paramIsQuoted) ||
                                    ((curChar == '"') && !escaped && paramIsQuoted)) {
                                    state = parsePreKey;
                                    NSMutableString *firstValue = [[workString substringWithRange:NSMakeRange(lastMarker,position - lastMarker)] mutableCopy];
                                    [firstValue replaceOccurrencesOfString:@"\\\"" withString:@"\"" options:0 range:NSMakeRange(0,[firstValue length])];
                                    NSString *tempValue = [NSString stringWithString:firstValue];
                                    [firstValue release];
                                    [resultPacket addText:tempValue toAttribute:currentParam];
                                }
                                if (curChar == '\\') {
                                    escaped = !escaped;
                                }
                                else {
                                    escaped = NO;
                                }
                            }
                    }
                    position++;
                }
                
                if (state == parseValue) {
                    NSMutableString *firstValue = [[workString substringWithRange:NSMakeRange(lastMarker,position - lastMarker)] mutableCopy];
//                    [firstValue replaceOccurrencesOfString:@"\\\"" withString:@"\"" options:0 range:NSMakeRange(0,[firstValue length])];
                    NSString *tempValue = [NSString stringWithString:firstValue];
                    [firstValue release];
                    [resultPacket addText:tempValue toAttribute:currentParam];                    
                }
                
                NSString *dataTag = [resultPacket attributeText:@"_data-tag"];
                if (dataTag && ![[self world] mcpPacketForTag:dataTag]) {
                    [[self world] mapMcpPacket:resultPacket toTag:dataTag];
                }
                
                if (!dataTag && ![resultPacket compat10] && ![mcpCommand isEqualToString:@"*"]) {
                    [resultPacket setFinished:YES];
                 } 
            }
            
            if (_rdIs10Grab || [[resultPacket namespace] isEqualToString:@"mcp"] || [[self world] mcpNegotiated]) {           
                [realString replaceCharactersInRange:NSMakeRange(0,[realString length]) withString:@""];
            
                if ([resultPacket finished]) {
                    AtlantisState *state = [[AtlantisState alloc] initWithString:nil inWorld:[self world] forSpawn:nil];
                    [[[RDAtlantisMainController controller] mcpDispatch] dispatchMessage:resultPacket forState:state];
                    [state release];
                    [[self world] removeMcpPacket:resultPacket];
                }
            }
            
            [resultPacket release];
        }
    }
}

@end
