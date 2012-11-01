package TT::Command::Comment;

use strict;
use warnings;

use base 'TT::Command::Base';

use TT::File;
use TT::Mode;

sub run {
    my $self = shift;

    die 'Not started' unless TT::Mode->new(file => $self->{file})->is_started;

    my $comment = join ' ', @_;

    my $file = TT::File->new(file => $self->{file});
    $file->append('comment', $comment);
}

1;
