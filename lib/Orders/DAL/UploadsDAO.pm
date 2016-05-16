package Orders::DAL::UploadsDAO;
use Moose;
use namespace::autoclean;

use Data::Dumper;

use Digest::MD5::File qw(file_md5_hex);

has dbh => (
    is => 'rw',
    isa => 'DBI::db',
    required => 1,
    );


# Takes the temp filename from the upload,
# generates an MD5sum of it, and inserts
# it into the DB if it's not already there

# Returns the number of rows inserted, so 
# 0 means that it has already seen it, so to
# reject it
sub add_filename {

    my ($self, $filename) = @_;
    my $dbh = $self->dbh;

    my $digest = file_md5_hex($filename);

    my $results = $dbh->selectall_arrayref("SELECT * FROM upload_log WHERE md5sum = ?", 
                                           { Slice => {} }, $digest);

    if (scalar @{$results}) {
	return 0;
    } 

    return $dbh->do("INSERT INTO upload_log (md5sum) VALUES (?)", {}, $digest);
}


1;
