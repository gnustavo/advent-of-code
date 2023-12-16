#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;

my @grid;
while (<>) {
    chomp;
    push @grid, ['.', split(''), '.'];
}
unshift @grid, [('.') x $grid[0]->@*];
push    @grid, [('.') x $grid[0]->@*];

# Each pipe is represented by a function which receives two two-dimensional
# vectors and returns two two-dimentional vectors. The first argument is the
# current position in the grid. The second argument is the unitary vector
# representing the direction from which the current pipe was reached. The first
# resulting vector is the next position. The second resulting vector is the next
# direction. If the pipe can't be entered from the original direction, the
# function returns an empty list.
my %pipes = (
    '|' => sub {
        return $_[1][1] ? ([$_[0][0], $_[0][1] + $_[1][1]], $_[1]) : ();
    },
    '-' => sub {
        return $_[1][0] ? ([$_[0][0] + $_[1][0], $_[0][1]], $_[1]) : ();
    },
    'L' => sub {
        if ($_[1][0] == -1) {
            return ([$_[0][0], $_[0][1] - 1], [0, -1]);
        } elsif ($_[1][1] == +1) {
            return ([$_[0][0] + 1, $_[0][1]], [+1, 0]);
        } else {
            return ();
        }
    },
    'J' => sub {
        if ($_[1][0] == +1) {
            return ([$_[0][0], $_[0][1] - 1], [0, -1]);
        } elsif ($_[1][1] == +1) {
            return ([$_[0][0] - 1, $_[0][1]], [-1, 0]);
        } else {
            return ();
        }
    },
    '7' => sub {
        if ($_[1][0] == +1) {
            return ([$_[0][0], $_[0][1] + 1], [0, +1]);
        } elsif ($_[1][1] == -1) {
            return ([$_[0][0] - 1, $_[0][1]], [-1, 0]);
        } else {
            return ();
        }
    },
    'F' => sub {
        if ($_[1][0] == -1) {
            return ([$_[0][0], $_[0][1] + 1], [0, +1]);
        } elsif ($_[1][1] == -1) {
            return ([$_[0][0] + 1, $_[0][1]], [+1, 0]);
        } else {
            return ();
        }
    },
    '.' => sub {
        return ();
    },
    'S' => sub {
        return ();
    }
);

# Find S's position
my $S;
POSITION:
while (my ($y, $row) = each @grid) {
    while (my ($x, $char) = each $row->@*) {
        if ($char eq 'S') {
            $S = [$x, $y];
            last POSITION;
        }
    }
}

# Find one initial valid direction
my $dir;
DIRECTION:
for my $d ([-1, 0], [0, +1], [+1, 0], [0, -1]) {
    if ($pipes{$grid[$S->[1]+$d->[1]][$S->[0]+$d->[0]]}->([$S->[1]+$d->[1], $S->[0]+$d->[0]], [$d->[0], $d->[1]])) {
        $dir = [$d->[0], $d->[1]];
        last DIRECTION;
    }
}

my $pos = [$S->[0]+$dir->[0], $S->[1]+$dir->[1]];

my $cycle_length = 1;

while ($pos->[0] != $S->[0] || $pos->[1] != $S->[1]) {
    ($pos, $dir) = $pipes{$grid[$pos->[1]][$pos->[0]]}->($pos, $dir);
    $cycle_length += 1;
}

say $cycle_length / 2;
