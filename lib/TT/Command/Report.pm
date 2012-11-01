package TT::Command::Report;

use strict;
use warnings;

use base 'TT::Command::Base';

use Time::Piece;
use Text::Wrap ();

sub run {
    my $self = shift;

    $self->output('Report');
    $self->output('-' x 50);

    my $total;
    my $start;
    my @comments;

    open my $fh, '<', $self->{file} or die $!;
    while (defined(my $line = <$fh>)) {
        chomp $line;

        my ($command, $time, $comment) = $line
          =~ m/^([\S]+)\s*(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})(?:\s*(.*))?$/;

        next unless $command;

        if ($command eq 'start') {
            $start = $time;
            push @comments, $comment if $comment;
        }
        elsif ($command eq 'finish') {
            my $diff =
                Time::Piece->new->strptime($time,  '%Y-%m-%d %T')
              - Time::Piece->new->strptime($start, '%Y-%m-%d %T');

            $total += $diff;

            my $elapsed = $self->_epoch_to_time($diff);

            $self->output("$start - $time $elapsed");

            if (@comments) {
                my $comments = join "\n", @comments;

                $Text::Wrap::columns = 50;
                $comments = Text::Wrap::wrap('', '', $comments);
                $self->output($comments);

                @comments = ();
            }

        }
        elsif ($command eq 'comment') {
            push @comments, join ' ', $comment if $comment;
        }
    }
    close $fh;

    $self->output('-' x 50);
    $self->output('Total: ' . $self->_epoch_to_time($total));

    return $self;
}

sub _epoch_to_time {
    my $self = shift;
    my ($time) = @_;

    my $hours   = sprintf('%02d', int($time / 3600));
    my $minutes = sprintf('%02d', int(($time - $hours * 3600) / 60));
    my $seconds = sprintf('%02d', $time - $hours * 3600 - $minutes * 60);

    return "$hours:$minutes:$seconds";
}

1;
