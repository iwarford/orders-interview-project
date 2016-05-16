package Orders::Controller::Report;
use Moose;
use namespace::autoclean;

use Data::Dumper;



BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Orders::Controller::Report - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $dbh = $c->model( 'DB' )->dbh;
    #print STDERR Dumper $c->model('DB');

    # If the user doesn't have a username in the session, go back to login
    if (!defined $c->session->{username}) {
	$c->res->redirect( "/" );	
    }
    my $dao = Orders::DAL::OrdersDAO->new(dbh => $dbh);
    my $order_data = $dao->load_all_orders();

    $c->stash( order_data => $order_data );
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
