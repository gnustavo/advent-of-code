#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;

my @platform;
while (<>) {
    chomp;
    push @platform, [split ''];
}

#ddx \@platform;

my @shifted;

while (my ($i, $row) = each @platform) {
    push @shifted, [];
    while (my ($j, $char) = each @$row) {
        my $k = $i;
        if ($char eq 'O') {
            while ($k > 0 && $shifted[$k-1][$j] eq '.') {
                $k -= 1;
            }
            if ($k < $i) {
                $shifted[$i][$j] = '.';
            }
        }
        $shifted[$k][$j] = $char;
    }
}

#ddx \@shifted;

my $total_load = 0;

while (my ($i, $row) = each @shifted) {
    my $load = @shifted - $i;
    my $rounded_rocks = grep {$_ eq 'O'} @$row;
    $total_load += $load * $rounded_rocks;
}

say $total_load;
