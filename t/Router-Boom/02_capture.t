use strict;
use warnings;
use utf8;

use Test::More;
use Router::Assemble;

{
    eval {
        my $r = Router::Assemble->new();
        $r->add('/{foo:(.)}');
    };
    like $@, qr/paren/;
}
{
    eval {
        my $r = Router::Assemble->new();
        $r->add('/{foo:(?:.)}');
    };
    ok !$@;
}

done_testing;
