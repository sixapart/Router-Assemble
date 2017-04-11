use strict;
use warnings;
use utf8;

use Test::More;
use Router::Assemble;

subtest 'static files and fallback' => sub {
    my $r = Router::Assemble->new;
    $r->add('/index.html', 'index');
    $r->add('/styles.css', 'styles');
    $r->add('/news.html', 'news');
    $r->add('/atom.xml', 'atom');
    $r->add('/{path:.*\\.[a-zA-Z0-9]+}', 'fallback');

    is_deeply [$r->match('/atom.xml')], ['atom', {}];
    is_deeply [$r->match('/path/to/index.html')], [
        'fallback',
        {path => 'path/to/index.html'}
    ];
};

subtest 'category archive with prefix' => sub {
    my $r = Router::Assemble->new;
    $r->add('/blog/{category:\w+}',           'cat');
    $r->add('/blog/mobile/{category:\w+}',    'mobile-cat');
    $r->add('/blog/{path:.*\\.[a-zA-Z0-9]+}', 'fallback');

    is_deeply [$r->match('/blog/mobile/cat')], [
        'mobile-cat',
        {category => 'cat'},
    ];
};

subtest 'overwrite' => sub {
    my $r = Router::Assemble->new;
    $r->add('/blog/{category:\w+}', 'cat-1');
    $r->add('/blog/{category:\w+}', 'cat-2');

    is_deeply [$r->match('/blog/cat')], [
        'cat-2',
        {category => 'cat'},
    ];
};

subtest 'route_cmp' => sub {
    subtest 'in the added order' => sub {
        subtest 'category' => sub {
            my $r = Router::Assemble->new;
            $r->add('/{category:\w+}', 'cat');
            $r->add('/blog',           'blog_main');

            is_deeply[$r->match('/blog')], ['cat', {category => 'blog'}];
        };

        subtest 'blog' => sub {
            my $r = Router::Assemble->new;
            $r->add('/blog',           'blog_main');
            $r->add('/{category:\w+}', 'cat');

            is_deeply[$r->match('/blog')], ['blog_main', {}];
        };
    };

    subtest 'in the custom order' => sub {
        my $new_router = sub {
            Router::Assemble->new(
                route_cmp => sub($$){
                    my ($a, $b) = @_;
                    # try to match to static route first
                    $a->[0] =~ m/[\+\*]/ <=> $b->[0] =~ m/[\+\*]/;
                },
            );
        };

        subtest 'category' => sub {
            my $r = $new_router->();
            $r->add('/{category:\w+}', 'cat');
            $r->add('/blog',           'blog_main');

            is_deeply[$r->match('/blog')], ['blog_main', {}];
        };

        subtest 'blog' => sub {
            my $r = $new_router->();
            $r->add('/blog',           'blog_main');
            $r->add('/{category:\w+}', 'cat');

            is_deeply[$r->match('/blog')], ['blog_main', {}];
        };
    };
};

subtest 'quotemeta_static_path' => sub {
    subtest 'quotemeta_static_path: 1' => sub {
        my $r = Router::Assemble->new;
        $r->add('/(a)/index.html', '(a)');

        is_deeply[$r->match('/(a)/index.html')], ['(a)', {}];
    };

    subtest 'quotemeta_static_path: 0' => sub {
        my $r = Router::Assemble->new(
            quotemeta_static_path => 0,
        );
        $r->add('/(?:a|b)/index.html', '(a)');

        is_deeply[$r->match('/(a)/index.html')], [];
        is_deeply[$r->match('/a/index.html')], ['(a)', {}];
        is_deeply[$r->match('/b/index.html')], ['(a)', {}];
    };
};

done_testing;
