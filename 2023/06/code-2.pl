#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use POSIX qw(ceil floor);
use List::Util qw(max min product);
use Data::Dump;

my (undef, @times) = split ' ', <>;
chomp(@times);
@times = (join('', @times));

my (undef, @distances) = split ' ', <>;
chomp(@distances);
@distances = (join('', @distances));

my @wins;

for (my $i=0; $i < @times; ++$i) {
    my ($time, $distance) = ($times[$i], $distances[$i]);
    my $delta = $time*$time - 4*$distance;
    next if $delta < 0;
    my $sqrt_delta = sqrt($delta);
    my $lower = ($time - $sqrt_delta)/2;
    my $ceil  = ceil($lower);
    if ($lower == $ceil) {
        $ceil += + 1;
    }
    my $upper = ($time + $sqrt_delta)/2;
    my $floor = floor($upper);
    if ($upper == $floor) {
        $floor -= 1;
    }
    my $wins  = $floor - $ceil + 1;
    #ddx $time, $distance, $delta, $sqrt_delta, $lower, $ceil, $upper, $floor, $wins;
    push @wins, $wins;
}

say product @wins;
