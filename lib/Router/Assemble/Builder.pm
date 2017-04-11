package Router::Assemble::Builder;

use strict;
use warnings;
use utf8;

use Carp ();

use Router::Assemble::Assembler;
use Router::Assemble::Matcher;
use Router::Assemble::Util;
use Router::Assemble::Constant;

sub new {
    my $class = shift;
    my $self  = +{@_==1 ? %{$_[0]} : @_};

    $self->{routes}                = +[] unless exists $self->{routes};
    $self->{quotemeta_static_path} = 1   unless exists $self->{quotemeta_static_path};

    bless $self, $class;
}

sub new_assembler {
    Router::Assemble::Assembler->new;
}

sub compile {
    use re 'eval';

    my $self = shift;
    my $assembler = $self->new_assembler;

    my @routes = @{$self->{routes}};
    if (my $cmp = $self->{route_cmp}) {
        @routes = sort $cmp @routes;
    }

    my @compiled_routes;
    for (my $i = 0; $i < scalar @routes; $i++) {
        my @names;
        my @tokens =
            map {
                if (is_placeholder($_)) {
                    my ($name, $regexp) = split_placeholder($_);
                    push @names, $name;
                    "($regexp)";
                }
                else {
                    $self->{quotemeta_static_path} ? quotemeta($_) : $_;
                }
            }
            map { normalize_path_component($_) }
            split_path($routes[$i][0]);

        $assembler->add(join('', @tokens) . "\\z(?<@{[INDEX_KEYWORD]}>$i)");
        push @compiled_routes, [\@names, $routes[$i][1]];
    }

    (my $r = "\\A@{[$assembler->regexp]}") =~ s/\(\?<@{[INDEX_KEYWORD]}>(\d+)\)/(?{$1})/g;

    [qr/$r/, \@compiled_routes];
}

# True if : ()
# False if : (?:)
sub _is_normal_capture {
    $_[0] =~ /
        \(
            (?!
                \?:
            )
    /x
}

sub add {
    my $self = shift;
    my ($path, $ctx) = @_;

    delete $self->{matcher};

    Carp::croak("You can't include parens in your custom rule.")
        if grep {
                _is_normal_capture(
                    is_placeholder($_)
                        ? (split_placeholder($_))[1]
                        : $_
                )
            }
            grep { !$self->{quotemeta_static_path} || is_placeholder($_) }
            map { normalize_path_component($_) }
            split_path($path);

    for (my $i = 0; $i < scalar @{$self->{routes}}; $i++) {
        next if $self->{routes}->[$i][0] ne $path;
        $self->{routes}->[$i][1] = $ctx;
        return;
    }

    push @{$self->{routes}}, [$path, $ctx];
}

sub matcher {
    my $self = shift;

    $self->{matcher} ||= do {
        my ($regexp, $routes) = @{$self->compile};
        Router::Assemble::Matcher->new(
            regexp => $regexp,
            routes => $routes,
        );
    };
}

1;
