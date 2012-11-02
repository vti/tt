package ParserTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use File::Temp qw(:seekable);
use TT::Parser;

sub parse_empty : Test {
    my $self = shift;

    my $results = [];
    my $parser = $self->_build_parser(
        cb => sub {
            push @$results, @_;
        }
    );

    $parser->parse('');

    is_deeply($results, []);
}

sub parse : Test {
    my $self = shift;

    my $results = [];
    my $parser = $self->_build_parser(
        cb => sub {
            push @$results, @_;
        }
    );

    $parser->parse('start 2012-12-12 12:12:12');
    $parser->parse('finish 2012-12-12 12:12:13');

    is_deeply(
        $results,
        [   {   start   => '1355314332',
                finish  => '1355314333',
                elapsed => 1
            }
        ]
    );
}

sub parse_with_comment : Test {
    my $self = shift;

    my $results = [];
    my $parser = $self->_build_parser(
        cb => sub {
            push @$results, @_;
        }
    );

    $parser->parse('start 2012-12-12 12:12:12 hi');
    $parser->parse('finish 2012-12-12 12:12:13');

    is_deeply(
        $results,
        [   {   start   => '1355314332',
                finish  => '1355314333',
                comment => 'hi',
                elapsed => 1
            }
        ]
    );
}

sub parse_in_progress : Test {
    my $self = shift;

    my $results = [];
    my $parser = $self->_build_parser(
        cb => sub {
            push @$results, @_;
        }
    );

    $parser->parse('start 2012-09-12 12:12:12');
    $parser->parse;

    is_deeply(
        $results,
        [   {   start   => '1347451932',
                elapsed => time - 1347451932
            }
        ]
    );
}

sub _build_parser {
    my $self = shift;

    return TT::Parser->new(@_);
}

1;
