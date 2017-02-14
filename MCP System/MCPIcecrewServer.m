//
//  MCPIcecrewServer.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MCPIcecrewServer.h"
#import "AtlantisState.h"
#import "RDAtlantisWorldInstance.h"


@implementation MCPIcecrewServer

- (void) handleMessage:(MCPMessage *)message withState:(AtlantisState *)state
{
    if ([[message command] isEqualToString:@"set"]) {
        NSString *charset = [message attributeText:@"charset"];
		CFStringEncoding testEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)charset);
		if (testEncoding != kCFStringEncodingInvalidId) {
			NSStringEncoding realEncoding = (NSStringEncoding)CFStringConvertEncodingToNSStringEncoding(testEncoding); 
			if ([[state world] stringEncoding] != realEncoding)
				[[state world] handleStatusOutput:[NSString stringWithFormat:@"Negotiated new string encoding: %@\n", [NSString localizedNameOfStringEncoding:realEncoding]]];
			[[state world] setStringEncoding:realEncoding];		
		}
	}
}
	
- (void) negotiated:(AtlantisState *)state
{
	NSString *mcpKey = [[state world] mcpSessionKey];
	
	MCPMessage *message = [[MCPMessage alloc] initWithNamespace:@"dns-nl-icecrew-serverinfo" command:@"get"];
	[message setSessionKey:mcpKey];
	NSString *messageString = [message messageString];
	[[state world] sendString:messageString];
	[message release];
}

@end
