//
//  RDTelnetFilter.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/12/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDTelnetFilter.h"
#define TELOPTS
#define TELCMDS
#include <arpa/telnet.h>
#define TELOPT_CHARSET 42
#define TELOPT_COMPRESS 85
#define TELOPT_COMPRESS2 86

#define TELOPT_MSDP 69
#define MSDP_VAR 1
#define MSDP_VAL 2
#define MSDP_OPEN 3
#define MSDP_CLOSE 4


#define ESC 24

#define TQ_NO               0
#define TQ_YES              1
#define TQ_WANTNO           2
#define TQ_WANTYES          3
#define TQ_EMPTY            NO
#define TQ_OPPOSITE         YES



@implementation TelnetData

- (id) init
{
    memset(&local[0],0,sizeof(unsigned char) * 256);
    memset(&remote[0],0,sizeof(unsigned char) * 256);
    
    memset(&local[0],TQ_EMPTY,sizeof(unsigned char) * 256);
    memset(&remote[0],TQ_EMPTY,sizeof(unsigned char) * 256);
    
    return self;
}

- (void) clear
{
    memset(&local[0],0,sizeof(unsigned char) * 256);
    memset(&remote[0],0,sizeof(unsigned char) * 256);
    
    memset(&local[0],TQ_EMPTY,sizeof(unsigned char) * 256);
    memset(&remote[0],TQ_EMPTY,sizeof(unsigned char) * 256);
}

@end

enum ScanStates { scanNormal, scanIAC, scanWILL, scanWONT, scanDO, scanDONT, scanSB, scanSBdata, scanSBIAC };

@interface RDTelnetFilter (Private)
- (void) resendNaws;
- (void) screenUpdated:(NSNotification *) notification;
- (void) worldConnected:(NSNotification *) notification;
- (void) worldDisconnected:(NSNotification *) notification;
- (void) nopTimerFired:(NSTimer *) timer;
@end

@implementation RDTelnetFilter

- (id) initWithWorld:(RDAtlantisWorldInstance *)world
{
    self = [super initWithWorld:world];
    if (self) {
        telnetSessionData = [[TelnetData alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenUpdated:) name:@"RDAtlantisMainScreenDidChangeNotification" object:[self world]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(worldConnected:) name:@"RDAtlantisConnectionDidConnectNotification" object:[self world]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(worldDisconnected:) name:@"RDAtlantisConnectionDidDisconnectNotification" object:[self world]];
        _rdNopTimer = nil;
        mudPrompted = NO;
    }    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_rdNopTimer) {
        [_rdNopTimer invalidate];
        [_rdNopTimer release];
    }
    [telnetSessionData release];
    [super dealloc];
}

- (void) sendState:(unsigned char)state forOption:(unsigned char)option
{
    char response[3] = { IAC, state, option };
    
    [[self world] sendDataRaw:[NSData dataWithBytes:response length:3]];
}

- (BOOL) prefersOption:(unsigned char)option
{
    switch(option) {
        case TELOPT_BINARY:
        case TELOPT_SGA:
        case TELOPT_NAWS:
        case TELOPT_TTYPE:
        case TELOPT_CHARSET:
        case TELOPT_ECHO:
            return YES;
        
        case TELOPT_COMPRESS2:
            return [[NSUserDefaults standardUserDefaults] boolForKey:@"atlantis.network.compress"];
            
        case TELOPT_TM:
        case TELOPT_SNDLOC:
        case TELOPT_EOR:
        case TELOPT_EXOPL:
        case TELOPT_COMPRESS:
        case TELOPT_MSDP:
            return NO;            
    }
    
    return NO;
}

- (void) sendSuboption:(unsigned char)option withData:(NSData *)data
{
    unsigned char start[3] = { IAC, SB, option };
    unsigned char end[2] = { IAC, SE };
    
    NSMutableData *endResult = [NSMutableData dataWithCapacity:[data length] + 5];
    [endResult appendBytes:start length:3];
    [endResult appendData:data];
    [endResult appendBytes:end length:2];
    
    [[self world] sendDataRaw:endResult];
}

