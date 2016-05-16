package Orders::Controller::Manage;
use Moose;
use namespace::autoclean;

use Data::Dumper;
use Orders::Util qw(parse_csv);
use Orders::DAL::OrdersDAO;
use Orders::DAL::UploadsDAO;


BEGIN { extends 'Catalyst::Controller'; }



=head1 NAME

Orders::Controller::Manage - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my %stash = ();
    # In lieu of implementing a real user system, I'm
    # simply going to store the username in the session that 
    # was used to "login" and display it 
    if (defined $c->request->parameters->{username}) {
	$c->session->{username} = $c->request->parameters->{username};
    }
    if (!defined $c->session->{username}) {
	$c->res->redirect( "/" );	
    }

    $stash{username} = $c->session->{username};
    
    if (defined $c->session->{error}) {
	$stash{error} = $c->session->{error};
	delete $c->session->{error};
    }

    #my $dbh = $c->model( 'DB' )->dbh;
    #print STDERR Dumper $c->model('DB');
    #print STDERR Dumper $dbh;
    #my $dao = Orders::DAL::OrdersDAO->new( dbh => $dbh );
    #my $orders = $dbh->selectall_arrayref( "SELECT * FROM orders  ", { Slice => {} } );
    #print STDERR Dumper $orders;

    $c->stash( %stash );
}


sub _price {
    my $d = shift;
    $d =~ s/[\$\.]//g;
    return $d;
}

sub upload : Local {
    my ( $self, $c) = @_;

    if (defined $c->request->parameters->{username}) {
	$c->session->{username} = $c->request->parameters->{username};
    }
    if (!defined $c->session->{username}) {
	$c->res->redirect( "/" );	
    }

    my $upload = $c->req->upload('csv');

    if (!defined $upload) {
	$c->session->{error} = "Please actually upload a file";
	$c->res->redirect("/manage");
	return;
    }

    my $dbh = $c->model( 'DB' )->dbh;

    # Check to see if we've already seen this file
    my $udao = Orders::DAL::UploadsDAO->new(dbh => $dbh);    
    my $result;
    eval {
	$result = $udao->add_filename( $upload->tempname );
    };
    if ($@) {
	$c->session->{error} = "There was an error uploading the CSV file: " . $@;
	$c->res->redirect("/manage");
	return;
    }

    if ($result == 0) {
	$c->session->{error} = "That file has already been uploaded.";
	$c->res->redirect("/manage");
	return;
    }

    my @data = ();
    eval {
	@data = Orders::Util::parse_csv($upload->tempname);
    };
    if ($@) {
	$c->session->{error} = "There was an error parsing the CSV file: " . $@;
	$c->res->redirect("/manage");
    } 

    #print STDERR Dumper \@data;
    #$c->log->debug(Dumper(\@data));

    # Put these into the DB
    my $dao = Orders::DAL::OrdersDAO->new(dbh => $dbh);

    eval {
	$dao->save_orders( \@data );
    };
    if ($@) {
	$c->session->{error} = "There was an error saving the order data: " . $@;
    }

    $c->res->redirect( "/manage" );
} 


=encoding utf8

=head1 AUTHOR

Ian Warford,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
