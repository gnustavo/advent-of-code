#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;

my @cards = (undef);

while (<>) {
    if (/^Card\s+\d+:\s*([\d\s]+?)\s+\|\s+([\d\s]+?)\s*$/) {
        my %winning = map {($_ => undef)} split ' ', $1;
        my @having = split ' ', $2;
        my $wins = 0;
        foreach (@having) {
            $wins += 1 if exists $winning{$_};
        }
        push @cards, {
            winning => \%winning,
            having  => \@having,
            wins    => $wins,
            copies  => 1,
        };
    }
}

my $cards = 0;

for my $i (1 .. $#cards) {
    for (1 .. $cards[$i]{copies}) {
        for (my $j=1; $j <= $cards[$i]{wins}; ++$j) {
            if ($i+$j < @cards) {
                $cards[$i+$j]{copies} += 1;
            }
        }
    }
    $cards += $cards[$i]{copies};
}

say $cards;
