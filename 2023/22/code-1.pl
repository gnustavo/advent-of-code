#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;
use List::Util qw(min max);
use List::MoreUtils qw(binsert);

my @bricks;
while (<>) {
    chomp;
    if (/^(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)/) {
        my @p0 = ($1, $2, $3);
        my @p1 = ($4, $5, $6);
        # keep the brick's points in ascending order of their z's coordinate.
        # The third parameter tells which bricks this one sustains
        # The fourth parameter tells by how many bricks this one is sustained
        my @brick = $p0[2] < $p1[2] ? (\@p0, \@p1, [], 0) : (\@p1, \@p0, [], 0);
        push @bricks, \@brick;
        # I'm assuming that the coordinates differ by at most one dimension.
    }
}

# keep bricks sorted by their bottom Z's coordinate in ascending order
@bricks = sort {$a->[0][2] <=> $b->[0][2]} @bricks;

# These are the same bricks after they have fallen. $fallen[0] represents the ground.
my @fallen = ([
    [0, 0, 0],
    [
        max(map {($_->[0][0], $_->[1][0])} @bricks),
        max(map {($_->[0][1], $_->[1][1])} @bricks),
        0
    ],
    [],
    0,
]);

#ddx \@bricks, \@fallen;

sub cross_XY {
    my ($this, $that) = @_;
    return ! (
        max($this->[0][0], $this->[1][0]) < min($that->[0][0], $that->[1][0]) ||
        max($that->[0][0], $that->[1][0]) < min($this->[0][0], $this->[1][0]) ||
        max($this->[0][1], $this->[1][1]) < min($that->[0][1], $that->[1][1]) ||
        max($that->[0][1], $that->[1][1]) < min($this->[0][1], $this->[1][1])
    );
}

# Make the bricks fall but without crossing over each other.
BRICK:
while (my $this = shift @bricks) {
    # Invariant: ($this, @bricks) have yet to fall
    # Invariant: @fallen have already fallen into place

    # Find out the first lower brick, downwards, which crosses the X's or the
    # Y's coordinates with this brick. We're sure to stop at the ground.
    my $has_falled = 0;
    foreach my $lower (reverse @fallen) {
        if (cross_XY($this, $lower)) {
            if ($has_falled) {
                if ($this->[0][2] - $lower->[1][2] == 1) {
                    # Remember that $lower sustains $this
                    push $lower->[2]->@*, $this;
                    # Remember that $this is sustained by another brick
                    $this->[3] += 1;
                } else {
                    # No lower brick can sustain $this
                    next BRICK;
                }
            } else {
                # Their X's or Y's coordinates do cross
                # Make $this fall until it touches $lower
                $this->[1][2] -= $this->[0][2] - $lower->[1][2] - 1;
                $this->[0][2] = $lower->[1][2] + 1;
                # Fallen bricks are kept sorted by their upper Z's coordinate in
                # ascending order
                binsert {$_->[1][2] <=> $this->[1][2]} $this, @fallen;
                # Remember that $lower sustains $this
                push $lower->[2]->@*, $this;
                # Remember that $this is sustained by another brick
                $this->[3] += 1;
                $has_falled = 1;
            }
        }
    }
}

#ddx \@bricks, \@fallen;

shift @fallen;                  # remove the floor
my $nof_disintegratable = 0;
FALLEN:
foreach my $this (@fallen) {
    foreach my $sustained ($this->[2]->@*) {
        next FALLEN if $sustained->[3] == 1;
    }
    $nof_disintegratable += 1;
}
say $nof_disintegratable;
