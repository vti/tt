package TT::Mode;

use strict;
use warnings;

use TT::File;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

sub is_started {
    my $self = shift;

    my $last_command = $self->_read_last_command;

    if (!$last_command || $last_command eq 'finish') {
        return 0;
    }

    return 1;
}

sub _read_last_command {
    my $self = shift;

    my $file = TT::File->new(file => $self->{file});
    my $last_line = $file->read_last_line;

    my ($last_command) = $last_line =~ m/^([\S]+)/;

    return $last_command;
}

1;
