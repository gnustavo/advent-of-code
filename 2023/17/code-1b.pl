#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;
use Array::Heap;

package My::Elem {
    sub cmp { ## no critic (ProhibitBuiltinHomonyms)
        my ($self, $other) = @_;
        return $self->[4] <=> $other->[4] || $self->[2] cmp $other->[2];
    }
}

my @map;
while (<>) {
    chomp;
    push @map, [split ''];
}
my $width = $map[0]->@*;

sub show {
    ddx [map {join '', @$_} @map];
    return;
}

#show();

my %dirs = (
    '^' => [-1, 0],
    '>' => [0, +1],
    'v' => [+1, 0],
    '<' => [0, -1],
);

my %opposites = (
    '^' => 'v',
    '>' => '<',
    'v' => '^',
    '<' => '>',
);

my %passed;

my @heap = ([0, 1, '>', 1, 0], [1, 0, 'v', 1, 0]);

sub compare {
    return $a->[4] <=> $b->[4] || $a->[2] cmp $b->[2];
}

make_heap_cmp(\&compare, @heap);

my $min_heat_loss;

while (my $op = pop_heap_cmp(\&compare, @heap)) {
    my ($y, $x, $direction, $times, $heat_loss) = @$op;

    next if $times > 3;

    next if ($y < 0) || ($y == @map) || ($x < 0) || ($x == $width);

    $heat_loss += $map[$y][$x];

    #next if $passed{$y}{$x}{$direction}++; # already passed here

    next if exists $passed{$y}{$x}{$direction} && $heat_loss >= $passed{$y}{$x}{$direction};

    $passed{$y}{$x}{$direction} = $heat_loss;

    next if defined $min_heat_loss && $heat_loss >= $min_heat_loss;

    if ($y == $#map && $x == $width-1) {
        # Reached destination with less head loss
        $min_heat_loss = $heat_loss;
        next;
    }

    #printf "%5d:%*s\n", $heat_loss, $n, '>';

    push_heap_cmp(
        \&compare,
        @heap,
        [
            $y + $dirs{$_}[0],
            $x + $dirs{$_}[1],
            $_,
            ($_ eq $direction ? $times+1 : 1),
            $heat_loss,
        ],
    ) foreach
        grep {$_ ne $opposites{$direction}}
        keys %dirs
        ;

    #printf "%5d:%*s\n", $heat_loss, $n, '<';
} continue {
    #say ' ' x scalar(@heap), scalar(@heap);
}

say $min_heat_loss;
