package TT::Command::Finish;

use strict;
use warnings;

use base 'TT::Command::Base';

use TT::Mode;
use TT::File;

sub run {
    my $self = shift;

    die 'Not started' unless TT::Mode->new(file => $self->{file})->is_started;

    TT::File->new(file => $self->{file})->append('finish', @_);
}

1;
