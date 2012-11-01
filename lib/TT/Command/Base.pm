package TT::Command::Base;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub output {
    my $self = shift;

    $self->{output} = '' unless defined $self->{output};
    $self->{output} .= join(' ', @_) . "\n";
}

sub get_output {
    my $self = shift;

    return $self->{output};
}

1;
