#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;

my $highest_seat_id = -1;

foreach (<>) {
    tr/FBLR/0101/;

    my $row = eval '0b' . substr($_, 0, 7);
    my $col = eval '0b' . substr($_, 7, 3);

    my $seat_id = $row * 8 + $col;

    $highest_seat_id = $seat_id if $highest_seat_id < $seat_id;
}

say $highest_seat_id;
