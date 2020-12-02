#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;

# Reads a list of integers and find a triple which adds to 2020, returning the
# triple product.

my @input = sort {$a <=> $b} <>;

sub result {
    my ($i, $j, $k) = @_;
    printf "%d * %d * %d == %d\n", $input[$i], $input[$j], $input[$k], $input[$i] * $input[$j] * $input[$k];
    #exit 0;
}

say "\nTake 0 - simpleton";

for (my $i=0; $i < (@input - 2); ++$i) {
    for (my $j=$i+1; $j < (@input - 1); ++$j) {
        for (my $k=$j+1; $k < @input; ++$k) {
            if ($input[$i] + $input[$j] + $input[$k] == 2020) {
                result($i, $j, $k);
            }
        }
    }
}
