use strict;
use warnings;
use utf8;

use Test::More;
use Router::Assemble;

subtest 'regexp' => sub {
    my $r = Router::Assemble->new;
    $r->add('/index.html', 'index');
    my $m = $r->matcher;
    is ref($m->regexp), 'Regexp';
};

done_testing;
