//
//	ALSocket.h
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

#import <Foundation/Foundation.h>
#import <Security/SecureTransport.h>

@class NetSocket;

@interface ALSocket : NSObject {
@private
	id					mDelegate;
	
	// flags
	BOOL				mWasConnected;
	
	// ssl/tls stuff
	SSLContextRef		mSSLContext;
	BOOL				mIsEncrypted;
    BOOL                mIsHandshaking;
	
	// netsocket
	NetSocket			*mNetSocket;
}

+ (ALSocket *)socket;

- (void)dealloc;

#pragma mark Initialization

- (id)init;

#pragma mark Accessors

- (BOOL)isConnected;

- (BOOL)wasConnected;
- (void)setWasConnected:(BOOL)wasConnected;

- (BOOL)isHandshaking;
- (void)setIsHandshaking:(BOOL)handshake;

- (id)delegate;
- (void)setDelegate:(id)delegate;

#pragma mark Network

- (void)connectToHost:(NSString *)host port:(NSNumber *)port;

- (void)writeData:(NSData *)data;

- (void)disconnect;

#pragma mark Delegate

- (void)netsocketConnected:(NetSocket *)socket;
- (void)netsocketDisconnected:(NetSocket *)socket;
- (void)netsocket:(NetSocket *)socket dataAvailable:(unsigned)dataLength;

#pragma mark SSL/TLS Stuff

- (SSLContextRef)sslContext;
- (void)setSSLContext:(SSLContextRef)aSSLContextRef;

- (BOOL)isEncrypted;
- (void)setEncrypted:(BOOL)aIsEncrypted;

#pragma mark Threading

- (void)postSocketNotificationOnMainThread:(NSNotification *)notification;

@end


#pragma mark SSL/TLS Read Functions

OSStatus ALSSLRead(SSLConnectionRef connection, void *data, size_t *length);
OSStatus ALSSLWrite(SSLConnectionRef connection, const void *data, size_t *length);


#pragma mark Notifications

extern NSString *ALSocketDidNotOpenConnectionNotification;
extern NSString *ALSocketDidOpenConnectionNotification;
extern NSString *ALSocketDidTimeoutNotification;
extern NSString *ALSocketDidNotReadNotification;
extern NSString *ALSocketDidReadNotification;
