use strict;
use warnings;
use utf8;

use Test::More;

use_ok $_ for qw(
    Router::Assemble
    Router::Assemble::Assembler
    Router::Assemble::Builder
    Router::Assemble::Constant
    Router::Assemble::Matcher
    Router::Assemble::Util
);

done_testing;
