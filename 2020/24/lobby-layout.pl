#!/usr/bin/env perl

use 5.030;
use warnings;
use List::AllUtils qw(true);

chomp(my @input = <>);

my %moves = (
    e  => [+2,  0],
    ne => [+1, +1],
    nw => [-1, +1],
    se => [+1, -1],
    sw => [-1, -1],
    w  => [-2,  0],
);

my @steps = map {[/(e|ne|nw|se|sw|w)/g]} @input;

my %floor;

foreach my $steps (@input) {
    my ($x, $y) = (0, 0);
    foreach my $step ($steps =~ /(e|ne|nw|se|sw|w)/g) {
        my $move = $moves{$step};
        $x += $move->[0];
        $y += $move->[1];
    }
    $floor{$x}{$y} = ! $floor{$x}{$y};
}

sub show {
    my ($day) = @_;
    say "Day $day: ", scalar true {$_} map {values %$_} values %floor;
}

show(0);

for my $day (1 .. 100) {
    # Create white tiles around black tiles
    my @whites;
    while (my ($x, $ys) = each %floor) {
        while (my ($y, $tile) = each %$ys) {
            if ($tile) {        # is black
                foreach my $move (values %moves) {
                    my ($dx, $dy) = @$move;
                    push @whites, [$x + $dx, $y + $dy]
                        unless exists $floor{$x + $dx} and exists $floor{$x + $dx}{$y + $dy};
                }
            }
        }
    }
    foreach my $white (@whites) {
        my ($x, $y) = @$white;
        $floor{$x}{$y} = '';
    }

    # Apply rules to see which tiles need to be flipped
    my @flips;
    while (my ($x, $ys) = each %floor) {
        while (my ($y, $tile) = each %$ys) {
            my $black_adjacents = 0;
            foreach my $move (values %moves) {
                my ($dx, $dy) = @$move;
                $black_adjacents += 1
                    if exists $floor{$x + $dx} && exists $floor{$x + $dx}{$y + $dy} && $floor{$x + $dx}{$y + $dy};
            }
            if ($tile) {
                # black
                push @flips, [$x, $y] if $black_adjacents == 0 || $black_adjacents > 2;
            } else {
                #white
                push @flips, [$x, $y] if $black_adjacents == 2;
            }
        }
    }

    # Flip them
    foreach my $flip (@flips) {
        my ($x, $y) = @$flip;
        $floor{$x}{$y} = ! $floor{$x}{$y};
    }

    show($day);
}
