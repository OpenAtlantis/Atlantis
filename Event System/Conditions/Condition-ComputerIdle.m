//
//  Condition-ComputerIdle.m
//  Atlantis
//
//  Created by Rachel Blackman on 4/10/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "Condition-ComputerIdle.h"
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <IOKit/IOKitLib.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

/* 10^9 --  number of ns in a second */
#define NS_SECONDS 1000000000

@implementation Condition_ComputerIdle

+ (NSString *) conditionName
{
    // TODO: Localize
    return @"Computer: System has been idle for at least ...";
}

+ (NSString *) conditionDescription
{
    // TODO: Localize
    return @"Execute this event when the computer has been idle and unused for the given number of seconds.";
}

- (NSString *) conditionDescription
{
    NSString *string = [[NSString stringWithFormat:@"Computer has been idle %d seconds.", _rdInterval] retain];
    
    return [string autorelease];
}

- (id) init
{
    self = [super init];
    if (self) {
        _rdInterval = 600;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _rdInterval = [coder decodeDoubleForKey:@"idle.interval"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder
{
    [super encodeWithCoder:coder];
    [coder encodeDouble:_rdInterval forKey:@"idle.interval"];
}

#pragma mark Execution

UInt64 SystemIdleTime()
{    
    mach_port_t masterPort;
    io_iterator_t iter;
    io_registry_entry_t curObj;
    
    IOMasterPort(MACH_PORT_NULL, &masterPort);
    
    /* Get IOHIDSystem */
    IOServiceGetMatchingServices(masterPort,
                                 IOServiceMatching("IOHIDSystem"),
                                 &iter);
    if (iter == 0) {
        return 0;
    }
    
    curObj = IOIteratorNext(iter);
    
    if (curObj == 0) {
        return 0;
    }
    
    CFMutableDictionaryRef properties = 0;
    CFTypeRef obj;
    
    if (IORegistryEntryCreateCFProperties(curObj, &properties,
                                          kCFAllocatorDefault, 0) ==
        KERN_SUCCESS && properties != NULL) {
        
        obj = CFDictionaryGetValue(properties, CFSTR("HIDIdleTime"));
        if (obj)
            CFRetain(obj);
    } else {
        obj = NULL;
    }
    
    UInt64 tHandle = 0;
    
    if (obj) {
        
        CFTypeID type = CFGetTypeID(obj);
        
        if (type == CFDataGetTypeID()) {
            CFDataGetBytes((CFDataRef) obj,
                           CFRangeMake(0, sizeof(tHandle)),
                           (UInt8*) &tHandle);
        }  else if (type == CFNumberGetTypeID()) {
            CFNumberGetValue((CFNumberRef)obj,
                             kCFNumberSInt64Type,
                             &tHandle);
        } else {
            return 0;
        }

        CFRelease(obj);
        
        // essentially divides by 10^9
        tHandle >>= 30;
    } else {
        return 0;
    }
    
    /* Release our resources */
    IOObjectRelease(curObj);
    IOObjectRelease(iter);
    CFRelease((CFTypeRef)properties);
    
    return tHandle;
}

- (BOOL) isTrueForState:(AtlantisState *) state
{
    unsigned idleTime = SystemIdleTime();

    if (idleTime >= _rdInterval)
        return YES;
    
    return NO;
}

#pragma mark Configuration

- (void) controlTextDidEndEditing:(NSNotification *) notification
{
    _rdInterval = [_rdActualText doubleValue];
}


- (NSView *) conditionConfigurationView
{
    if (!_rdInternalConfigurationView) {
        [NSBundle loadNibNamed:@"CondConf_ComputerIdle" owner:self];
    }

    [_rdActualText setDelegate:self];
    [_rdActualText setDoubleValue:_rdInterval];
    
    return _rdInternalConfigurationView;
}

@end
