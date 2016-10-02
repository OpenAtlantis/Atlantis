//
//  NSDictionary+XMLPersistence.m
//  TestPadDataReader
//
//	Created by Uli Kusterer on 07.10.04.
//  Copyright (c) 2004 M. Uli Kusterer. All rights reserved.
//

#import "NSDictionary+XMLPersistence.h"
#import "UKXMLPersistence.h"


@implementation NSDictionary (UKXMLPersistence)

+(id)			dictionaryWithXML: (NSString*)str
{
	return [(NSDictionary*) UKCreateDictionaryFromXML( (CFStringRef) str, kUKXMLCreateDictionaryDefaultFlags ) autorelease];
}


+(id)			dictionaryWithXML: (NSString*)str flags: (unsigned int)flags
{
	return [(NSDictionary*) UKCreateDictionaryFromXML( (CFStringRef) str, flags ) autorelease];
}

+(id)			dictionaryWithContentsOfXMLFile: (NSString*)path
{
	NSString*	str = [NSString stringWithContentsOfFile: path];
	
	return [[self class] dictionaryWithXML: str];
}


+(id)			dictionaryWithContentsOfXMLFile: (NSString*)path flags: (unsigned int)flags
{
	NSString*	str = [NSString stringWithContentsOfFile: path];
	
	return [[self class] dictionaryWithXML: str flags: flags];
}


-(NSString*)	xmlRepresentation
{
	return [(NSString*) UKCreateXMLFromDictionary( (CFDictionaryRef) self, kUKXMLCreateXMLDefaultFlags ) autorelease];
}


-(NSString*)	xmlRepresentationWithFlags: (unsigned int)flags
{
	return [(NSString*) UKCreateXMLFromDictionary( (CFDictionaryRef) self, flags ) autorelease];
}


-(BOOL)			writeToXMLFile: (NSString*)path atomically: (BOOL)atm
{
	NSString*	str = [self xmlRepresentation];
	
	return [str writeToFile: path atomically: atm];
}


-(BOOL)			writeToXMLFile: (NSString*)path atomically: (BOOL)atm flags: (unsigned int)flags
{
	NSString*	str = [self xmlRepresentationWithFlags: flags];
	
	return [str writeToFile: path atomically: atm];
}


@end