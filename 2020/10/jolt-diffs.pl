#!/usr/bin/env perl

use 5.030;
use warnings;
no warnings 'recursion';

my @sorted_input = sort {$a <=> $b} <>;

sub one {
    my $previous = 0;
    my @diffs;

    for my $output (@sorted_input) {
        $diffs[$output - $previous] += 1;
        $previous = $output;
    }
    $diffs[3] += 1;             # count the diff to my device

    return $diffs[1] * $diffs[3];
}

sub two {
    my @extended_input = (0, @sorted_input, $sorted_input[-1]+3);

    return count_ways(\@extended_input, 0);
}

sub count_ways {
    my ($sequence, $i) = @_;

    state $cache = [];

    unless (defined $cache->[$i]) {
        if ($i == $#$sequence) {
            $cache->[$i] = 1;
        } else {
            my $ways = 0;
            my $jolt = $sequence->[$i];
            for (my $j=$i+1; $j < @{$sequence} && $sequence->[$j] - $jolt <= 3; ++$j) {
                $ways += count_ways($sequence, $j);
            }
            $cache->[$i] = $ways;
        }
    }
    return $cache->[$i];
}

my $one = one();
my $two = two();

say $one;
say $two;
