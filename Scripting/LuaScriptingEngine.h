//
//  LuaScriptingEngine.h
//  Atlantis
//
//  Created by Rachel Blackman on 9/30/07.
//  Copyright 2007 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <LuaCore/LuaCore.h>
#import "ScriptingEngine.h"
#import "ScriptBridge.h"

@interface LuaScriptingEngine : ScriptingEngine {

    LCLua                   *_rdLuaInterpreter;
    NSDate                  *_rdNewestModificationDate;

    ScriptBridge            *_rdBridge;
    
    NSLock                  *_rdLuaLock;

}

@end
