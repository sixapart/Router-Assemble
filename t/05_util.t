use strict;
use warnings;
use utf8;

use Test::More;
use Router::Assemble::Util;

subtest 'normalize_path_component' => sub {
    is normalize_path_component('a'),   'a';
    is normalize_path_component(':a'),  '{a:[^/]+}';
    is normalize_path_component('{a}'), '{a:[^/]+}';
};

subtest 'split_path' => sub {
    is_deeply [split_path('/path/{to}/(?:deep)/{dir:\w+}/:basename/index.html')], [qw(
        /path/
        {to}
        /(?:deep)/
        {dir:\w+}
        /
        :basename
        /index.html
    )];
};

subtest 'is_placeholder' => sub {
    ok is_placeholder('{a:[^/]+}');
    ok !is_placeholder(':a');
    ok !is_placeholder('a');
};

subtest 'split_placeholder' => sub {
    is_deeply [split_placeholder('{a:[^/]+}')], [qw(a [^/]+)];
};

done_testing;
