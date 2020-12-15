#!/usr/bin/env perl

use 5.030;
use warnings;

while (<>) {
    chomp;
    say;
    my @starting = split /,/;
    say spoken_at(     2_020, @starting);
    say spoken_at(30_000_000, @starting);
    say '';
}

sub spoken_at {
    my ($at, @starting) = @_;
    my ($turn, @prev, @last) = (1);
    foreach my $spoken (@starting) {
        $prev[$spoken] = $last[$spoken];
        $last[$spoken] = $turn;
        $turn += 1;
    }
    my $speak = $starting[-1];
    for (; $turn <= $at; $turn += 1) {
        if (defined $prev[$speak]) {
            $speak = $last[$speak] - $prev[$speak];
        } else {
            $speak = 0;
        }
        $prev[$speak] = $last[$speak];
        $last[$speak] = $turn;
    }
    return $speak;
}