- (void) resendNaws
{
    NSMutableData *terminfo = [NSMutableData data];
    
    UInt16 width = (UInt16)[[self world] mainScreenWidth];
    UInt16 height = (UInt16)[[self world] mainScreenHeight];
    
    unsigned char tbyte = (width & 0xFF00) >> 8;
    [terminfo appendBytes:&tbyte length:1];
    if (tbyte == 0xFF) {
        [terminfo appendBytes:&tbyte length:1];
    }
    
    tbyte = width & 0xFF;
    [terminfo appendBytes:&tbyte length:1];
    if (tbyte == 0xFF) {
        [terminfo appendBytes:&tbyte length:1];
    }                
    
    tbyte = (height & 0xFF00) >> 8;
    [terminfo appendBytes:&tbyte length:1];
    if (tbyte == 0xFF) {
        [terminfo appendBytes:&tbyte length:1];
    }                
    
    tbyte = height & 0xFF;
    [terminfo appendBytes:&tbyte length:1];
    if (tbyte == 0xFF) {
        [terminfo appendBytes:&tbyte length:1];
    }
    
    [self sendSuboption:TELOPT_NAWS withData:terminfo];
    
}

- (void) screenUpdated:(NSNotification *) notification
{
    if (telnetSessionData->local[TELOPT_NAWS] == TQ_YES) {
        [self resendNaws];
    }
}

- (void) worldConnected:(NSNotification *) notification
{
    ttypeCycle = 0;
    [telnetSessionData clear];
    int keepalive = [[[self world] preferenceForKey:@"atlantis.network.keepalive"] intValue];
    if ((keepalive == 1) || (keepalive == 2)) {
        [self performSelector:@selector(beginFiringNops) withObject:nil afterDelay:30];
    }
    int serverType = [[[self world] preferenceForKey:@"atlantis.world.codebase"] intValue];
    if ((serverType == AtlantisServerMud) || (serverType == AtlantisServerIRE))
        mudProtocol = YES;
    else 
        mudProtocol = NO;
}

- (void) worldDisconnected:(NSNotification *) notification
{
    if (_rdNopTimer) {
        [_rdNopTimer invalidate];
        [_rdNopTimer release];
        _rdNopTimer = nil;
    }
}

- (void) nopTimerFired:(NSTimer *) timer
{
    int keepalive = [[[self world] preferenceForKey:@"atlantis.network.keepalive"] intValue];
    NSMutableData *tempdata = [NSMutableData data];
    
    if ((keepalive == 0) || (keepalive == 1)) {             
        unsigned char tempchar = IAC;
        [tempdata appendBytes:&tempchar length:1];
        tempchar = NOP;
        [tempdata appendBytes:&tempchar length:1];
        [[self world] sendDataRaw:tempdata];
    }
    else if (keepalive == 2) {
        unsigned char tempchar = '\n';
        [tempdata appendBytes:&tempchar length:1];
        [[self world] sendDataRaw:tempdata];
    }
}

- (void) beginFiringNops
{
    int keepalive = [[[self world] preferenceForKey:@"atlantis.network.keepalive"] intValue];
    if (!_rdNopTimer && (keepalive != 3)) {
        _rdNopTimer = [[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(nopTimerFired:) userInfo:nil repeats:YES] retain];    
    }
}

