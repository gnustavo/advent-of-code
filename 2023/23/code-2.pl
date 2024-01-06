#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;
use List::Util qw(min max);
use List::MoreUtils qw(binsert);

my @map;
while (<>) {
    chomp;
    push @map, [split ''];
}

my ($x_beg, $x_end);
{
    while (my ($x, $c) = each $map[0]->@*) {
        if ($c eq '.') {
            $x_beg = $x;
            $map[0][$x] = 'S';
            last;
        }
    }
    while (my ($x, $c) = each $map[-1]->@*) {
        if ($c eq '.') {
            $x_end = $x;
            $map[-1][$x] = 'E';
            last;
        }
    }
}

sub show {
    say '';
    foreach (@map) {
        say join('', @$_);
    }
    return;
}

show;

my %dirs = (
    '.' => [[-1, 0], [+1, 0], [0, -1], [0, +1]],
    'S' => [[+1, 0]],
    '<' => [[-1, 0], [+1, 0], [0, -1], [0, +1]],
    '>' => [[-1, 0], [+1, 0], [0, -1], [0, +1]],
    '^' => [[-1, 0], [+1, 0], [0, -1], [0, +1]],
    'v' => [[-1, 0], [+1, 0], [0, -1], [0, +1]],
);

sub walk {
    my ($y, $x) = @_;
    my $c = $map[$y][$x];
    my $dirs = $dirs{$c};
    unless (defined $dirs) {
        if ($c eq '#' || $c eq 'O') {
            return;
        } elsif ($c eq 'E') {
            #show;
            return 0;
        } else {
            die "Can't happen!";
        }
    }

    local $map[$y][$x] = 'O';
    my $max = 0;
    foreach my $dir (@$dirs) {
        my $length = walk($y + $dir->[0], $x + $dir->[1]);
        $max = $length if defined $length && $max < $length;
    }

    return $max + 1;
}

say walk(0, $x_beg);
