#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;

my %seats;

foreach (<>) {
    tr/FBLR/0101/;

    my $row = eval '0b' . substr($_, 0, 7);
    my $col = eval '0b' . substr($_, 7, 3);

    my $seat = $row * 8 + $col;

    $seats{$seat} = undef;
}

my @seats = sort {$a <=> $b} keys %seats;

for my $seat ($seats[0]+1 .. $seats[-1]-1) {
    if (! exists $seats{$seat} && exists $seats{$seat-1} && exists $seats{$seat+1}) {
        say $seat;
        last;
    }
}
