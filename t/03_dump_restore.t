use strict;
use warnings;
use utf8;

use Test::More;
use Router::Assemble;
use Router::Assemble::Matcher;

my $r = Router::Assemble->new;
$r->add('/index.html', 'index');
$r->add('/styles.css', 'styles');
$r->add('/news.html', 'news');
$r->add('/atom.xml', 'atom');
$r->add('/{path:.*\\.[a-zA-Z0-9]+}', 'fallback');

my $hash = $r->matcher->to_hash;
my $m = Router::Assemble::Matcher->new($hash);

is_deeply [$m->match('/atom.xml')], ['atom', {}];
is_deeply [$m->match('/path/to/index.html')], [
    'fallback',
    {path => 'path/to/index.html'}
];

done_testing;
