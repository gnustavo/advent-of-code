#!/usr/bin/env perl

use 5.030;
use warnings;

chomp(my @input = <>);

my $cols = length $input[0];
my $seats = '.' x (3+$cols) . join('..', @input) . '.' x (3+$cols);
my $skip = $cols - 1;
my $empty_to_change  = "([.L]{3})  .{$skip} ([.L])(L)([.L])     .{$skip} ([.L]{3})";
my $seated_to_change = "([.L#]{3}) .{$skip} ([.L#])(\\#)([.L#]) .{$skip} ([.L#]{3})";
my $empty_to_change_rx  = qr/$empty_to_change/ox;
my $seated_to_change_rx = qr/$seated_to_change/ox;

my @changes;
while (1) {
    while ($seats =~ /$empty_to_change_rx/g) {
        push @changes, [$-[3], '#'];
        pos($seats) = $-[0] + 1;
    }
    while ($seats =~ /$seated_to_change_rx/g) {
        push @changes, [$-[3], 'L'] if (join('', @{^CAPTURE}) =~ tr/#//) > 4;
        pos($seats) = $-[0] + 1;
    }
    last unless @changes;
    substr($seats, $_->[0], 1) = $_->[1] foreach @changes;
    @changes = ();
}

say $seats =~ tr/#//;
