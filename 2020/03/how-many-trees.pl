#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;

my @map;

while (<>) {
    chomp;
    push @map, [split(//)];
}

my ($right, $down) = (3, 1);

my $tree_count = 0;

my ($y, $x) = (0, 0);

while ($x < @map) {
    ++$tree_count if $map[$x][$y] eq '#';
    $y = ($y + $right) % @{$map[$x]};
    $x += $down;
}

say $tree_count;
