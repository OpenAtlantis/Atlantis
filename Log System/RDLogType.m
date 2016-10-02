//
//  RDLogType.m
//  Atlantis
//
//  Created by Rachel Blackman on 2/14/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDLogType.h"
#import "AtlantisState.h"

@implementation RDLogType

+ (NSString *) logtypeName
{
    // TODO: Localize
    return @"Base Logfile (this should not be here!)";
}

+ (BOOL) canAppendToLog
{
    return NO;
}

+ (BOOL) supportsOptions
{
    return NO;
}

+ (NSString *) shortTypeName
{
    return @"baselog";
}

- (NSDictionary *) configureOptions:(NSDictionary *)oldOptions
{
    return nil;
}

- (id) initWithFilename:(NSString *)filename forSpawn:(NSString *)spawnPath inWorld:(RDAtlantisWorldInstance *)world
{
    return [self initWithFilename:filename forSpawn:spawnPath inWorld:world withOptions:nil];
}

- (id) initWithFilename:(NSString *)filename forSpawn:(NSString *)spawnPath inWorld:(RDAtlantisWorldInstance *)world withOptions:(NSDictionary *)options
{
    self = [super init];
    if (self) {
        _rdFilename = [[[filename stringByExpandingTildeInPath] stringByStandardizingPath] retain];

        if (spawnPath)
            _rdSpawnPath = [[NSString stringWithString:spawnPath] retain];
        else
            _rdSpawnPath = nil;

        if (world)
            _rdWorld = [world retain];
        else
            _rdWorld = nil;

        if (options) 
            _rdOptions = [[NSDictionary dictionaryWithDictionary:options] retain];
        else
            _rdOptions = [[self defaultOptions] retain];
            
        _rdLogfile = nil;
        _rdTimestamps = NO;
    }
    return self;
}

- (void) dealloc
{
    [self closeFile];
    [_rdOptions release];
    [_rdLogfile release];
    [_rdFilename release];
    [_rdSpawnPath release];
    [_rdWorld release];
    [super dealloc];
}

- (void) setWriteTimestamps:(BOOL) timestamps
{
    _rdTimestamps = timestamps;
}

- (BOOL) writeTimestamps
{
    return _rdTimestamps;
}

- (NSString *) shortTypeName
{
    return [[self class] shortTypeName];
}

- (NSString *) description
{
    // TODO: Localize
    NSString *baseLine = @"%@ (%@%@)";
    NSString *spawnLine = @"%@ only";
    
    NSString *spawnData = nil;
    if ([self spawnPath]) {
        spawnData = [NSString stringWithFormat:spawnLine, [self spawnPath]];
    }

    NSString *fileonly = [[self filename] lastPathComponent];

    return [NSString stringWithFormat:baseLine, fileonly, [self shortTypeName], spawnData ? spawnData : @""];    
}

- (NSDictionary *) options
{
    return _rdOptions;
}

- (NSDictionary *) defaultOptions
{
    return nil;
}

- (BOOL) createDirectoriesToFile
{
    NSArray *pathComponents = [[[self filename] stringByDeletingLastPathComponent] pathComponents];
    
    NSString *currentPath = @"";
    NSFileManager *fileman = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    NSEnumerator *pathEnum = [pathComponents objectEnumerator];
    NSString *pathFragment = @"/";
    
    do {
        currentPath = [currentPath stringByAppendingPathComponent:pathFragment];
        if ([fileman fileExistsAtPath:currentPath isDirectory:&isDirectory]) {
            if (!isDirectory)
                return NO;
        }
        else {
            if (![fileman createDirectoryAtPath:currentPath attributes:nil])
                return NO;
        }
    } while (pathFragment = [pathEnum nextObject]);

    return YES;
}

- (void) findGoodFilename
{
    NSString *extension = [[self filename] pathExtension];
    NSString *baseline;
    if (extension && [extension length])
        baseline = [[self filename] substringWithRange:NSMakeRange(0,[[self filename] length] - ([extension length] + 1))];
    else
        baseline = [self filename];
        
    int counter = 1;
    NSString *testFilename;
    
    if (extension && [extension length])
        testFilename = [NSString stringWithFormat:@"%@-%d.%@", baseline, counter, extension];
    else
        testFilename = [NSString stringWithFormat:@"%@-%d", baseline, counter];

    NSFileManager *fileman = [NSFileManager defaultManager];
    
    while ([fileman fileExistsAtPath:testFilename]) {
        counter++;
        if (extension && [extension length])
            testFilename = [NSString stringWithFormat:@"%@-%d.%@", baseline, counter, extension];
        else
            testFilename = [NSString stringWithFormat:@"%@-%d", baseline, counter];
    }
    
    [_rdFilename release];
    _rdFilename = [testFilename retain];    
}

