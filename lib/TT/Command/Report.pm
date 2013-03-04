package TT::Command::Report;

use strict;
use warnings;

use base 'TT::Command::Base';

use Time::Piece;
use Text::Wrap ();
use TT::Parser;

sub run {
    my $self = shift;
    my ($filter) = @_;

    $self->output('Report');
    $self->output('-' x 52);

    my $total = 0;

    $filter ||= 'today';

    my $parser = $self->_build_parser(
        filter => $filter || 'today',
        cb => sub {
            my $task = shift;

            $task->{elapsed} ||= $self->_current_time - $task->{start};

            $total += $task->{elapsed};

            my $elapsed = $self->_format_to_hours($task->{elapsed});
            my $start_time = $self->_time($task->{start})->strftime('%Y-%m-%d %T');

            my $finish_time =
              $task->{finish}
              ? $self->_time($task->{finish})->strftime('%Y-%m-%d %T')
              : ('working...' . (' ' x 9));

            $self->output("$start_time - $finish_time [$elapsed]");

            if (my $comment = $task->{comment}) {
                $Text::Wrap::columns = 52;
                $comment = Text::Wrap::wrap('', '', $comment);
                $self->output($comment);
            }

            $self->output('-' x 52);
        }
    );

    open my $fh, '<', $self->{file} or die $!;
    while (defined(my $line = <$fh>)) {
        chomp $line;

        $parser->parse($line);

    }
    close $fh;

    $parser->parse;

    $self->output((' ' x 36) . 'Total: ' . $self->_format_to_hours($total));

    return $self;
}

sub _format_to_hours {
    my $self = shift;
    my ($time) = @_;

    my $formatted    = $self->_time($time)->strftime('%T');
    if ($time > 3600 * 24) {
        my $days = int($time / (24 * 3600));
        $formatted =~ s{^(\d\d)}{$1 + $days * 24}e;
    }

    return $formatted;
}

sub _build_parser {
    my $self = shift;

    return TT::Parser->new(@_);
}

sub _current_time {
    my $self = shift;

    return time;
}

sub _time {
    my $self = shift;
    my ($epoch) = @_;

    return gmtime($epoch);
}

1;
