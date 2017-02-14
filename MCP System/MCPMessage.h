//
//  MCPMessage.h
//  Atlantis
//
//  Created by Rachel Blackman on 8/6/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MCPMessage : NSObject {

    NSString                *_rdNamespace;
    NSString                *_rdCommand;
    NSMutableDictionary     *_rdAttributes;
    NSString                *_rdSessionKey;
    NSMutableArray          *_rdAttributeOrder;

    BOOL                     _rdFinished;
    BOOL                     _rdCompat10;

}

- (id) initWithNamespace:(NSString *) mcpNamespace command:(NSString *)command;

- (void) addText:(NSString *)text toAttribute:(NSString *)attribute;
- (void) removeAttribute:(NSString *)attribute;
- (void) makeAttributeMultiline:(NSString *)attribute;

- (BOOL) attributeIsMultiline:(NSString *)attribute;
- (NSString *) attributeText:(NSString *)attribute;
- (NSString *) attributeTextLinefeed:(NSString *)attribute;
- (NSArray *) attributeLines:(NSString *)attribute;
- (NSArray *) attributes;

- (NSString *) namespace;
- (NSString *) command;
- (void) setSessionKey:(NSString *)key;

- (BOOL) finished;
- (void) setFinished:(BOOL) finished;

- (BOOL) compat10;
- (void) setCompat10:(BOOL) legacy;

- (NSString *) messageString;

@end
