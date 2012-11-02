package TT;

use strict;
use warnings;

use TT::File;
use TT::Mode;
use File::Spec;
use File::HomeDir;

our $VERSION = '0.01';

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    my $home = File::HomeDir->my_home;

    my $tt_dir = File::Spec->catfile($home, '.tt');
    mkdir $tt_dir;

    $self->{file} = File::Spec->catfile($tt_dir, 'tasks');
    if (!-r $self->{file}) {
        open my $fh, '>', $self->{file};
        close $fh;
    }

    return $self;
}

sub run {
    my $self = shift;
    my ($command, @argv) = @_;

    if (!$command) {
        print "Usage: tt <command> <arguments>\n";
        print "    start <comment>\n";
        print "    comment <comment>\n";
        print "    finish\n";
        print "    report\n";
        return;
    }

    my $command_class = 'TT::Command::' . ucfirst($command);
    my $command_path  = $command_class;
    $command_path =~ s{::}{/}g;
    eval { require "$command_path.pm"; 1 } or do {
        die "Unknown command '$command'\n";
    };

    $command = $command_class->new(file => $self->{file});
    $command->run(@argv);

    if (defined(my $output = $command->get_output)) {
        print $output;
    }
}

1;
