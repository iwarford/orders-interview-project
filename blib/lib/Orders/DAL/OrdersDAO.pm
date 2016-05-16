package Orders::DAL::OrdersDAO;
use Moose;
use namespace::autoclean;

use Data::Dumper;

has dbh => (
    is => 'rw',
    isa => 'DBI::db',
    required => 1,
    );


sub load_all_orders {
    my ($self) = @_;
    my $dbh = $self->dbh;
    my $order_sth = $dbh->prepare( "SELECT * FROM orders JOIN customers USING (customer_id) ORDER BY order_id, last_name, order_date");
    $order_sth->execute();
    my %days = ();
    while (my $row = $order_sth->fetchrow_hashref()) {
	my $order_date = $row->{order_date};
	my ($day, $time) = split(" ", $order_date);
	
	if (!exists $days{$day}) {
	    $days{$day} = {};
	}
	if (!exists $days{$day}->{$row->{customer_code}}) {
	    $days{$day}->{$row->{customer_code}} = {};
	}
	if (!exists $days{$day}->{$row->{customer_code}}->{$row->{order_number}}) {
	    $days{$day}->{$row->{customer_code}}->{$row->{order_number}} = [];
	}
	push @{$days{$day}->{$row->{customer_code}}->{$row->{order_number}}}, $row;


    }
#    print STDERR Dumper \%days;
    return \%days;
}

sub save_orders {
    my ($self, $data) = @_;

    my $dbh = $self->dbh;

    # Check to see if there are duplicate order_numbers --
    # the best solution is to simply skip them, rather than
    # replace them -- that way re-uploads of the same file 
    # don't do anything
    # (a later enhancement would be to enable per-record modification or deletion)
    # my $check_sth  = $dbh->prepare("SELECT order_number FROM orders WHERE order_number = ?");
    my @duplicates = ();

    # SQL for insertion
    my $insert_sql = <<'END_SQL';
INSERT INTO orders 
    (order_date, customer_id, order_number, item_name, 
     item_manufacturer,  item_price_cents) 
VALUES (?,?,?,?,?,?)
END_SQL
    my $insert_sth = $dbh->prepare($insert_sql);

    # Prepare for managing customers
    my $customer_sql = "SELECT customer_id FROM customers WHERE customer_code = ?";
    my $customer_insert_sql = "INSERT INTO customers (customer_code, first_name, last_name) VALUES (?,?,?)";
    my $customer_insert_sth = $dbh->prepare($customer_insert_sql);
    
    # keep track of the duplicates to let the user know the list of order
    # numbers that were skipped
    for my $row (@$data) {
	my $customer_id;

	# Check if this customer_id already exists
	my $check_customer = $dbh->selectall_arrayref($customer_sql, undef, $row->[1]);
#	print STDERR Dumper $check_customer;

	if (scalar @{$check_customer}) {
	    $customer_id = $check_customer->[0]->[0];
	} else {
	    $customer_insert_sth->execute( @{$row}[1,2,3] );
	    $check_customer = $dbh->selectall_arrayref($customer_sql, undef, $row->[1]);
	    $customer_id = $check_customer->[0]->[0];
	}
	$insert_sth->execute($row->[0], $customer_id, @{$row}[4,5,6], $row->[7] =~ s/[\$\.]//gr );
    }
}

1;
