package Atlantis::Spawn;
use CamelBones qw(:All);
use Atlantis;

use vars qw(%StateData);

# Atlantis::Spawn->new($path)
#
# Where 'path' is the full path of the spawn.
#
sub new 
{
    my ($proto, $path)  = @_;
    my $class           = ref($proto) || $proto;
    my $self            = 
            {
                PATH    =>      $path
            };
    bless ($self, $class);
    return $self;    
}

# $spawn->outputStatus($text)
#
# Output the given text as status text.
#
sub outputStatus
{
    my $self = shift;
    my ($text) = @_;
    
    Atlantis::DisplayStatusOnSpawn($self->{PATH},$text,"");
}

# $spawn->focus()
#
# Focus the UI on the current spawn.
#
sub focus
{
    my $self = shift;
    $main::ScriptBridge->focusSpawn($self->{PATH});
}

# $spawn->selectedText()
#
# Returns a string representing whatever text is currently selected in the given spawn's 
# output window.
#
sub selectedText
{
    my $self = shift;
    $main::ScriptBridge->selectedStringInSpawn($self->{PATH});
}

# $spawn->getInputText()
#
# Returns the current contents of the spawn's input window.
#
sub getInputText
{
    my $self = shift;
    $main::ScriptBridge->getTextFromInputForSpawn($self->{PATH});
}

# $spawn->setInputText($text)
#
# Replaces the contents of the spawn's input window with the given string.
#
sub setInputText
{
    my $self = shift;
    my ($text) = @_;
    
    $main::ScriptBridge->setTextToInput_forSpawn($text,$self->{PATH},"");
}

# $spawn->setStatusbarText($text)
#
# Replaces the contents of the spawn's input window with the given string.
#
sub setStatusbarText
{
    my ($text) = @_;
    
    $main::ScriptBridge->setStatusBarText_forSpawn_inWorld($text,$self->{PATH},$Atlantis::StateData{'event.world'});
}

# $spawn->outputHTML($text)
#
# Outputs the given HTML string to the Spawn window.
#
sub outputHTML
{
    my $self = shift;
    my ($text) = @_;
    
    $main::ScriptBridge->appendHTML_toSpawn_inWorld($text,$self->{PATH},"");
}

# $spawn->output($text)
#
# Outputs the given AML string to the Spawn window.
#
sub output
{
    my $self = shift;
    my ($text) = @_;
    
    $main::ScriptBridge->appendAML_toSpawn_inWorld($text,$self->{PATH},"");
}

# $spawn->setPrefix($prefix)
#
# Sets the prefix of a given spawn to the given string
#
sub setPrefix
{
    my $self = shift;
    my ($prefix) = @_;
    
    $main::ScriptBridge->setPrefix_forSpawn_inSession($prefix,$self->{PATH},$Atlantis::StateData{'event.uuid'});
}
