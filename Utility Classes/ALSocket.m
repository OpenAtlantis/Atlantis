//
//	ALSocket.m
//	Alurio
//
//	Copyright (c) 2003-2006 Alurio Development Studios
//	All rights reserved.
//	
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//	
//	- Redistributions of source code must retain the above copyright notice,
//	  this list of conditions and the following disclaimer.
//	
//	- Redistributions in binary form must reproduce the above copyright notice,
//	  this list of conditions and the following disclaimer in the documentation
//	  and/or other materials provided with the distribution.
//	
//	- Neither the name of the Alurio Development Studios nor the names of its
//	  contributors may be used to endorse or promote products derived from this
//	  software without specific prior written permission.
//	
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
//	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//	POSSIBILITY OF SUCH DAMAGE.
//

#import "ALSocket.h"
#import "NetSocket.h"

@interface ALSocket (Private)

- (NetSocket *)netSocket;
- (void)setNetSocket:(NetSocket *)netSocket;

@end

@implementation ALSocket (Private)

- (NetSocket *)netSocket
{
	return mNetSocket;
}

- (void)setNetSocket:(NetSocket *)netSocket
{
	[mNetSocket autorelease];
	mNetSocket = [netSocket retain];
}

@end

@implementation ALSocket

+ (ALSocket *)socket
{
	return [[[self alloc] init] autorelease];
}

#pragma mark Initialization

+ (void)initialize
{
	static BOOL initialized = NO;
	
	if(!initialized)
	{
		[NetSocket ignoreBrokenPipes];
		
		initialized = YES;
	}
}

- (id)init
{
	if([super init])
	{
		mWasConnected = NO;
		
		// create net socket
		[self setNetSocket:[[[NetSocket alloc] init] autorelease]];
		if(![mNetSocket open])
		{
			[self setNetSocket:nil];
			[self release];
			return nil;
		}
		if(![mNetSocket scheduleOnCurrentRunLoop])
		{
			[self setNetSocket:nil];
			[self release];
			return nil;
		}
		[mNetSocket setDelegate:self];
	}
	
	return self;
}

- (void)dealloc
{
	
	[mNetSocket close];
	[mNetSocket setDelegate:nil];
	[self setNetSocket:nil];
	
	[super dealloc];
}

#pragma mark Accessors

- (BOOL)isConnected
{
	return [mNetSocket isConnected];
}

- (BOOL)wasConnected
{
	return mWasConnected;
}

- (void)setWasConnected:(BOOL)wasConnected
{
	mWasConnected = wasConnected;
}

- (BOOL) isHandshaking
{
    return mIsHandshaking;
}

- (void) setIsHandshaking:(BOOL) handshake
{
    mIsHandshaking = handshake;
}

- (id)delegate
{
	return mDelegate;
}

- (void)setDelegate:(id)delegate
{
	// do not retain
	mDelegate = delegate;
}

#pragma mark Network

- (void)connectToHost:(NSString *)host port:(NSNumber *)port
{
	[mNetSocket connectToHost:host port:[port intValue] /*timeout:30.0*/];
}

- (void)writeData:(NSData *)data
{
	if(mIsEncrypted)
	{
		size_t finalLength = 0;
		SSLWrite(mSSLContext, [data bytes], [data length], &finalLength);
	}
	else
	{
		[mNetSocket writeData:data];
	}
}

- (void) disconnect
{
    [mNetSocket close];
}

#pragma mark Delegate

- (void)netsocketConnected:(NetSocket *)socket
{
	// notify
	[self postSocketNotificationOnMainThread:[NSNotification notificationWithName:ALSocketDidOpenConnectionNotification object:[self delegate]]];
}

- (void)netsocketDisconnected:(NetSocket *)socket
{
	// notify
	[self postSocketNotificationOnMainThread:[NSNotification notificationWithName:ALSocketDidNotOpenConnectionNotification object:[self delegate]]];
	
	// confirm disconnect
	mWasConnected = NO;
}

- (void)netsocket:(NetSocket *)socket connectionTimedOut:(NSTimeInterval)timeout;
{
	// notify
	[self postSocketNotificationOnMainThread:[NSNotification notificationWithName:ALSocketDidTimeoutNotification object:[self delegate]]];
}

- (void)netsocket:(NetSocket *)socket dataAvailable:(unsigned)dataLength
{
	// confirm connect
	mWasConnected = YES;
    
    if(mIsHandshaking)
        return;
	
	if(mIsEncrypted)
	{
		NSMutableData	*data = [[[NSMutableData alloc] init] autorelease];
		UInt8			bytes[1024];
		size_t			processedLength = 1; // 1, because the loop needs to run at least once
		
		while(processedLength != 0)
		{
			// read
			OSStatus ret = SSLRead(mSSLContext, bytes, 1024, &processedLength);
			if(ret < 0)
			{
				processedLength = 0;
			}
			
			// copy into buffer
			if(processedLength > 0)
				[data appendBytes:bytes length:processedLength];
		}
		
		// notify
		[self postSocketNotificationOnMainThread:
			[NSNotification notificationWithName:ALSocketDidReadNotification
										  object:[self delegate]
										userInfo:[NSDictionary dictionaryWithObjectsAndKeys:data, @"data", nil]
			]
		];
	}
	else
	{
		// get data
		NSData *data = [socket readData];
		
		// notify
		[self postSocketNotificationOnMainThread:
			[NSNotification notificationWithName:ALSocketDidReadNotification
										  object:[self delegate]
										userInfo:[NSDictionary dictionaryWithObjectsAndKeys:data, @"data", nil]
			]
		];
	}
}

#pragma mark SSL/TLS Stuff

- (SSLContextRef)sslContext
{
	return mSSLContext;
}

- (void)setSSLContext:(SSLContextRef)aSSLContext
{
	mSSLContext = aSSLContext;
}

- (BOOL)isEncrypted
{
	return mIsEncrypted;
}

- (void)setEncrypted:(BOOL)aIsEncrypted
{
	mIsEncrypted = aIsEncrypted;
}

#pragma mark Threading

- (void)postSocketNotificationOnMainThread:(NSNotification *)notification
{
	// notify
	[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}

@end


#pragma mark SSL/TLS Read Functions

OSStatus ALSSLRead(SSLConnectionRef connection, void *data, size_t *length)
{
	NSData *readData = nil;
	unsigned i = 0;
	
	while(!readData && i < 10)
	{
		// read
		readData = [[(ALSocket *)connection netSocket] readData:*length];
		
        if (!readData) {
            usleep(1000000);
            [[(ALSocket *)connection netSocket] _cfsocketDataAvailable];
        }
        
		++i;
	}

    if (readData) {
        [readData getBytes:data length:*length];
    }
    *length = [readData length];
	
	return noErr;
}

OSStatus ALSSLWrite(SSLConnectionRef connection, const void *data, size_t *length)
{
	// write
    [[(ALSocket *)connection netSocket] writeData:[NSData dataWithBytes:data length:*length]];
    
	return noErr;
}


#pragma mark Notifications

NSString *ALSocketDidNotOpenConnectionNotification
	= @"ConnectionFailed Notification";
NSString *ALSocketDidOpenConnectionNotification
	= @"ConnectionSucceeded Notification";
NSString *ALSocketDidTimeoutNotification
	= @"ConnectionTimedOut Notification";
NSString *ALSocketDidNotReadNotification
	= @"ReadFailed Notification";
NSString *ALSocketDidReadNotification
	= @"ReadSucceeded Notification";
