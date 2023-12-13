#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;

my $points = 0;
while (<>) {
    if (/^Card\s+\d+:\s*([\d\s]+?)\s+\|\s+([\d\s]+?)\s*$/) {
        my %winning = map {($_ => undef)} split ' ', $1;
        my @having = split ' ', $2;
        my $wins = 0;
        foreach (@having) {
            $wins += 1 if exists $winning{$_};
        }
        $points += 2 ** ($wins-1) if $wins;
        #warn "$.: wins=$wins\tpoints=$points\n";
    }
}
say $points;
