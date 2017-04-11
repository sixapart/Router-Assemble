package Router::Assemble::Util;

use strict;
use warnings;
use utf8;

use parent 'Exporter';
our @EXPORT = qw(
    normalize_path_component split_path is_placeholder split_placeholder
);

our $placeholder_content_regexp = qr/(?:\{[0-9,]+\}|[^{}])/;

sub normalize_path_component {
    my $c = shift;

    if (   $c =~ m/\A\{((?:$placeholder_content_regexp(?!:))+)\}\z/
        || $c =~ m/\A:([A-Za-z0-9_]+)\z/ )
    {
        "{$1:[^/]+}";
    }
    elsif ( $c eq '*' ) {
        '{*:.+}';
    }
    else {
        $c;
    }
}

sub split_path {
    $_[0] =~ m{(
        \{(?:$placeholder_content_regexp)+\} | # /blog/{year:\d{4}}
        :[A-Za-z0-9_]+                       | # /blog/:year
        \*                                   | # /blog/*/*
        (?:\(\?\:.*?\)|[^\{:*])+               # normal string
    )}gx
}

sub is_placeholder {
    !!split_placeholder( $_[0] );
}

sub split_placeholder {
    $_[0] =~ m{\A\{
        ((?:$placeholder_content_regexp)+?)
        :
        ((?:$placeholder_content_regexp)+)
    \}\z}x;
}

1;
