#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;

chomp(my $instructions = <>);
my @instructions = map {$_ eq 'L' ? 0 : 1} split '', $instructions;

my %nodes;
while (<>) {
    chomp;
    if (my ($element, $nl, $nr) = (/^([A-Z]+) = \(([A-Z]+), ([A-Z]+)\)/)) {
        $nodes{$element} = [$nl, $nr];
    }
}

my $ip = 0;
my $element = 'AAA';
my $steps = 0;

while ($element ne 'ZZZ') {
    $element = $nodes{$element}[$instructions[$ip]];
    $ip = ($ip + 1) % @instructions;
    $steps += 1;
}

say $steps;
