#!/usr/bin/env perl

use 5.008007;

use strict;
use warnings;

use ExtUtils::MakeMaker;

my ($mm) = $ExtUtils::MakeMaker::VERSION =~ /^([^_]+)/;

WriteMakefile(
    NAME         => 'TT',
    VERSION_FROM => 'lib/TT.pm',
    ABSTRACT     => 'TT',
    AUTHOR       => 'Viacheslav Tykhanovskyi <vti@cpan.org>',

    ($mm < 6.3002 ? () : ('LICENSE' => 'artistic_2')),

    (   $mm < 6.46
        ? ()
        : ( META_MERGE => {
                requires  => {perl => '5.008007'},
                resources => {
                    license    => 'http://dev.perl.org/licenses/',
                    repository => 'http://github.com/vti/tt'
                },
                no_index => {directory => [qw/t/]}
            },
            META_ADD => {
                build_requires     => {},
                configure_requires => {}
            },
        )
    ),
    EXE_FILES => ['bin/tt'],

    PREREQ_PM => {
        'File::Spec'  => '0',
        'Text::Wrap'  => '0',
        'Time::Piece' => '0',

        'File::HomeDir'       => '0',
        'File::ReadBackwards' => '0',

        'Test::Class' => '0',
        'Test::Fatal' => '0'
    },
    test => {TESTS => 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t'}
);
