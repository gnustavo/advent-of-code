#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;
use integer;

# Gets an integer argument N and reads a list of integers from stdin. It finds a
# subset of the integers, having N members, which adds to 2020, returning the
# product of the integers in the subset.

my $n = shift;

my @input = sort {$a <=> $b} map {0+$_} <>;

die "The input has less than $n numbers!\n"
    unless $n < @input;

say "\nTake 0 - simpleton";

my @indexes = (-1);

sub result {
    my $product = 1;
    $product *= $input[$_] foreach @indexes[1..$#indexes];
    say join(' * ', @input[@indexes[1..$#indexes]]), " == $product";
    exit 0;
}

sub sumit {
    my ($index, $sum) = @_;

    for ($indexes[$index]=$indexes[$index-1]+1;
         $indexes[$index] < (@input - $n + $index);
         ++$indexes[$index]
     ) {
        if ($index == $n) {
            result() if ($sum + $input[$indexes[$index]]) == 2020;
        } else {
            sumit($index+1, $sum + $input[$indexes[$index]]);
        }
    }
}

sumit(1, 0);
