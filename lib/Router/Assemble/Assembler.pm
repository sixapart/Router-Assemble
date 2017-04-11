package Router::Assemble::Assembler;

use strict;
use warnings;
use utf8;

use List::Util qw(min);
use Regexp::Assemble;

use Router::Assemble::Constant;

sub new {
    my $class = shift;
    my $self = +{@_==1 ? %{$_[0]} : @_};

    local $Regexp::Assemble::Current_Lexer = qr/(?![[(\\]).(?:[*+?]\??|\{\d+(?:,\d*)?\}\??)?|\\(?:[bABCEGLQUXZ]|[lu].|(?:[^\w]|[aefnrtdDwWsS]|c.|0\d{2}|x(?:[\da-fA-F]{2}|{[\da-fA-F]{4}})|N\{\w+\}|[Pp](?:\{\w+\}|.))(?:[*+?]\??|\{\d+(?:,\d*)?\}\??)?)|\[.*?(?<!\\)\](?:[*+?]\??|\{\d+(?:,\d*)?\}\??)?|(\((?:[^\(\)]++|(?<!\\\\)|(?1))*\)(?:[*+?]\??|\{\d+(?:,\d*)?\}\??)?)/;

    $self->{assembler} //= Regexp::Assemble->new;

    bless $self, $class;
}

sub add {
    my $self = shift;

    $self->{assembler}->add(@_);
}

sub _min_index {
    my $self = shift;

    min($_[0] =~ /\(\?<@{[INDEX_KEYWORD]}>(\d+)\)/g);
}

sub regexp {
    no warnings 'redefine';

    my $self = shift;

    local $Regexp::Assemble::Single_Char = qr//;
    local *Regexp::Assemble::_re_sort = sub($$) {
        my ($a, $b) = @_;

        $self->_min_index($a) <=> $self->_min_index($b)
            || length $b <=> length $a
            || $a cmp $b;
    };

    $self->{assembler}->re;
}

1;
