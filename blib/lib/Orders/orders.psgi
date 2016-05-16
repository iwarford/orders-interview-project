use strict;
use warnings;

use Orders;

my $app = Orders->apply_default_middlewares(Orders->psgi_app);
$app;

