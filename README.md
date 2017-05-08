[![Build Status](https://travis-ci.org/sixapart/Router-Assemble.svg?branch=master)](https://travis-ci.org/sixapart/Router-Assemble) [![Coverage Status](https://coveralls.io/repos/github/sixapart/Router-Assemble/badge.svg?branch=master)](https://coveralls.io/github/sixapart/Router-Assemble?branch=master)

# NAME

Router::Assemble - Fast, dumpable/restorable and weight adjustable routing engine for web applications

# SYNOPSIS

    use Router::Assemble;

    my $router = Router::Assemble->new();
    $router->add('/', 'dispatch_root');
    $router->add('/entrylist', 'dispatch_entrylist');
    $router->add('/:user', 'dispatch_user');
    $router->add('/:user/{year}', 'dispatch_year');
    $router->add('/:user/{year}/{month:\d+}', 'dispatch_month');
    $router->add('/download/*', 'dispatch_download');

    my $dest = $router->match($env->{PATH_INFO});

# DESCRIPTION

Router::Assemble is yet another routing engine for web applications. This module is inspired by [Router::Boom](https://metacpan.org/pod/Router::Boom) and powered by [Regexp::Assemble](https://metacpan.org/pod/Regexp::Assemble).

## Fast

This module is prity fast, almost as fast as [Router::Boom](https://metacpan.org/pod/Router::Boom).

                         Rate Router::Assemble     Router::Boom
    Router::Assemble 220553/s               --              -0%
    Router::Boom     220554/s               0%               --

## Dump and restore

    my $router = Router::Assemble->new();
    build_routes($router); # add routes for your application

    # Get an instance of Router::Assemble::Matcher.
    # This object holds the minimum information necessary for routing.
    my $matcher = $router->matcher;
    $matcher->match($env->{PATH_INFO});

    # dump and restore
    my $hash = $matcher->to_hash;                     # Dump as a hash object that can be expressed as JSON
    my $m    = Router::Assemble::Matcher->new($hash); # Restore. This is very fast
    $m->match($env->{PATH_INFO});

## Weight adjustable

By default, [Router::Assemble](https://metacpan.org/pod/Router::Assemble) routes in order of addition.

    my $router = Router::Assemble->new();
    $router->add('/{category:\w+}', 'cat');
    $router->add('/blog',           'blog_main');

    $router->match('/blog') # cat

By using _route\_cmp_, we can adjust routing order.

    my $router = Router::Assemble->new(
        route_cmp => sub($$){
            my ($a, $b) = @_;
            # route to static route first
            $a->[0] =~ m/[\+\*]/ <=> $b->[0] =~ m/[\+\*]/;
        },
    );
    $router->add('/{category:\w+}', 'cat');
    $router->add('/blog',           'blog_main');

    $router->match('/blog') # blog_main

## Copatibility with [Router::Boom](https://metacpan.org/pod/Router::Boom)

[Router::Assemble](https://metacpan.org/pod/Router::Assemble) is compatible with [Router::Boom](https://metacpan.org/pod/Router::Boom) about basic API.

# MEHTODS

- my $router = Router::Assemble->new(%options)

    Create a new instance. %options may contains these values.

    - route\_cmp

        A subroutine for comparing routes. this subroutine will be called at first arguments of "sort". The value to be compared is \[$path, $context\] pair of registered via "add".

- $router->add($path, $context)

    Add a route. $path accepts a string value. See the PATH DEFINITION section for details on how $path value is specified. $context accepts any value.

- my ($context, $captured) = $router->match($path);

    Attempt to find route that matches the given $path and return two values if a route is found. $context is a value of registered via "add". $captured is a hashref that contains placeholders given from $path.

    Return empty list if no route is found.

# PATH DEFINITION

- `{name:\w+}`

    Accepts "\\w+" in this component. And "name" will be used as a key in the $captured.

        $router->add('/user/{name:\w+}', 'profile');
        $router->match('/user/foo');
        # => ('profile', {name => 'foo'})

    You can use "(?:pattern)". (But you can not use "(pattern)")

        $router->add('/user/{name:(?:bar|baz)}', 'special_profile');
        $router->add('/user/{name:\w+}', 'profile');
        $router->match('/user/bar');
        # => ('special_profile', {name => 'bar'})

- `:name` and `{name}`

    Same as `{name:[^/]+}`.

        $router->add('/user/:name', 'profile');
        $router->match('/user/foo');
        # => ('profile', {name => 'foo'})

- `*`

    Same as `{*:.+}`.

        $router->add('/archive/*', 'archive');
        $router->match('/archive/path/to/files.zip');
        # => ('archive', {'*' => 'path/to/files.zip'})

# LICENSE

Copyright (C) Six Apart Ltd. <sixapart@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Taku AMANO <usualoma@cpan.org>

# SEE ALSO

[Router::Boom](https://metacpan.org/pod/Router::Boom) Prity fast routing engine for web applications.

[Regexp::Assemble](https://metacpan.org/pod/Regexp::Assemble) Assemble multiple Regular Expressions into a single RE.
