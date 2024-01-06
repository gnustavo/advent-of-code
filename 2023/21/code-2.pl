#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;
use List::Util qw(sum0);

my @steps = (6, 10, 50, 100, 500, 1000, 5000, 26501365);

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

#ddx \%rocks, $height, $width, $y0, $x0;

my $reacheds = {$y0 => {$x0 => 'O'}};

sub nof_plots {
    my $nof_plots = 0;
    while (my ($y, $row) = each %$reacheds) {
        while (my ($x, undef) = each %$row) {
            $nof_plots += 1;
        }
    }
    return $nof_plots;
}

for (my $i=0; @steps; ++$i) {
    if ($i == $steps[0]) {
        my $n = nof_plots();
        say "$n after $i steps";
        shift @steps;
    }

    my %new_reacheds = ();
    while (my ($y, $row) = each %$reacheds) {
        while (my ($x, undef) = each %$row) {
            foreach my $dir ([-1, 0], [+1, 0], [0, -1], [0, +1]) {
                my ($dy, $dx) = @$dir;
                my $new_y = $y + $dy;
                my $new_x = $x + $dx;
                next if exists $rocks{$new_y % $height}{$new_x % $width};
                $new_reacheds{$new_y}{$new_x} = 'O';
            }
        }
    }
    $reacheds = \%new_reacheds;
}
