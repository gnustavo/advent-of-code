#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;

my @map;
while (<>) {
    chomp;
    push @map, [split ''];
}
my $width = $map[0]->@*;

sub show {
    ddx [map {join '', @$_} @map];
    return;
}

show();

my $min_heat_loss;

my %dirs = (
    '^' => [-1, 0, 'v'],
    '>' => [0, +1, '<'],
    'v' => [+1, 0, '^'],
    '<' => [0, -1, '>'],
);

sub walk {
    my ($y, $x, $direction, $times, $heat_loss, $n) = @_;

    return if $times > 3;

    return if ($y < 0) || ($y == @map) || ($x < 0) || ($x == $width);

    return if $map[$y][$x] =~ /\D/; # already passed here

    $heat_loss += $map[$y][$x];

    return if defined $min_heat_loss && $heat_loss >= $min_heat_loss;

    if ($y == $#map && $x == $width-1) {
        # Reached destination
        $min_heat_loss = $heat_loss;
        say "= $min_heat_loss";
        #say "destination($y, $x, $min_heat_loss)";
        #show();
        return;
    }

    local($map[$y][$x]) = $direction;   # mark that we've already passed here

    #printf "%5d:%*s\n", $heat_loss, $n, '>';

    foreach my $dir (keys %dirs) {
        unless ($dir eq $dirs{$direction}[2]) { # can't go back
            if ($n == 8) {
                say "  $y $x $heat_loss $min_heat_loss $dir";
            }
            walk(
                $y + $dirs{$dir}[0],
                $x + $dirs{$dir}[1],
                $dir,
                ($dir eq $direction ? $times+1 : 1),
                $heat_loss,
                $n+1,
            );
        }
    }

    #printf "%5d:%*s\n", $heat_loss, $n, '<';

    return;
}

walk(0, 1, '>' => 1, 0, 0);
walk(1, 0, 'v' => 1, 0, 0);

say $min_heat_loss;
