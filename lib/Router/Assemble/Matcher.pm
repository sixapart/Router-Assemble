package Router::Assemble::Matcher;

use strict;
use warnings;
use utf8;

use Router::Assemble::Util;

sub new {
    use re 'eval';

    my $class = shift;
    my $self  = +{@_==1 ? %{$_[0]} : @_};

    $self->{routes} = +[] unless exists $self->{routes};
    $self->{regexp} = qr/$self->{regexp}/ if exists $self->{regexp};

    bless $self, $class;
}

sub regexp {
    my $self = shift;
    $self->{regexp};
}

sub match {
    my $self = shift;
    my ($path) = @_;

    # copatibility with Router::Simple/Router::Boom
    #
    # "I think there was a discussion about that a while ago and it is up to apps to deal with empty PATH_INFO as root / iirc"
    # -- by @miyagawa
    #
    # see http://blog.64p.org/entry/2012/10/05/132354
    $path = '/' if $path eq '';

    my @res = ($path =~ $self->{regexp})
        or return ();
    my ($names, $ctx) = @{$self->{routes}->[$^R]};

    my %captured;
    @captured{@$names} = grep { defined $_ } @res;

    $ctx, \%captured;
}

sub to_hash {
    my $self = shift;

    +{
        regexp => $self->{regexp} . "",
        routes => $self->{routes},
    };
}

1;
