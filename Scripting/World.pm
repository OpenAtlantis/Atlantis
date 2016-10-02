package Atlantis::World;
use CamelBones qw(:All);

use vars qw(%StateData);

# Atlantis::World->new($name)
#
# Where 'name' is the name of the world in the address book, such as 'OGR' or 'Firan' or whatnot.
#
sub new 
{
    my ($proto, $name)  = @_;
    my $class           = ref($proto) || $proto;
    my $uuid            = $main::ScriptBridge->worldUuidForName($name);
    my $self            = 
            {
                UUID    =>      $uuid
            };
    bless ($self, $class);
    return $self;    
}

# $world->characters()
#
# Returns an array of the characters defined for the world.
#
sub characters
{
    my $self = shift;
    return $main::ScriptBridge->charactersForWorld($self->{"UUID"});
}

# $world->connected($character)
#
# Returns whether a given character is connected or not.
#
sub connected
{
    my $self = shift;
    my ($character) = @_;
    return $main::ScriptBridge->isWorldConnected_forCharacter($self->{"UUID"},$character);
}

# $world->connectCharacter($character)
#
# Connects a given character.
#
sub connectCharacter
{
    my $self = shift;
    my ($character) = @_;
    $main::ScriptBridge->connectWorld_forCharacter($self->{"UUID"},$character);
}

# $world->disconnectCharacter($character)
#
# Disconnects a given character.
#
sub disconnectCharacter
{
    my $self = shift;
    my ($character) = @_;
    $main::ScriptBridge->disconnectWorld_forCharacter($self->{"UUID"},$character);
}

# $world->getPreference($character,$preference)
#
# Retrieves a given preference setting in a world.  If $character is an empty string,
# reads from the world parent.
#
sub getPreference
{
    my $self = shift;
    my ($character, $preference) = @_;
    $main::ScriptBridge->getPreference_inWorldUUID_withCharacter($preference,$self->{"UUID"},$character);
}

# $world->setPreference($character,$preference,$value)
#
# Sets a given preference setting in a world.  If $character is an empty string,
# sets in the world parent.
#
sub setPreference
{
    my $self = shift;
    my ($character, $preference, $value) = @_;
    $main::ScriptBridge->setPreference_forKey_inWorldUUID_withCharacter($value,$preference,$self->{"UUID"},$character);
}

# $world->removePreference($character,$preference)
#
# Removes a given preference setting in a world entirely.  If $character is an empty string,
# removes from the world parent.
#
sub removePreference
{
    my $self = shift;
    my ($character, $preference) = @_;
    $main::ScriptBridge->removePreference_inWorldUUID_withCharacter($preference,$self->{"UUID"},$character);
}


1;
