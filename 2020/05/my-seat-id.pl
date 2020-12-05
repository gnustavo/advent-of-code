#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;

my @seats = sort {$a <=> $b} map {tr/FBLR/0101/; eval "0b$_"} <>;

for (my $i=0; $i < $#seats; ++$i) {
    if ($seats[$i+1] - $seats[$i] == 2) {
        say $seats[$i] + 1;
        exit 0;
    }
}

die "No seat found!\n";
