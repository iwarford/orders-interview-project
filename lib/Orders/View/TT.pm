package Orders::View::TT;
use strict;
use warnings;
use base 'Catalyst::View::TT';
    __PACKAGE__->config(
        # any TT configuration items go here
        ENCODING     => 'utf-8',
        # Not set by default
	EVAL_PERL          => 1,
    );
1;

