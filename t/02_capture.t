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
{
    eval {
        my $r = Router::Assemble->new();
        $r->add('/(a)/index.html', '(a)');
    };
    ok !$@;
}
{
    eval {
        my $r = Router::Assemble->new(
            quotemeta_static_path => 0,
        );
        $r->add('/(a)/index.html', '(a)');
    };
    like $@, qr/paren/;
}
{
    eval {
        my $r = Router::Assemble->new(
            quotemeta_static_path => 0,
        );
        $r->add('/(?:a)/index.html', '(a)');
    };
    ok !$@;
}

done_testing;
