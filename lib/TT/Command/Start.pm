package TT::Command::Start;

use strict;
use warnings;

use base 'TT::Command::Base';

use TT::Mode;

sub run {
    my $self = shift;

    die 'Not finished' if TT::Mode->new(file => $self->{file})->is_started;

    TT::File->new(file => $self->{file})->append('start', @_);
}

1;
