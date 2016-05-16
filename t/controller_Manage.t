use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Orders';
use Orders::Controller::Manage;

ok( request('/manage')->is_success, 'Request should succeed' );
done_testing();
