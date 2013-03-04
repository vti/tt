package ReportTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;
use Test::MockObject::Extends;

use Time::Piece;
use File::Temp qw(:seekable);
use TT::Command::Report;

sub build_empty_report : Test {
    my $self = shift;

    my $command = $self->_build_command();

    my $report = $command->run->get_output;

    is($report, <<'EOF');
Report
----------------------------------------------------
                                    Total: 00:00:00
EOF
}

sub build_report : Test {
    my $self = shift;

    my $command = $self->_build_command(
        content => ['start 2012-12-12 12:12:12', 'finish 2012-12-12 12:12:13']);

    my $report = $command->run('all')->get_output;

    is($report, <<'EOF');
Report
----------------------------------------------------
2012-12-12 12:12:12 - 2012-12-12 12:12:13 [00:00:01]
----------------------------------------------------
                                    Total: 00:00:01
EOF
}

sub build_report_more_than_one_day : Test {
    my $self = shift;

    my $command = $self->_build_command(
        content => ['start 2012-12-12 12:12:12', 'finish 2012-12-14 12:12:13']);

    my $report = $command->run('all')->get_output;

    is($report, <<'EOF');
Report
----------------------------------------------------
2012-12-12 12:12:12 - 2012-12-14 12:12:13 [48:00:01]
----------------------------------------------------
                                    Total: 48:00:01
EOF
}

sub build_report_in_progress : Test {
    my $self = shift;

    my $command =
      $self->_build_command(content => ['start 2012-09-12 12:12:12']);
    $command->mock(
        _build_parser => sub {
            shift;
            my $parser = TT::Parser->new(@_);
            $parser = Test::MockObject::Extends->new($parser);
            $parser->mock(
                _current_time => sub {
                    Time::Piece->strptime('2012-09-12 12:12:13', '%Y-%m-%d %T')
                      ->epoch;
                }
            );
        }
    );

    my $report = $command->run('all')->get_output;

    is($report, <<'EOF');
Report
----------------------------------------------------
2012-09-12 12:12:12 - working...          [00:00:01]
----------------------------------------------------
                                    Total: 00:00:01
EOF
}

sub build_report_with_comments : Test {
    my $self = shift;

    my $command = $self->_build_command(
        content => [
'start 2012-12-12 12:12:12 again and again and again and again and again and again and again',
            'finish 2012-12-12 12:12:13'
        ]
    );

    my $report = $command->run('all')->get_output;

    is($report, <<'EOF');
Report
----------------------------------------------------
2012-12-12 12:12:12 - 2012-12-12 12:12:13 [00:00:01]
again and again and again and again and again and
again and again
----------------------------------------------------
                                    Total: 00:00:01
EOF
}

sub _build_command {
    my $self = shift;
    my (%params) = @_;

    my $content = join "\n", @{$params{content} || []};

    my $file = File::Temp->new;
    print $file $content;
    $self->{file} = $file;
    $file->seek(0, SEEK_END);

    my $command = TT::Command::Report->new(file => $file->filename);
    $command = Test::MockObject::Extends->new($command);
    return $command;
}

1;
