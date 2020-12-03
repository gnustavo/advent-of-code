#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;

my @map;

while (<>) {
    chomp;
    push @map, [split(//)];
}

my @slopes = (
    [1, 1],
    [3, 1],
    [5, 1],
    [7, 1],
    [1, 2],
);

my $result = 1;

foreach my $slope (@slopes) {
    my $tree_count = 0;
    my ($right, $down) = @$slope;
    my ($y, $x) = (0, 0);

    while ($x < @map) {
        ++$tree_count if $map[$x][$y] eq '#';
        $y = ($y + $right) % @{$map[$x]};
        $x += $down;
    }

    $result *= $tree_count;
}

say $result;