- (void) processSuboption:(unsigned char)option withData:(NSData *)data
{
    unsigned const char *tdata = [data bytes];
 
    switch (option) {
        case TELOPT_CHARSET:
        {

            // See RFC 2066
            unsigned char sep;
            const unsigned char *scan = tdata;
            const unsigned char *end = tdata + [data length];
            switch (*scan++) {
                case 01:
                {
                    // REQUEST
                    NSMutableArray *serverEncoding = [NSMutableArray array];

                    const unsigned char *scanend;
                    BOOL ttable = !memcmp(scan, "[TTABLE]", 8);
                    
                    if (ttable) 
                        scan += 9;

                    sep = *(scan++);
                    
                    for (scanend = scan; scanend < end; scanend++) {
                        if (*scanend == sep) {
                            [serverEncoding addObject:[NSString stringWithCString:(const char *)scan length:(scanend - scan)]];
                            scan = scanend + 1;
                        }
                    }

                    [serverEncoding addObject:[NSString stringWithCString:(const char *)scan length:(scanend - scan)]];
                    
                    {
                        NSEnumerator *encodeEnum = [serverEncoding objectEnumerator];
                        NSString *encode;
                        BOOL found = NO;
                        
                        if ([[self world] stringEncoding] != -1) {
                            // If we have a manually-set encoding, we will check if it's in the list.
                            CFStringEncoding currentEncoding = CFStringConvertNSStringEncodingToEncoding([[self world] stringEncoding]);
                            CFStringRef currentEncodingName = CFStringConvertEncodingToIANACharSetName(currentEncoding);
                            
                            if ([serverEncoding containsObject:(NSString *)currentEncodingName] && ([[self world] stringEncoding] != NSASCIIStringEncoding)) {
                                found = YES;
                                NSMutableData *d = [NSMutableData data];
                                uint8_t accepted = 2;
                                [d appendBytes:&accepted length:1];
                                [d appendData:[(NSString *)currentEncodingName dataUsingEncoding:NSASCIIStringEncoding] ];
                                [self sendSuboption:TELOPT_CHARSET withData:d];
                                [[self world] handleStatusOutput:[NSString stringWithFormat:@"Negotiated string encoding: %@\n", [NSString localizedNameOfStringEncoding:[[self world] stringEncoding]]]];
                            }
                        }
                        
                        // RFC 2066 requires charsets to be in preferred order.
                        while ((encode = [encodeEnum nextObject]) && !found) {
                            CFStringEncoding testEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)encode);
                            if (testEncoding != kCFStringEncodingInvalidId) {
                                found = YES;
                                NSStringEncoding realEncoding = (NSStringEncoding)CFStringConvertEncodingToNSStringEncoding(testEncoding); 
                                NSMutableData *d = [NSMutableData data];
                                uint8_t accepted = 2;
                                [d appendBytes:&accepted length:1];
                                [d appendData:[encode dataUsingEncoding:NSASCIIStringEncoding] ];
                                [self sendSuboption:TELOPT_CHARSET withData:d];
                                [[self world] handleStatusOutput:[NSString stringWithFormat:@"Negotiated string encoding: %@\n", [NSString localizedNameOfStringEncoding:realEncoding]]];
                                [[self world] setStringEncoding:realEncoding];
                            }
                        }
                    
                        if (!found) {
                            uint8_t rejected = 3;
                            [self sendSuboption:TELOPT_CHARSET withData:[NSData dataWithBytes:&rejected length:1]];
                        }
                    }
                }
            }
        }
        break;
            
        case TELOPT_TTYPE:
        {
            if (*tdata == TELQUAL_SEND) {
                unsigned char ISc = TELQUAL_IS;
                
                NSMutableData *terminfo = [NSMutableData data];
                [terminfo appendBytes:&ISc length:1];
                
                switch (ttypeCycle) {
                    case 0:
                    {
                        const char *termname = "Atlantis";
                        [terminfo appendBytes:termname length:strlen(termname)];
                    }
                    break;
                    
                    case 1:
                    {
                        const char *termname = "Atlantis-256color";
                        [terminfo appendBytes:termname length:strlen(termname)];
                    }
                    break;
                    
                    case 2:
                    {
                        const char *termname = "xterm-256color";
                        [terminfo appendBytes:termname length:strlen(termname)];
                    }
                    break;
                    
                    case 3:
                    {
                        const char *termname = "xterm-256color";
                        [terminfo appendBytes:termname length:strlen(termname)];
                    }
                    break;
                }
                
                ttypeCycle++;
                if (ttypeCycle > 3)
                    ttypeCycle = 0;
                
                [self sendSuboption:TELOPT_TTYPE withData:terminfo];
            }
        }
            break;
        
        case TELOPT_NAWS:
        {
            if (*tdata == TELQUAL_SEND) {
                [self resendNaws];
            }
        }
            break;
        
        case TELOPT_COMPRESS2:
        {
            [[self world] compress:YES];            
        }
            break;
            
        case TELOPT_MSDP:
        {
        
        }
            break;
    }
}

