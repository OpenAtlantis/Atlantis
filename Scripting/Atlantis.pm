# $Id: $
#
# ATLANTIS PERL BRIDGE MODULE
#
# Enables Perl modules loaded into Atlantis to communicate
# back with the main application.
#
######

package Atlantis;
use CamelBones qw(:All);

use vars qw(%StateData);

# SendTextToWorld($world,$text)
#
# Sends the given text to the named world, as if it were
# typed into the input window.
#
sub SendTextToWorld
{
    my ($world, $text) = @_;

    if ($world eq "") {
       $world = $Atlantis::StateData{'world.name'};
    }
    
    $main::ScriptBridge->sendText_toWorld($text,$world);
}

# DisplayStatusOnSpawn($spawn,$text)
#
# Displays the given text as a status message on the 
# named spawn.
#
sub DisplayStatusOnSpawn
{
    my ($spawn, $text) = @_;

    if ($spawn eq "") {
       $spawn = $Atlantis::StateData{'event.spawn'};
    }
    
    $main::ScriptBridge->sendStatus_toSpawn_inWorld($text,$spawn,$Atlantis::StateData{'world.name'});
}

# DisplayHTMLOnSpawn($spawn,$text)
#
# Adds the given HTML string to a spawn.
#
sub DisplayHTMLOnSpawn
{
    my ($spawn, $text) = @_;

    if ($spawn eq "") {
       $spawn = $Atlantis::StateData{'event.spawn'};
    }
    
    $main::ScriptBridge->appendHTML_toSpawn_inWorld($text,$spawn,$Atlantis::StateData{'world.name'});
}

# DisplayOnSpawn($spawn,$text)
#
# Adds the given AML string to a spawn.
#
sub DisplayOnSpawn
{
    my ($spawn, $text) = @_;

    if ($spawn eq "") {
       $spawn = $Atlantis::StateData{'event.spawn'};
    }
    
    $main::ScriptBridge->appendAML_toSpawn_inWorld($text,$spawn,$Atlantis::StateData{'world.name'});
}



# SetTempVariable($variable,$value)
#
# A legacy function which sets the global temporary variable 'temp.$variable' 
# to the given value.
#
sub SetTempVariable
{
    my ($variable, $value) = @_;

    $main::ScriptBridge->setVariable_forKey_inWorld("$value","temp." . $variable,"");
}

# GetPreference($world,$key)
#
# Returns the preference value for the given key (or an empty string) for the world
# given in $world.  This only works on connected worlds, and is intended as a shortcut
# for use with the 'world.name' variable in events.
#
sub GetPreference
{
    my ($world, $key) = @_;
    
    if ($world eq "") {
       $world = $Atlantis::StateData{'world.name'};
    }
    
    return $main::ScriptBridge->getPreference_inWorld($key, $world);
}

# SetPreference($world,$key,$preference)
#
# Sets the preference value for the given key for the world given in $world.  This only
# works on connected worlds, and is intended as a shortcut for use with the 'world.name' 
# variable in events.
#
sub SetPreference
{
    my ($world, $key, $preference) = @_;
    
    if ($world eq "") {
       $world = $Atlantis::StateData{'world.name'};
    }
    
    $main::ScriptBridge->setPreference_forKey_inWorld("$preference", $key, $world);
}

# SetVariable($world,$variable,$vale)
#
# A generic 'variable setting' option.  $world is intended as a connected world
# such as named in the world.name variable, while $variable will be 'temp.<something>' 
# or 'worldtemp.<something>' or 'userconf.<something>'; for temp variables, the $world 
# option is ignored, and if world is a blank string for worldtemp or userconf, the
# current world.name will be used.
#
sub SetVariable
{
    my ($world, $variable, $value) = @_;
    
    if ($world eq "") {
       $world = $Atlantis::StateData{'world.name'};
    }
    
    $main::ScriptBridge->setVariable_forKey_inWorld("$value",$variable,$world);
}

# GetCurrentInput()
#
# Returns the contents of the input window on the spawn associated with
# this particular event.
#
sub GetCurrentInput
{
    return $main::ScriptBridge->getTextFromInput();
}

# SetCurrentInput($text)
#
# Replaces the contents of the input window on the spawn associated with
# this particular event.
#
sub SetCurrentInput
{
    my ($text) = @_;
    
    $main::ScriptBridge->sendTextToInput($text);
}

# SetStatusbarText($spawn,$text)
#
# Sets the user-defined text field of a status field to the provided text,
# on the given spawn.
#
sub SetStatusbarText
{
    my ($spawn, $text) = @_;
    
    if ($spawn eq "") {
        $spawn = $Atlantis::StateData{'event.spawn'};
    }
    
    $main::ScriptBridge->setStatusBarText_forSpawn_inWorld($text,$spawn,$Atlantis::StateData{'event.world'});
}


# Growl($title,$text)
#
# Uses Growl to display the given text and title.
#
sub Growl
{
    my ($title, $text) = @_;
    
    $main::ScriptBridge->growlText_withTitle($text,$title);
}

# Speak($text)
# 
# Speaks the given text using system speech synthesis
#
sub Speak
{
    my ($text) = @_;
    
    $main::ScriptBridge->speakText($text);
}

# Beep()
#
# Beeps.  What, you expected a detailed description here?
#
sub Beep
{
    $main::ScriptBridge->systemBeep();
}

# PlaySound($filename)
#
# Plays a given MP3, AAC, OGG, WAV, SND, whatever file.  The filename
# should be a fully-qualified path.
#
sub PlaySound
{
    my ($filename) = @_;
    
    $main::ScriptBridge->playSoundFile($filename);
}

# FocusSpawn($spawn)
#
# Focuses the given spawn
#
sub FocusSpawn
{
    my ($spawn) = @_;
    
    $main::ScriptBridge->focusSpawn($spawn);
}

