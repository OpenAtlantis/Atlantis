/*
 *  UKXMLPersistence.h
 *  
 *
 *  Created by Uli Kusterer on 07.10.04.
 *  Copyright 2004 M. Uli Kusterer. All rights reserved.
 *
 */

#include <CoreFoundation/CoreFoundation.h>


CFDictionaryRef	UKCreateDictionaryFromXML( CFStringRef padStr, unsigned int flags );
CFStringRef		UKCreateXMLFromDictionary( CFDictionaryRef ref, unsigned int flags );


// Flags for UKCreateDictionaryFromXML and UKCreateXMLFromDictionary
#define	kUKXMLNoXMLHeadTag		(1 << 0)		// Means you don't want an "?xml" entry added to the dictionary, or you don't want an automatically generated <?xml ...?> tag added to the top of the file when it's missing.
#define	kUKXMLNoEmptyTags		(1 << 1)		// XML output only: If a tag contains an empty string, omit the tag instead of generating an empty tag for it (<foo />).
#define	kUKXMLDontIndent		(1 << 2)		// XML output only: Do not indent the tags according to their nesting depth. This saves a couple of bytes during transfer of the files on the net, but makes them unreadable.

#define kUKXMLCreateDictionaryDefaultFlags	(kUKXMLNoXMLHeadTag)
#define kUKXMLCreateXMLDefaultFlags			(kUKXMLNoEmptyTags)