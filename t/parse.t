#!/usr/bin/env perl

#use common::sense;
use Test::More;
use Pod::Usage();
use Getopt::Long();
use File::Spec::Functions;
use File::Find;

=head1 NAME

This is the harness for testing that the parser does not fail on all given org
files

=head1 SYNOPSIS

Run all tests

    prove -l t/parse.t

To run on an individual test case, use the following:

    prove -l t/parse.t :: t/<testcase>.org

=cut

my %options;

Getopt::Long::GetOptions(\%options, qw(
    help!
));

Pod::Usage::pod2usage( -output => \*STDERR,
                       -exitval => 0 ) if $options{help};

my $org_dir = catdir(Cwd::cwd, qw( t ));
my $parser = catfile(Cwd::cwd, qw( org-parse ));

sub runtest {
    my $test_case = $File::Find::fullname // $File::Find::name;
    unless ($test_case =~ m/.*\.org$/) {
        return;
    }

    my @args = ($parser, $test_case);
    my $output;
    system(@args);
    if ($? == -1) {
        print "failed to execute: $!\n";
    }
    elsif ($? & 127) {
        printf "child died with signal %d, %s coredump\n",
        ($? & 127),  ($? & 128) ? 'with' : 'without';
    }
    else {
        $output = $? >> 8;
        #printf "child exited with value %d\n", $? >> 8;
    }
    ok $output == 0, $test_case . " failed: $output";
}

find( {
    wanted      => \&runtest,
    no_chdir    => 1,
    follow_fast => 1,
}, $org_dir);

done_testing;
