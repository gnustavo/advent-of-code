#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;

my @layout;
while (<>) {
    chomp;
    push @layout, [split ''];
}

my $width = $layout[0]->@*;

my %energizeds;
my $energizeds = 0;

sub beam {
    my ($y, $x, $dy, $dx) = @_;

    return if $y < 0 || $y == @layout || $x < 0 || $x == $width;

    if (! exists $energizeds{$y}{$x}) {
        $energizeds += 1;
    } elsif (exists $energizeds{$y}{$x}{$dy}{$dx}) {
        # We've already have come here from the same direction, which means that
        # we're in a loop.  There's no point in keep looping.
        return;
    }
    $energizeds{$y}{$x}{$dy}{$dx} = 1;

    my $char = $layout[$y][$x];

    if ($char eq '.') {
        beam($y+$dy, $x+$dx, $dy, $dx);
    } elsif ($char eq '\\') {
        if ($dy != 0) {
            beam($y, $x+$dy, 0, $dy);
        } else {
            beam($y+$dx, $x, $dx, 0);
        }
    } elsif ($char eq '/') {
        if ($dy != 0) {
            beam($y, $x-$dy, 0, -$dy);
        } else {
            beam($y-$dx, $x, -$dx, 0);
        }
    } elsif ($char eq '|') {
        if ($dy != 0) {
            beam($y+$dy, $x, $dy, 0);
        } else {
            beam($y-1, $x, -1, 0);
            beam($y+1, $x, +1, 0);
        }
    } elsif ($char eq '-') {
        if ($dx != 0) {
            beam($y, $x+$dx, 0, $dx);
        } else {
            beam($y, $x-1, 0, -1);
            beam($y, $x+1, 0, +1);
        }
    }

    return;
}

beam(0, 0, 0, +1);

say $energizeds;
