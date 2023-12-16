#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use List::Util qw(notall);

chomp(my $instructions = <>);
my @instructions = map {$_ eq 'L' ? 0 : 1} split '', $instructions;

my %nodes;
my @elements;
while (<>) {
    chomp;
    if (my ($element, $nl, $nr) = (/^([0-9A-Z]+) = \(([0-9A-Z]+), ([0-9A-Z]+)\)/)) {
        my $mark = substr $element, -1, 1;
        if ($mark eq 'A') {
            # A start node
            push @elements, $element;
        }
        $nodes{$element} = [$nl, $nr, $mark eq 'Z'];
    }
}

my $ip = 0;
my $steps = 0;

while (notall {$nodes{$_}[2]} @elements) {
    for (my $i=0; $i < @elements; ++$i) {
        $elements[$i] = $nodes{$elements[$i]}[$instructions[$ip]];
    }
    $ip = ($ip + 1) % @instructions;
    $steps += 1;
}

say $steps;
