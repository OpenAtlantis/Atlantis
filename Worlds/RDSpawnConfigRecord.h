//
//  RDSpawnConfigRecord.h
//  Atlantis
//
//  Created by Rachel Blackman on 2/11/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RDStringPattern.h"

@interface RDSpawnConfigRecord : NSObject <NSCoding> {

    NSArray                     *_rdPatterns;
    NSArray                     *_rdExceptions;
    NSString                    *_rdSpawnPath;
    
    unsigned                     _rdSpawnWeight;
    BOOL                         _rdDefaultsActive;
    NSArray                     *_rdActiveExceptions;
    NSString                    *_rdSpawnPrefix;
    
    unsigned                     _rdMaxLines;
    BOOL                         _rdStatusBar;

}

- (id) initWithPath:(NSString *)path forPatterns:(NSArray *)patterns withExceptions:(NSArray *)exceptions weight:(unsigned)weight defaultsActive:(BOOL)active activePatterns:(NSArray *)activePatterns maxLines:(unsigned)lines prefix:(NSString *)prefix statusBar:(BOOL)status;

- (NSString *) path;
- (BOOL) matches:(NSString *) string;

- (unsigned) weight;
- (BOOL) defaultActive;
- (NSArray *) activeExceptions;

- (NSArray *) patterns;
- (NSArray *) exceptions;

- (NSString *) prefix;
- (void) setPrefix:(NSString *)prefix;

- (BOOL) statusBar;
- (void) setStatusBar:(BOOL)statusBar;

- (unsigned) maxLines;

@end