- (BOOL) supportsOption:(unsigned char)option
{
    switch (option) {
        case TELOPT_BINARY:
        case TELOPT_SGA:
        case TELOPT_NAWS:
        case TELOPT_TTYPE:
        case TELOPT_EOR:
        case TELOPT_ECHO:
        case TELOPT_CHARSET:
            return YES;
            
        case TELOPT_MSDP:
        case TELOPT_TM:
        case TELOPT_SNDLOC:
        case TELOPT_TSPEED:
        case TELOPT_LFLOW:
        case TELOPT_LINEMODE:
        case TELOPT_COMPRESS:
        case TELOPT_COMPRESS2:
            return NO;
    }
    
    return NO;
}

const unsigned char * findCharInBlock(const unsigned char needle, const unsigned char *haystack, unsigned long length)
{
    const unsigned char *result = NULL;
    const unsigned char *ptr = haystack;
    
    if (!ptr || !haystack)
        return NULL;
    
    while (!result && (ptr <= (haystack + length))) {
        if (*ptr == needle) 
            result = ptr;
        else
            ptr++;
    }
    
    return result;
}

- (void) filterOutput:(id)object
{
    if ([object isKindOfClass:[NSMutableData class]])
    {
        const unsigned char *scandata = [object bytes];
        unsigned long length = [(NSData *)object length];

        NSMutableData *finalData = [NSMutableData dataWithCapacity:(length * 2)];
        NSMutableData *realData = (NSMutableData *)object;
        const unsigned char *ptr = findCharInBlock(IAC,scandata,length);
        const unsigned char *lastPtr = scandata;
        const unsigned char *endmark = scandata + length;
        unsigned char tempchar = IAC;
        
        while (ptr && (ptr < endmark)) {
            [finalData appendBytes:lastPtr length:(lastPtr - ptr)];
            [finalData appendBytes:&tempchar length:1];
            lastPtr = ptr + 1;
            if (ptr < endmark)
                ptr = findCharInBlock(IAC,lastPtr,(endmark - lastPtr));
        }
        [finalData appendBytes:lastPtr length:(endmark - lastPtr)];
        [realData setLength:0];
        [realData appendData:finalData];
    }
}

