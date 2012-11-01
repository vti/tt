package TT::File;

use strict;
use warnings;

use File::ReadBackwards;
use Time::Piece;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    die 'File is required' unless $self->{file};

    return $self;
}

sub read_last_line {
    my $self = shift;

    my $bw = File::ReadBackwards->new($self->{file}) or die $!;
    return $bw->readline;
}

sub append {
    my $self = shift;
    my ($command, @argv) = @_;

    my $time = Time::Piece->new->strftime('%Y-%m-%d %T');

    open my $fh, '>>', $self->{file} or die $!;
    print $fh $command, ' ', $time, ' ', join(' ', @argv) . "\n";
    close $fh;
}

1;