# UploadTextfile($world,$filename)
#
# Uploads a textfile to the given world, or the current-state world if the
# $world value is left empty.
#
sub UploadTextfile
{
    my ($world, $filename) = @_;
    
    if ($world eq "") {
        $world = Atlantis::StateData{'world.name'};
    }
    
    $main::ScriptBridge->uploadTextfile_toWorld($filename,$world);
}

# UploadCodefile($world,$filename)
#
# Uploads a textfile to the given world running the MUSHcode unformatted, or 
# to the current-state world if the $world value is left empty.
#
sub UploadCodefile
{
    my ($world, $filename) = @_;
    
    if ($world eq "") {
        $world = Atlantis::StateData{'world.name'};
    }
    
    $main::ScriptBridge->uploadCodefile_toWorld($filename,$world);
}

# SendAsInput($world,$text)
#
# Sends the given text to the world, first processing for any aliases.
# This acts as it would if the line of text were entered in the input window.
#
sub SendAsInput
{
    my ($world, $text) = @_;
    
    if ($world eq "") {
        $world = $Atlantis::StateData{'world.name'};
    }
    
    $main::ScriptBridge->sendAsInput_onWorld($text,$world);
}

# ReplaceEventLine($text)
#
# If the current event was triggered by an incoming line of text, this function
# will replace that text before it's displayed on whatever spawn it should be sorted to.
# The text should be provided in AML; you can get the existing line in AML as 
# event.script.lineAML from the Atlantis::StateData hash.
#
sub ReplaceEventLine
{
    my ($text) = @_;
    
    $main::ScriptBridge->replaceEventLine_inSession($text,$Atlantis::StateData{'event.uuid'});
}

# SetLineSpawn($spawn,$copy)
#
# Copy or move the current line to the given spawn within our current world.  If copy is
# 1, the line will be duplicated on that spawn.  Otherwise, the line will be moved there.
#
sub SetLineSpawn
{
    my ($spawn,$copy) = @_;
    
    $main::ScriptBridge->setLineSpawn_copy_inSession($spawn,$copy,$Atlantis::StateData{'event.uuid'});
}

# SetSpawnPrefix($spawn,$prefix)
#
# Copy or move the current line to the given spawn within our current world.  If copy is
# 1, the line will be duplicated on that spawn.  Otherwise, the line will be moved there.
#
sub SetSpawnPrefix
{
    my ($spawn,$prefix) = @_;
    
    $main::ScriptBridge->setPrefix_forSpawn_inSession($prefix,$spawn,$Atlantis::StateData{'event.uuid'});
}


# RegisterTrigger($cause,$function,$world)
#
# Registers a trigger.  The function should be a string to execute in Perl,
# the world is either a given world name (or an empty string for all worlds),
# and the cause is the value of an event.cause variable, such as 'line' or 
# 'statechange' or suchnot.
#
sub RegisterTrigger
{
    my ($cause, $function, $world) = @_;
    
    $main::ScriptBridge->registerFunction_forEventType_withLanguage_inWorld($function,$cause,"Perl",$world);
}

# RegisterPattern($pattern,$function,$world)
#
# Registers a line trigger.  The function should be a string to execute in Perl,
# the world is either a given world name (or an empty string for all worlds),
# and the pattern is a regexp to match a line variable.
#
sub RegisterPattern
{
    my ($pattern, $function, $world) = @_;
    
    $main::ScriptBridge->registerFunction_forLinePattern_withLanguage_inWorld($function,$pattern,"Perl",$world);
}



# RegisterAlias($name,$function,$world)
#
# Registers a trigger.  The function should be a string to execute in Perl,
# the world is either a given world name (or an empty string for all worlds),
# and the cause is the value of an event.cause variable, such as 'line' or 
# 'statechange' or suchnot.
#
sub RegisterAlias
{
    my ($name, $function, $world) = @_;
    
    $main::ScriptBridge->registerAlias_withName_withLanguage_inWorld($function,$name,"Perl",$world);
}


# RegisterHotkey($keycode,$modifier,$global,$function)
#
# Registers a hotkey callback.  The function should be a string to execute in Perl,
# the the value for global is either a '1' or a '0' for a global (outside of Atlantis) key or not,
# while the 'keycode' and 'modifiers' are Carbon keycode and modifier values.  Remember that if
# you register a hotkey as 'global,' then NO OTHER APPLICATION can use it, because it will make
# Atlantis always respond to it.
#
# Modifier values are any combination of:
#
#  Command key -  256   
#  Shift key   -  512
#  Option key  - 2048
#  Control key - 4096
#
# So, for instance, 768 (256 + 512) would be command+shift.  The keycode should be the numeric
# code of that key on the keyboard, which can be found with any number of Mac OS X applications,
# including Apple's software keyboard display.
#
sub RegisterHotkey
{
    my ($keycode, $modifiers, $global, $function) = @_;
    
    $main::ScriptBridge->registerHotkeyFunction_withKeyCode_modifiers_globally_withLanguage($function,$keycode,$modifiers,$global,"Perl");
}

# RegisterTimer($delay,$repeats,$function,$world)
#
# Registers a timer.  The function should be a string to execute in Perl,
# the world is either a given world name (or an empty string for all worlds),
# and the delay is how many seconds should be between executions.
#
# The 'repeats' value should be the number of times to repeat the timer.  -1 means
# to repeat forever, 0 will just not create a timer.  1 will execute once, 2 twice,
# and so on.
#
sub RegisterTimer
{
    my ($delay, $repeats, $function, $world) = @_;
    
    $main::ScriptBridge->registerTimer_withLanguage_inWorld_withInterval_repeats($function,"Perl",$world,$delay,$repeats);
}

1;
