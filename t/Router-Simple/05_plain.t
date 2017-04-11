use strict;
use warnings;
use Router::Assemble;
use Test::More;

my $r = Router::Assemble->new();
$r->add('/' => {controller => 'Root', action => 'show'});
$r->add('/p' => {controller => 'Root', action => 'p'});

is_deeply(
    [$r->match( '/' )],
    [
        {
            controller => 'Root',
            action     => 'show',
        }, {}
    ]
);

is_deeply(
    [ $r->match( '/p' ) ],
    [
        {
            controller => 'Root',
            action     => 'p',
        }, {}
    ]
);

done_testing;

