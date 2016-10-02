#import <Foundation/Foundation.h>
@interface HIDIdleTime : NSObject {
   io_registry_entry_t _hidEntry;
}
- (uint64_t)idleTime;
- (unsigned)idleTimeInSeconds;
@end