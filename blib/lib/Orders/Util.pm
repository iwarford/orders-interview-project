package Orders::Util;


use strict;
use warnings;
use Exporter;
use Text::CSV;
use Data::Dumper;

use vars qw(@EXPORT_OK);

@EXPORT_OK = qw(parse_csv);

# Pass an array of CSV lines into 
sub parse_csv {
    my $filename = shift;
    my $row;

    # Could use more error checking for cases of running under a real web server
    # The Catalyst uploader should put it into /tmp by default, but you never know
    open(my $fh, "<", $filename) || die "Unable to open $filename, $!\n";

    my @rows;
    my $csv = Text::CSV->new( { binary => 1 } );
    $row = $csv->getline($fh); # Skip the headers
    $csv->column_names(@$row);
    my $results = $csv->getline_all($fh);

    print STDERR Dumper($results);
    return @$results;
}

1;
