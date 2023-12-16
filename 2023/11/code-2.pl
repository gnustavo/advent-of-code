#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;

my @galaxies;

{
    my $y = 0;
    while (<>) {
        my $x = -1;
        while (1) {
            $x = index $_, '#', $x;
            last if $x == -1;
            push @galaxies, [$y, $x];
            $x += 1;
        }
        $y += 1;
    }
}

die "There are no galaxies in this universe!\n" unless @galaxies;

use Data::Dump;
#ddx \@galaxies;

my $expansion_rate = 1000000;

# Expand in the Y direction, noting that they are already sorted in this
# direction.
{
    my $y = 0;
    my $expansion = 0;
    foreach my $galaxy (@galaxies) {
        if ($galaxy->[0] > $y) {
            $expansion += ($expansion_rate - 1) * ($galaxy->[0] - $y - 1);
            $y = $galaxy->[0];
        }
        $galaxy->[2] = $galaxy->[0] + $expansion;
    }
}

#ddx \@galaxies;

# Expand in the X direction.
{
    my $x = 0;
    my $expansion = 0;
    foreach my $galaxy (sort {$a->[1] <=> $b->[1]} @galaxies) {
        if ($galaxy->[1] > $x) {
            $expansion += ($expansion_rate - 1) * ($galaxy->[1] - $x - 1);
            $x = $galaxy->[1];
        }
        $galaxy->[3] = $galaxy->[1] + $expansion;
    }
}

#ddx [sort {$a->[1] <=> $b->[1]} @galaxies];
#ddx \@galaxies;

my $sum = 0;

for (my $i=0; $i < @galaxies; ++$i) {
    for (my $j=$i+1; $j < @galaxies; ++$j) {
        $sum += abs($galaxies[$j][2] - $galaxies[$i][2]) + abs($galaxies[$j][3] - $galaxies[$i][3]);
    }
}

say $sum;
