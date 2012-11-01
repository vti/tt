package ReportTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use File::Temp qw(:seekable);
use TT::Command::Report;

sub build_report : Test {
    my $self = shift;

    my $command = $self->_build_command(
        'start 2012-12-12 12:12:12',
        'finish 2012-12-12 12:12:13'
    );

    my $report = $command->run->get_output;

    is($report, <<'EOF');
Report
--------------------------------------------------
2012-12-12 12:12:12 - 2012-12-12 12:12:13 00:00:01
--------------------------------------------------
Total: 00:00:01
EOF
}

sub build_report_with_comments : Test {
    my $self = shift;

    my $command = $self->_build_command(
        'start 2012-12-12 12:12:12 hi there',
        'comment 2012-12-12 12:12:12 again and again and again and again and again and again and again',
        'finish 2012-12-12 12:12:13'
    );

    my $report = $command->run->get_output;

    is($report, <<'EOF');
Report
--------------------------------------------------
2012-12-12 12:12:12 - 2012-12-12 12:12:13 00:00:01
hi there
again and again and again and again and again and
again and again
--------------------------------------------------
Total: 00:00:01
EOF
}

sub build_report_with_overlapping_days : Test {
    my $self = shift;

    my $command = $self->_build_command(
        'start 2012-12-11 12:12:12',
        'finish 2012-12-12 12:12:13'
    );

    my $report = $command->run->get_output;

    is($report, <<'EOF');
Report
--------------------------------------------------
2012-12-11 12:12:12 - 2012-12-12 12:12:13 24:00:01
--------------------------------------------------
Total: 24:00:01
EOF
}

sub _build_command {
    my $self = shift;

    my $content = join "\n", @_;

    my $file = File::Temp->new;
    print $file $content;
    $self->{file} = $file;
    $file->seek( 0, SEEK_END );

    return TT::Command::Report->new(file => $file->filename);
}

1;