- (BOOL) openFile 
{
    BOOL appendOk = [[self class] canAppendToLog];

    NSFileManager *fileman = [NSFileManager defaultManager];

    BOOL isDirectory;

    if ([fileman fileExistsAtPath:[self filename] isDirectory:&isDirectory]) {            
        if (isDirectory)
            return NO;

        if (!appendOk) {
            [self findGoodFilename];

            if (![self createDirectoriesToFile])
                return NO;
            
            if (![fileman createFileAtPath:[self filename] contents:[NSData data] attributes:nil])
                return NO;        
        }
        
        if (![fileman isWritableFileAtPath:[self filename]])
            return NO;
    }
    else {    
        // Make our file
        if (![self createDirectoriesToFile])
            return NO;
            
        if (![fileman createFileAtPath:[self filename] contents:[NSData data] attributes:nil])
            return NO;        
    }

    _rdLogfile = [NSFileHandle fileHandleForWritingAtPath:_rdFilename];
    if (_rdLogfile) {
        [_rdLogfile retain];
        [_rdLogfile seekToEndOfFile];   // Ensure we're at the end for appends

        // TODO: Localize
        NSString *outputString = @"Began logging to file: %@";        
        [_rdWorld outputStatus:[NSString stringWithFormat:outputString,[self filename]] toSpawn:[self spawnPath]];
        return YES;
    }
    
    return NO;
}

- (BOOL) closeFile
{
    if (_rdLogfile) {
        [_rdLogfile closeFile];
        [_rdLogfile release];
        _rdLogfile = nil;

        // TODO: Localize
        NSString *outputString = @"Closed logfile: %@";        
        [_rdWorld outputStatus:[NSString stringWithFormat:outputString,[self filename]] toSpawn:[self spawnPath]];
    }
    return YES;
}

- (BOOL) isOpen
{
    if (_rdLogfile) {
        return YES;
    }
    
    return NO;
}

- (NSString *) filename
{
    return _rdFilename;
}

- (NSString *) spawnPath
{
    return _rdSpawnPath;
}

- (NSFileHandle *) fileHandle
{
    return _rdLogfile;
}

- (RDAtlantisWorldInstance *) world
{
    return _rdWorld;
}

- (BOOL) shouldWriteForState:(AtlantisState *)state
{
    if (_rdSpawnPath) {
        NSString *viewPath = [state spawnPath];
        if (viewPath) {
            if ([viewPath isEqualToString:_rdSpawnPath])
                return YES;
        }
        
        return NO;
    }
    
    return YES;
}

- (void) writeStringToFile:(NSString *)string
{
    if ([self isOpen]) {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        [[self fileHandle] writeData:data];
    }
}

- (void) writeString:(NSAttributedString *)string withState:(AtlantisState *)state
{
    // Nothing
}

/* Template

+ (NSString *) logtypeName
{
    // TODO: Localize
    return @"typename here";
}

+ (BOOL) canAppendToLog;

- (id) initWithFilename:(NSString *)filename forSpawn:(NSString *)spawnPath inWorld:(RDAtlantisWorldInstance *)world
{
    self = [super initWithFilename:filename forSpawn:spawnPath inWorld:world];
    if (self) {
    
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (NSString *) shortTypeName
{
    // TODO: Localize
    return @"type";
}

- (BOOL) openFile 
{
    if ([super openFile]) {
        // Any initial file header stuff here
    }
}

- (BOOL) closeFile
{
    if ([self isOpen]) {
        // Any final footer stuff here
    }
    return [super closeFile];
}

- (void) writeString:(NSAttributedString *)string withState:(AtlantisState *)state
{
    // If this line is marked 'omit from logs,' we, well, omit it from logs.
    NSRange effRange;
    NSDictionary *attrs = [string attributesAtIndex:0 effectiveRange:&effRange];
    if ([attrs objectForKey:@"RDLogOmitLine"])
        return;

    // Alter this as appropriate.
}


 */

@end
