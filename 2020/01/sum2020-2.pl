#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;
use integer;

# Reads a list of integers and find a pair which adds to 2020, returning the
# pair product.

my @input = sort {$a <=> $b} <>;

sub result {
    my ($i, $j) = @_;
    printf "%d * %d == %d\n", $input[$i], $input[$j], $input[$i] * $input[$j];
    #exit 0;
}

say "\nTake 0 - simpleton";

for (my $i=0; $i < $#input; ++$i) {
    for (my $j=$i+1; $j <= $#input; ++$j) {
        if ($input[$i] + $input[$j] == 2020) {
            result($i, $j);
        }
    }
}

say "\nTake 1 - binary search";

for (my $i=0; $i < $#input; ++$i) {
    my ($left, $right) = ($i+1, $#input);
    while ($left <= $right) {
        my $j = ($left + $right) / 2;
        my $sum = $input[$i] + $input[$j];
        if ($sum < 2020) {
            $left = $j+1;
        } elsif ($sum > 2020) {
            $right = $j-1;
        } else {
            result($i, $j);
            last;
        }
    }
}
