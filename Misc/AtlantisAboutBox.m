//
//  AtlantisAboutBox.m
//  Atlantis
//
//  Created by Rachel Blackman on 5/26/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "AtlantisAboutBox.h"
#import <Lemuria/Lemuria.h>
#import <OgreKit/OgreKit.h>
#import <CamelBones/CamelBones.h>
#import "ScriptingDispatch.h"
#import "ScriptingEngine.h"
#import "RDAtlantisMainController.h"

@implementation AtlantisAboutBox

- (id) init
{
    self = [super init];
    if (self) {
        if ([NSBundle loadNibNamed:@"AboutBox" owner:self]) {
            NSString *version = [[NSBundle mainBundle] localizedStringForKey:@"CFBundleShortVersionString" value:@"" table:@"InfoPlist"];
            NSString *status = [[NSBundle mainBundle] localizedStringForKey:@"RDProjectStatus" value:@"" table:@"InfoPlist"];
            NSString *buildDate = [[NSBundle mainBundle] localizedStringForKey:@"RDProjectBuildDate" value:@"" table:@"InfoPlist"]; 
            NSString *releaseNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            
            NSString *build1 = [NSString stringWithFormat:@"%@ %@", version, status];
            NSString *build2 = [NSString stringWithFormat:@"Release %@ (%@)", releaseNum, buildDate];
            
            [_rdBuildInfo1 setStringValue:build1];
            [_rdBuildInfo2 setStringValue:build2];
            
            NSString *creditFile = [[NSBundle mainBundle] pathForResource:@"credits" ofType:@"rtf"];
            if (creditFile) {
                NSAttributedString *creditString =
                [[NSAttributedString alloc] initWithPath:creditFile documentAttributes:NULL];
                
                if (creditString) {
                    [[_rdCreditInfo textStorage] setAttributedString:creditString];
                    
                    [self addCreditProduct:@"Lemuria Windowing Toolkit" 
                                version:[[NSBundle bundleForClass:[RDNestedViewManager class]] localizedStringForKey:@"CFBundleShortVersionString" value:@"" table:@"InfoPlist"] 
                                copyright:@"2006-2007 Riverdark Studios"];

                    [self addCreditProduct:@"RBSplitView" version:@"1.1.4" copyright:@"2004-2006 Rainer Brockerhoff"];

                    [self addCreditProduct:@"PSMTabBarControl" 
                                version:@"1.3"
                                copyright:@"2006 John Pannell / Positive Spin Media"];

                    [self addCreditProduct:@"OgreKit"
                                version:[OGRegularExpression version]
                                copyright:@"2004-2006 Isao Sonobe, All rights reserved"];

                    [self addCreditProduct:@"Onuguruma"
                                version:[OGRegularExpression onigurumaVersion]
                                copyright:@"2002-2006 K.Kosako"];
                    
                    [self addCreditProduct:@"DTCVersionChecker" version:@"2.0" copyright:@"Daniel Todd Currie"];
                    
                    [self addCreditProduct:@"CamelBones" 
                                version:@"1.0.3"
                                copyright:@"2005-2007 Sherm Pendley"];

                    [self addCreditProduct:@"LuaCore" 
                                version:@"0.2"
                                copyright:@"2006 Flying Meat Inc."];
                                
                    ScriptingDispatch *scriptSystem = [[RDAtlantisMainController controller] scriptDispatch];
                    NSArray *languages = [scriptSystem languages];
                    
                    NSEnumerator *langEnum = [languages objectEnumerator];
                    NSString *langWalk;
                    
                    while (langWalk = [langEnum nextObject]) {
                        ScriptingEngine *engine = [scriptSystem engineForLanguage:langWalk];
                        if (engine)
                            [self addCreditProduct:langWalk
                                       version:[engine scriptEngineVersion]
                                       copyright:[engine scriptEngineCopyright]];
                    }
                }
            }
        }
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void) addCreditProduct:(NSString *)prodName version:(NSString *)version copyright:(NSString *)copyright;
{
    NSFont *creditFont = [NSFont fontWithName:@"Helvetica-Bold" size:12];
    
    NSAttributedString *creditString = 
        [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ %@ %@\n",prodName, version, [NSString stringWithUTF8String:"\xC2\xA9"], copyright] 
                        attributes:[NSDictionary dictionaryWithObject:creditFont forKey:NSFontAttributeName]];
    
    [[_rdCreditInfo textStorage] appendAttributedString:creditString];
}

- (void) display
{
    [_rdAboutBox center];
    [_rdAboutBox makeKeyAndOrderFront:self];
}

@end
