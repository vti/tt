package TT::Parser;

use strict;
use warnings;

use Time::Piece;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    $self->{cb} ||= sub { };

    return $self;
}

sub parse {
    my $self = shift;

    if (@_ == 0) {
        if ($self->{result}) {
            $self->{result}->{elapsed} = time - $self->{result}->{start};
            $self->{cb}->($self->{result});
        }

        return $self;
    }

    my ($line) = @_;

    my ($command, $date, $time, $comment) = $line
      =~ m/^([\S]+)\s*(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2})(?:\s+(.*))?$/;
    return unless $command;

    if ($command eq 'start') {
        $self->{result} = {
            start => gmtime->strptime("$date $time", '%Y-%m-%d %T')->epoch,
            defined($comment) ? (comment => $comment) : ()
        };
    }
    elsif ($command eq 'finish') {
        my $result = $self->{result};

        $result->{finish} =
          gmtime->strptime("$date $time", '%Y-%m-%d %T')->epoch;

        $result->{elapsed} = $result->{finish} - $result->{start};

        $self->{cb}->($result);

        delete $self->{result};
    }

    return $self;
}

1;
