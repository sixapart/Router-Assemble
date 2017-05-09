package Router::Assemble;

use 5.010001;
use strict;
use warnings;
use utf8;

our $VERSION = '1.00';

use Router::Assemble::Builder;

sub new {
    my $class = shift;
    my $self  = +{@_==1 ? %{$_[0]} : @_};

    my %builder_args;
    for my $k (qw(route_cmp quotemeta_static_path)) {
        $builder_args{$k} = delete $self->{$k} if exists $self->{$k};
    }
    $self->{builder} ||= Router::Assemble::Builder->new(%builder_args);

    bless $self, $class;
}

sub matcher {
    my $self = shift;

    $self->{matcher} ||= $self->{builder}->matcher;
}

sub add {
    my $self = shift;

    delete $self->{matcher};

    $self->{builder}->add(@_);
}

sub match {
    shift->matcher->match(@_);
}

1;
__END__

=encoding utf-8

=head1 NAME

Router::Assemble - Fast, dumpable/restorable and weight adjustable routing engine for web applications

=head1 SYNOPSIS

    use Router::Assemble;

    my $router = Router::Assemble->new();
    $router->add('/', 'dispatch_root');
    $router->add('/entrylist', 'dispatch_entrylist');
    $router->add('/:user', 'dispatch_user');
    $router->add('/:user/{year}', 'dispatch_year');
    $router->add('/:user/{year}/{month:\d+}', 'dispatch_month');
    $router->add('/download/*', 'dispatch_download');

    my $dest = $router->match($env->{PATH_INFO});

=head1 DESCRIPTION

Router::Assemble is yet another routing engine for web applications. This module is inspired by L<Router::Boom> and powered by L<Regexp::Assemble>.

=head2 Fast

This module is pretty fast, almost as fast as L<Router::Boom>.

                         Rate Router::Assemble     Router::Boom
    Router::Assemble 220553/s               --              -0%
    Router::Boom     220554/s               0%               --

=head2 Dump and restore

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

=head2 Weight adjustable

By default, L<Router::Assemble> routes in order of addition.

    my $router = Router::Assemble->new();
    $router->add('/{category:\w+}', 'cat');
    $router->add('/blog',           'blog_main');

    $router->match('/blog') # cat

By using I<route_cmp>, we can adjust routing order.

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

=head2 Compatibility with L<Router::Boom>

L<Router::Assemble> is compatible with L<Router::Boom> about basic API.

=head1 MEHTODS

=over 4

=item my $router = Router::Assemble->new(%options)

Create a new instance. %options may contains these values.

=over 4

=item route_cmp

A subroutine for comparing routes. this subroutine will be called at first arguments of "sort". The value to be compared is [$path, $context] pair of registered via "add".

=back

=item $router->add($path, $context)

Add a route. $path accepts a string value. See the PATH DEFINITION section for details on how $path value is specified. $context accepts any value.

=item my ($context, $captured) = $router->match($path);

Attempt to find route that matches the given $path and return two values if a route is found. $context is a value of registered via "add". $captured is a hashref that contains placeholders given from $path.

Return empty list if no route is found.

=back

=head1 PATH DEFINITION

=over 4

=item C<{name:\w+}>

Accepts "\w+" in this component. And "name" will be used as a key in the $captured.

    $router->add('/user/{name:\w+}', 'profile');
    $router->match('/user/foo');
    # => ('profile', {name => 'foo'})

You can use "(?:pattern)". (But you can not use "(pattern)")

    $router->add('/user/{name:(?:bar|baz)}', 'special_profile');
    $router->add('/user/{name:\w+}', 'profile');
    $router->match('/user/bar');
    # => ('special_profile', {name => 'bar'})

=item C<:name> and C<{name}>

Same as C<{name:[^/]+}>.

    $router->add('/user/:name', 'profile');
    $router->match('/user/foo');
    # => ('profile', {name => 'foo'})

=item C<*>

Same as C<{*:.+}>.

    $router->add('/archive/*', 'archive');
    $router->match('/archive/path/to/files.zip');
    # => ('archive', {'*' => 'path/to/files.zip'})

=back

=head1 LICENSE

Copyright (C) Six Apart Ltd. E<lt>sixapart@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Taku AMANO E<lt>usualoma@cpan.orgE<gt>

=head1 SEE ALSO

L<Router::Boom> Pretty fast routing engine for web applications.

L<Regexp::Assemble> Assemble multiple Regular Expressions into a single RE.

=cut
