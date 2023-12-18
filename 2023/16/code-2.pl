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

sub beam {
    my ($y, $x, $dy, $dx, $cache, $energizeds) = @_;

    return if $y < 0 || $y == @layout || $x < 0 || $x == $width;

    if (! exists $cache->{$y}{$x}) {
        $$energizeds += 1;
    } elsif (exists $cache->{$y}{$x}{$dy}{$dx}) {
        # We've already have come here from the same direction, which means that
        # we're in a loop.  There's no point in keep looping.
        return;
    }
    $cache->{$y}{$x}{$dy}{$dx} = 1;

    my $char = $layout[$y][$x];

    if ($char eq '.') {
        beam($y+$dy, $x+$dx, $dy, $dx, $cache, $energizeds);
    } elsif ($char eq '\\') {
        if ($dy != 0) {
            beam($y, $x+$dy, 0, $dy, $cache, $energizeds);
        } else {
            beam($y+$dx, $x, $dx, 0, $cache, $energizeds);
        }
    } elsif ($char eq '/') {
        if ($dy != 0) {
            beam($y, $x-$dy, 0, -$dy, $cache, $energizeds);
        } else {
            beam($y-$dx, $x, -$dx, 0, $cache, $energizeds);
        }
    } elsif ($char eq '|') {
        if ($dy != 0) {
            beam($y+$dy, $x, $dy, 0, $cache, $energizeds);
        } else {
            beam($y-1, $x, -1, 0, $cache, $energizeds);
            beam($y+1, $x, +1, 0, $cache, $energizeds);
        }
    } elsif ($char eq '-') {
        if ($dx != 0) {
            beam($y, $x+$dx, 0, $dx, $cache, $energizeds);
        } else {
            beam($y, $x-1, 0, -1, $cache, $energizeds);
            beam($y, $x+1, 0, +1, $cache, $energizeds);
        }
    }

    return;
}

my $max_energizeds = 0;

for (my $x=0; $x < $width; ++$x) {
    my $energizeds;

    $energizeds = 0;
    beam(0,        $x, +1, 0, {}, \$energizeds);
    $max_energizeds = $energizeds if $energizeds > $max_energizeds;

    $energizeds = 0;
    beam($#layout, $x, -1, 0, {}, \$energizeds);
    $max_energizeds = $energizeds if $energizeds > $max_energizeds;
}

for (my $y=0; $y < @layout; ++$y) {
    my $energizeds;

    $energizeds = 0;
    beam($y,        0, 0, +1, {}, \$energizeds);
    $max_energizeds = $energizeds if $energizeds > $max_energizeds;

    $energizeds = 0;
    beam($y, $width-1, 0, -1, {}, \$energizeds);
    $max_energizeds = $energizeds if $energizeds > $max_energizeds;
}

say $max_energizeds;
