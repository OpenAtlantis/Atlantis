#import "HIDIdleTime.h"

#define NS_SECONDS 1000000000 // 10^9 -- number of ns in a second


@implementation HIDIdleTime

- (id)init {
   self = [super init];
   if( self ) {
       mach_port_t masterPort;
       kern_return_t err = IOMasterPort( MACH_PORT_NULL, &masterPort );
       if (err != KERN_SUCCESS)
        return nil;
       
       io_iterator_t  hidIter;
       err = IOServiceGetMatchingServices( masterPort, IOServiceMatching("IOHIDSystem"), &hidIter );
       if ((err != KERN_SUCCESS) || !hidIter)
       
       _hidEntry = IOIteratorNext( hidIter );
       IOObjectRelease(hidIter);
   }
   return self;
}

- (void)dealloc {
   if( _hidEntry ) {
       IOObjectRelease( _hidEntry );
   }
   [super dealloc];
}

- (uint64_t)idleTime {
   NSMutableDictionary *hidProperties;
   kern_return_t err = IORegistryEntryCreateCFProperties( _hidEntry,(CFMutableDictionaryRef*) &hidProperties, kCFAllocatorDefault, 0 );
   if (!hidProperties || (err != KERN_SUCCESS))
    return 0;
   [hidProperties autorelease];
   
   id hidIdleTimeObj = [hidProperties objectForKey:@"HIDIdleTime"];
   if (!([hidIdleTimeObj isKindOfClass:[NSData class]] || [hidIdleTimeObj isKindOfClass:[NSNumber class]]))
    return 0;
   uint64_t result;
   if( [hidIdleTimeObj isKindOfClass:[NSData class]] ) {
        if (![(NSData*)hidIdleTimeObj length] == sizeof( result ) ) {
            return 0;
        }
       [hidIdleTimeObj getBytes:&result];
   } else {
       result = [hidIdleTimeObj longLongValue];
   }
   
   return result;
}

- (unsigned)idleTimeInSeconds {
   return [self idleTime] / NS_SECONDS;
}

@end