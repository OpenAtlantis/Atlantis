Atlantis = {};

-- =====================================================
-- Displays the string on the given spawn as a status line.
-- If the spawn is an empty string, then the current spawn
-- is used.
-- 
function Atlantis:displayStatus(spawn,string)
    if spawn == "" then
        spawn = AtlantisState["event.spawn"];
    end

    ScriptBridge:sendStatus_toSpawn_inWorld(string,spawn,AtlantisState["event.world"]);
end

-- =====================================================
-- Displays the string on the given spawn as a normal line.
-- If the spawn is an empty string, then the current spawn
-- is used.
-- 
function Atlantis:displayText(spawn,string)
    if spawn == "" then
        spawn = AtlantisState["event.spawn"];
    end

    ScriptBridge:appendAML_toSpawn_inWorld(string,spawn,AtlantisState["event.world"]);
end


-- =====================================================
-- Sends the string to the world given.  If the world
-- name is an empty string, the current world is used.
-- 
function Atlantis:sendText(world,string)
    if world == "" then
        world = AtlantisState["event.world"];
    end
    
    ScriptBridge:sendText_toWorld(string,world);
end

-- =====================================================
-- Sends the string to the world given as if the user had
-- entered it.  (Handles aliases and such.)  If the world
-- name is an empty string, the current world is used.
-- 
function Atlantis:sendInput(world,string)
    if world == "" then
        world = AtlantisState["event.world"];
    end
    
    ScriptBridge:sendAsInput_onWorld(string,world);
end


-- =====================================================
-- Makes Atlantis focus on a specific spawn.
-- If no spawn is given, uses the current event spawn.
-- 
function Atlantis:focusSpawn(spawn)
    if spawn == "" then
        spawn = AtlantisState["event.spawn"];
    end

    return ScriptBridge:focusSpawn(spawn);
end


-- =====================================================
-- Retrieves the current contents of the input area on a spawn.
-- If no spawn is given, uses the current spawn.
-- 
function Atlantis:getInputText(spawn)
    if spawn == "" then
        spawn = AtlantisState["event.spawn"];
    end

    return ScriptBridge:getTextFromInputForSpawn(spawn);
end

-- =====================================================
-- Sets the current contents of the input area on a spawn.
-- If no spawn is given, uses the current spawn.
-- 
function Atlantis:setInputText(spawn, string)
    if spawn == "" then
        spawn = AtlantisState["event.spawn"];
    end

    return ScriptBridge:setTextToInput_forSpawn(string,spawn);
end


-- =====================================================
-- Retrieves the current selected text (if any) on a spawn.
-- If no spawn is given, uses the current spawn.
-- 
function Atlantis:getSelectedText(spawn)
    if spawn == "" then
        spawn = AtlantisState["event.spawn"];
    end

    return ScriptBridge:selectedStringInSpawn(spawn);
end

-- =====================================================
-- Sets the current contents of the status bar on a spawn.
-- If no spawn is given, uses the current spawn.
-- 
function Atlantis:setStatusText(spawn, string)
    if spawn == "" then
        spawn = AtlantisState["event.spawn"];
    end

    ScriptBridge:setStatusBarText_forSpawn_inWorld(string,spawn,AtlantisState["event.world"]);
end


-- =====================================================
-- Sets a given variable in the temp, worldtemp or userconf
-- heirarchies.  If no world is given, the current world is
-- used.
-- 
function Atlantis:setVariable(world,variable,value)
    if world == "" then
        world = AtlantisState["event.world"];
    end

    ScriptBridge:setVariable_forKey_inWorld(value,variable,world);
end



-- =====================================================
-- Replaces the line the current state is functioning on
-- with the new line instead.  Events and highlights in
-- the event system will fire on this new line instead of
-- the original.
-- 
function Atlantis:replaceLine(newline)
    ScriptBridge:replaceEventLine_inSession(newline,AtlantisState["event.uuid"]);
end


-- =====================================================
-- Sets the spawn for this line to be output to.  If 
-- 'copy' is set to true, then normal spawn patterns will
-- also apply.  If 'copy' is false, the line will end up
-- only on those spawns you have manually set.
-- 
function Atlantis:setLineSpawn(spawn,copy)
    ScriptBridge:setLineSpawn_copy_inSession(spawn,copy,AtlantisState["event.uuid"]);
end

-- =====================================================
-- Sets the prefix for a given spawn. 
-- 
function Atlantis:setSpawnPrefix(spawn,prefix)
    ScriptBridge:setPrefix_forSpawn_in_session(prefix,spawn,AtlantisState["event.uuid"]);
end



-- =====================================================
-- Sends the string to Growl to be displayed as a notification,
-- if Growl is installed.
-- 
function Atlantis:growlText(title,string)
    ScriptBridge:growlText_withTitle(string,title);
end

-- =====================================================
-- Speaks the text aloud in the default system speech voice.
-- 
function Atlantis:speakText(string)
    ScriptBridge:speakText(string);
end

-- =====================================================
-- Does the system 'beep' behavior.
-- 
function Atlantis:beep(string)
    ScriptBridge:beep();
end

-- =====================================================
-- Plays a sound file at the given full path.
-- 
function Atlantis:playSound(filename)
    ScriptBridge:playSoundFile(filename);
end


-- =====================================================
-- Registers a handler for the given type.  The function
-- is a string of Lua code to be executed in such situations.
-- 
function Atlantis:registerFunction(world,event,triggerData)
    ScriptBridge:registerFunction_forEventType_withLanguage_inWorld(triggerData,event,"Lua",world);
end

-- =====================================================
-- Registers a handler for the given line pattern.  The function
-- is a string of Lua code to be executed in such situations.
-- The pattern should be a regexp the line must match.
-- 
function Atlantis:registerPattern(world,pattern,triggerData)
    ScriptBridge:registerFunction_forLinePattern_withLanguage_inWorld(triggerData,pattern,"Lua",world);
end


-- =====================================================
-- Registers an alias.  The function is a string of Lua
-- code to be executed when the alias is run.
-- 
function Atlantis:registerAlias(world,alias,triggerData)
    ScriptBridge:registerAlias_withName_withLanguage_inWorld(triggerData,alias,"Lua",world);
end

-- =====================================================
-- Registers an alias.  The function is a string of Lua
-- code to be executed when the alias is run.
-- 
function Atlantis:registerTimer(world,interval,repeats,triggerData)
    ScriptBridge:registerTimer_withLanguage_inWorld_withInterval_repeats(triggerData,"Lua",world,"" .. interval, "" .. repeats);
end

-- =====================================================
-- Registers a hotkey.  The function is a string of Lua
-- code to be executed when the hotkey is pressed.
-- 
function Atlantis:registerHotkey(keycode,modifiers,global,triggerData)
    ScriptBridge:registerHotkeyFunction_withKeyCode_modifiers_globally_withLanguage(triggerData,"" .. keycode, "" .. modifiers, "" .. global, "Lua");
end
