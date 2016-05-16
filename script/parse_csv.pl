#!/usr/bin/perl

use warnings;
use strict;

use Data::Dumper;
use Getopt::Std;
use vars qw(%opts);
use Text::CSV;

sub usage {
    print STDERR "parse_csv.pl -f file\n";
}

getopts('f:', \%opts);
usage() unless $opts{f};

open(my $fh, "<", $opts{f}) || die "Unable to open $opts{f}, $!\n";

my $row;

my $csv = Text::CSV->new( { binary => 1 } );


while (my $row = $csv->getline($fh) ) {
    print Dumper $row;
}
