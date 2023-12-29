#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;
use List::Util qw(sum0);

my $steps = 64;

my (%rocks, $height, $width, $y0, $x0);
{
    my $y = 0;
    while (<>) {
        chomp;
        $height += 1;
        $width = length;
        my @row = split '';
        while (my ($x, $c) = each @row) {
            if ($c eq '#') {
                $rocks{$y}{$x} = '#';
            } elsif ($c eq 'S') {
                ($y0, $x0) = ($y, $x);
            }
        }
    } continue {
        $y += 1;
    }
}

ddx \%rocks, $height, $width, $y0, $x0;

my $reacheds = {$y0 => {$x0 => 'O'}};

for (my $i=0; $i < $steps; ++$i) {
    my %new_reacheds = ();
    while (my ($y, $row) = each %$reacheds) {
        while (my ($x, undef) = each %$row) {
            foreach my $dir ([-1, 0], [+1, 0], [0, -1], [0, +1]) {
                my ($dy, $dx) = @$dir;
                my $new_y = $y + $dy;
                next unless $new_y >= 0 && $new_y < $height;
                my $new_x = $x + $dx;
                next unless $new_x >= 0 && $new_x < $width;
                next if exists $rocks{$new_y}{$new_x};
                $new_reacheds{$new_y}{$new_x} = 'O';
            }
        }
    }
    $reacheds = \%new_reacheds;
}

ddx $reacheds;

my $nof_plots = 0;
while (my ($y, $row) = each %$reacheds) {
    while (my ($x, undef) = each %$row) {
        $nof_plots += 1;
    }
}
say $nof_plots;
