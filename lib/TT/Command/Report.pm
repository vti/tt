package TT::Command::Report;

use strict;
use warnings;

use base 'TT::Command::Base';

use Time::Piece;
use Text::Wrap ();
use TT::Parser;

sub run {
    my $self = shift;

    $self->output('Report');
    $self->output('-' x 52);

    my $total = 0;

    my $parser = TT::Parser->new(
        cb => sub {
            my $task = shift;

            $total += $task->{elapsed};

            my $elapsed    = gmtime($task->{elapsed})->strftime('%T');
            my $start_time = gmtime($task->{start})->strftime('%Y-%m-%d %T');

            my $finish_time =
              $task->{finish}
              ? gmtime($task->{finish})->strftime('%Y-%m-%d %T')
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

    $self->output((' ' x 36) . 'Total: ' . gmtime($total)->strftime('%T'));

    return $self;
}

1;
