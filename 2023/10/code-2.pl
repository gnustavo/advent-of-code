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

# Find valid initial directions
my %directions = (
    N => [0, -1],
    L => [+1, 0],
    S => [0, +1],
    W => [-1, 0],
);
my @directions;
DIRECTION:
foreach my $name (qw/N L S W/) {
    my $d = $directions{$name};
    if ($pipes{$grid[$S->[1]+$d->[1]][$S->[0]+$d->[0]]}->([$S->[1]+$d->[1], $S->[0]+$d->[0]], [$d->[0], $d->[1]])) {
        push @directions, [$name, $d];
    }
}

# Select initial direction
my $dir = $directions[0][1];

# Select initial position
my $pos = [$S->[0]+$dir->[0], $S->[1]+$dir->[1]];

# Mark the cycle in a new grid
my @cycle_grid = map {[('.') x $grid[0]->@*]} 0 .. $#grid;
while ($pos->[0] != $S->[0] || $pos->[1] != $S->[1]) {
    my $char = $grid[$pos->[1]][$pos->[0]];
    $cycle_grid[$pos->[1]][$pos->[0]] = $char;
    ($pos, $dir) = $pipes{$char}->($pos, $dir);
}

# Mark the start position
$cycle_grid[$S->[1]][$S->[0]] = {
    N => {
        L => 'L',
        S => '|',
        W => 'J',
    },
    L => {
        S => 'F',
        W => '-',
    },
    S => {
        W => '7',
    },
}->{$directions[0][0]}{$directions[1][0]};
#say "S($S->[1], $S->[0])='$cycle_grid[$S->[1]][$S->[0]]'";

# Calculate the area using the ray casting algorithm

# A state-machine mapping (status, char) => (area, next-status)
my %algorithm = (
    'outside' => {
        '.' => [0, 'outside'],
        '|' => [0, 'entering'],
        'L' => [0, 'outside-L'],
        'F' => [0, 'outside-F'],
    },
    'inside' => {
        '.' => [1, 'inside'],
        '|' => [0, 'leaving'],
        'L' => [0, 'inside-L'],
        'F' => [0, 'inside-F'],
    },
    'entering' => {
        '.' => [1, 'inside'],
        '|' => [0, 'leaving'],
        'L' => [0, 'inside-L'],
        'F' => [0, 'inside-F'],
    },
    'leaving' => {
        '.' => [0, 'outside'],
        '|' => [0, 'entering'],
        'L' => [0, 'outside-L'],
        'F' => [0, 'outside-F'],
    },
    'outside-L' => {
        '-' => [0, 'outside-L'],
        'J' => [0, 'leaving'],
        '7' => [0, 'entering'],
    },
    'outside-F' => {
        '-' => [0, 'outside-F'],
        'J' => [0, 'entering'],
        '7' => [0, 'leaving'],
    },
    'inside-L' => {
        '-' => [0, 'inside-L'],
        'J' => [0, 'entering'],
        '7' => [0, 'leaving'],
    },
    'inside-F' => {
        '-' => [0, 'inside-F'],
        'J' => [0, 'leaving'],
        '7' => [0, 'entering'],
    },
);

my $area = 0;

while (my ($y, $row) = each @cycle_grid) {
    my $status = 'outside';
    while (my ($x, $char) = each $row->@*) {
        my $next = $algorithm{$status}{$char};
        if (! defined $next) {
            warn "Undefined: $status, $x, $y, $char\n";
        } elsif ($next->[0]) {
            #say "count ($y, $x) '$char': $status => $next->[1]";
        }
        $area += $next->[0];
        $status = $next->[1];
    }
}

say $area;
