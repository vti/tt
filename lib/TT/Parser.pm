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
            $self->{result}->{elapsed} = $self->_current_time - $self->{result}->{start};
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
            start => Time::Piece->strptime("$date $time", '%Y-%m-%d %T')->epoch,
            defined($comment) ? (comment => $comment) : ()
        };
    }
    elsif ($command eq 'finish') {
        my $result = $self->{result};

        if ($self->{filter} && $self->{filter} eq 'today') {
            my $today = gmtime($self->_current_time)->strftime('%Y-%m-%d');

            delete $self->{result};
            return unless $today eq $date;
        }

        if ($self->{filter} && $self->{filter} =~ /^(\d\d?)$/) {
            my $month = sprintf('%02d', $1);
            my $month_date = $date;
            $month_date =~ s{^(\d\d\d\d)-.*}{$1-$month};

            if ($date !~ m/^$month_date/) {
                delete $self->{result};
                return;
            }
        }

        $result->{finish} =
          Time::Piece->strptime("$date $time", '%Y-%m-%d %T')->epoch;

        $result->{elapsed} = $result->{finish} - $result->{start};

        $self->{cb}->($result);

        delete $self->{result};
    }

    return $self;
}

sub _current_time {
    my $self = shift;

    return time;
}

1;