- (void) filterInput:(id)object
{
    if ([object isKindOfClass:[NSMutableData class]]) 
    {
        unsigned char promptMark[] = { '\x1b', '[', '1', 'a', '\n' };
        const unsigned char *scandata = [object bytes];
        unsigned long length = [(NSData *)object length];
        
        const unsigned char *ptr = findCharInBlock(IAC,scandata,length);
        
        if (!ptr) {
            ptr = scandata;
        }
        else {          
            NSMutableData *final = [NSMutableData dataWithCapacity:length + 4];
            
            const unsigned char *endmark = scandata + length;
            const unsigned char *lastMarker = NULL;
            
            unsigned char subnegNumber = 0;
            int state = scanNormal;
            
            NSMutableData *subnegData = [NSMutableData data];
            ptr = scandata;
            
            while (ptr && (ptr < endmark)) {
                
                switch (state) {
                    case scanNormal:
                    {
                        lastMarker = ptr;
                        ptr = findCharInBlock(IAC,ptr,endmark - ptr);
                        if (ptr) {
                            state = scanIAC;
                            if (ptr != lastMarker) {
                                [final appendBytes:lastMarker length:(ptr - lastMarker)];
                            }
                        }
                        else {
                            ptr = endmark;
                            if (lastMarker < endmark) {
                                [final appendBytes:lastMarker length:(endmark - lastMarker)];
                            }
                        }
                    }
                        break;
                        
                    case scanIAC:
                    {                        
                        switch(*ptr) {
                            case IAC: [final appendBytes:ptr length:1]; state = scanNormal; break;
                            case DONT: state = scanDONT; break;
                            case DO: state = scanDO; [self beginFiringNops]; break;
                            case WILL: state = scanWILL; break;
                            case WONT: state = scanWONT; break;
                            case NOP: state = scanNormal; break; // Yay, we support MUX keepalive
                            case DM: break;
                            case SB: state = scanSB; break;
                            case GA: [final appendBytes:&promptMark length:5]; state = scanNormal; break; // Longer term, fix this!
                            case EOR: [final appendBytes:&promptMark length:5]; state = scanNormal; break; // No newline here.
                        }
                    }
                        break;
                                                
                    case scanWILL:
                    {
                        switch (telnetSessionData->remote[*ptr]) {
                            case TQ_NO:
                                if ([self prefersOption:*ptr]) {
                                    telnetSessionData->remote[*ptr] = TQ_YES;
                                    [self sendState:DO forOption:*ptr];
                                    if (*ptr == TELOPT_NAWS) {
                                        [self resendNaws];
                                    }
                                }
                                else {
                                    [self sendState:DONT forOption:*ptr];
                                }
                                state = scanNormal;
                                break;
                                
                            case TQ_YES: 
                                [self sendState:DO forOption:*ptr];
                                state = scanNormal;
                                break; // We... already told them yes.  But what the heck
                                
                            case TQ_WANTNO:
                                // This is seriously wrong.  Warn?
                                if (telnetSessionData->remoteQ[*ptr] == TQ_EMPTY)
                                    telnetSessionData->remote[*ptr] = TQ_NO;
                                else
                                    telnetSessionData->remote[*ptr] = TQ_YES;
                                state = scanNormal;
                                break;
                                
                            case TQ_WANTYES:
                                if (telnetSessionData->remoteQ[*ptr] == TQ_EMPTY) 
                                    telnetSessionData->remote[*ptr] = TQ_YES;
                                else {
                                    telnetSessionData->remote[*ptr] = TQ_WANTNO;
                                    telnetSessionData->remoteQ[*ptr] = TQ_EMPTY;
                                }
                                    state = scanNormal;
                                    break;
                        }
                    }
                        break;
                        
                    case scanWONT:
                    {
                        switch (telnetSessionData->remote[*ptr]) {
                            case TQ_NO:
                                //[self sendState:DONT forOption:*ptr];                            
                                state = scanNormal;
                                break;
                                
                            case TQ_YES:
                                telnetSessionData->remote[*ptr] = TQ_NO;
                                [self sendState:DO forOption:*ptr];
                                state = scanNormal;
                                break;
                                
                            case TQ_WANTNO:
                                if (telnetSessionData->remoteQ[*ptr] == TQ_EMPTY)
                                    telnetSessionData->remote[*ptr] = TQ_NO;
                                else {
                                    telnetSessionData->remote[*ptr] = TQ_WANTYES;
                                    telnetSessionData->remoteQ[*ptr] = TQ_EMPTY;
                                    [self sendState:DO forOption:*ptr];
                                }
                                state = scanNormal;
                                    break;
                                
                            case TQ_WANTYES:
                                if (telnetSessionData->remoteQ[*ptr] == TQ_EMPTY)
                                    telnetSessionData->remote[*ptr] = TQ_NO;
                                else {
                                    telnetSessionData->remote[*ptr] = TQ_NO;
                                    telnetSessionData->remoteQ[*ptr] = TQ_EMPTY;
                                }
                                state = scanNormal;
                                    break;
                        }

                    }
                        break;
                        
                    case scanDO:
                    {
                        switch(telnetSessionData->local[*ptr]) {
                            case TQ_NO:
                                if ([self supportsOption:*ptr]) {
                                    telnetSessionData->local[*ptr] = TQ_YES;
                                    [self sendState:WILL forOption:*ptr];
                                    if (*ptr == TELOPT_NAWS) {
                                        [self resendNaws];
                                    }
                                }
                                else {
                                    [self sendState:WONT forOption:*ptr];
                                }
                                state = scanNormal;
                                break;
                                
                            case TQ_YES:
                                [self sendState:WILL forOption:*ptr];
                                state = scanNormal;
                                break;
                                
                            case TQ_WANTNO:
                                // This... is wrong
                                if (telnetSessionData->localQ[*ptr] == TQ_EMPTY)
                                    telnetSessionData->local[*ptr] = TQ_NO;
                                else
                                    telnetSessionData->local[*ptr] = TQ_YES;
                                state = scanNormal;
                                break;
                                
                            case TQ_WANTYES:
                                if (telnetSessionData->localQ[*ptr] == TQ_EMPTY)
                                    telnetSessionData->local[*ptr] = TQ_YES;
                                else {
                                    telnetSessionData->local[*ptr] = TQ_WANTNO;
                                    telnetSessionData->localQ[*ptr] = TQ_EMPTY;
                                    [self sendState:WONT forOption:*ptr];
                                }
                                state = scanNormal;
                                    
                        }
                    }
                        break;
                        
                    case scanDONT:
                    {
                        switch (telnetSessionData->local[*ptr]) {
                            case TQ_NO:
                                // For the sake of mutant implementations, we
                                // do not send in this case.
                                // [self sendState:WONT forOption:*ptr];
                                state = scanNormal;
                                break;
                            case TQ_YES:
                                telnetSessionData->local[*ptr] = TQ_NO;
                                [self sendState:WONT forOption:*ptr];
                                state = scanNormal;
                                break;
                                
                            case TQ_WANTNO:
                                if (telnetSessionData->localQ[*ptr] == TQ_EMPTY)
                                    telnetSessionData->local[*ptr] = TQ_NO;
                                else {
                                    telnetSessionData->local[*ptr] = TQ_NO;
                                    telnetSessionData->localQ[*ptr] = TQ_EMPTY;
                                    [self sendState:WILL forOption:*ptr];
                                }
                                    state = scanNormal;
                                    break;
                                
                            case TQ_WANTYES:
                                if (telnetSessionData->localQ[*ptr] == TQ_EMPTY)
                                    telnetSessionData->local[*ptr] = TQ_NO;
                                else {
                                    telnetSessionData->local[*ptr] = TQ_NO;
                                    telnetSessionData->localQ[*ptr] = TQ_EMPTY;
                                }
                                    state = scanNormal;
                                    break;
                                
                        }
                    }
                        break;
                        
                    case scanSB:
                    {
                        state = scanSBdata;
                        subnegNumber = *ptr;
                        [subnegData setLength:0];
                    }
                        break;
                        
                    case scanSBdata:
                    {
                        if (*ptr == IAC)
                            state = scanSBIAC;
                        else
                            [subnegData appendBytes:ptr length:1];
                    }
                        break;
                        
                    case scanSBIAC:
                    {
                        if (*ptr == IAC) {
                            [subnegData appendBytes:ptr length:1];
                        }
                        else if (*ptr == SE) {
                            if (subnegNumber == TELOPT_COMPRESS2) {
                                NSMutableData *compressHolderData = [NSMutableData data];
                                
                                [compressHolderData appendBytes:(ptr + 1) length:(endmark - (ptr + 1))];
                                [[self world] addBytesToCompress:compressHolderData];
                                [(NSMutableData *)object setLength:0];
                                [(NSMutableData *)object appendData:final];
                                ptr = endmark;
                            }
                            [self processSuboption:subnegNumber withData:subnegData];
                            state = scanNormal;
                        }
                    }
                        
                }
                
                ptr++;
            }
            [(NSMutableData *)object setLength:0];
            [(NSMutableData *)object appendData:final];
        }
    }
}

@end