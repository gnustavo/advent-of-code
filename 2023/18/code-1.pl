#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;

my @ops;
while (<>) {
    chomp;
    my ($direction, $meters, $color) = split ' ';
    push @ops, [$direction, $meters, $color];
}

my %vectors = (
    U => [-1, 0],
    D => [+1, 0],
    L => [0, -1],
    R => [0, +1],
);

# Let's calculate the height and the width of the terrain, and its initial
# position.
my ($y0, $x0, $height, $width) = do {
    my ($y, $ymin, $ymax, $x, $xmin, $xmax) = (0, 0, 0, 0, 0, 0);
    foreach my $op (@ops) {
        my ($dir, $meters) = @$op;
        if ($dir eq 'U') {
            $y -= $meters;
            $ymin = $y if $y < $ymin;
        } elsif ($dir eq 'D') {
            $y += $meters;
            $ymax = $y if $y > $ymax;
        } elsif ($dir eq 'L') {
            $x -= $meters;
            $xmin = $x if $x < $xmin;
        } elsif ($dir eq 'R') {
            $x += $meters;
            $xmax = $x if $x > $xmax;
        }
    }
    (-$ymin, -$xmin, $ymax - $ymin + 1, $xmax - $xmin + 1);
};

ddx $y0, $x0, $height, $width;

my @terrain;
push @terrain, [('.') x $width] for 1 .. $height;

sub show {
    ddx map {join '', @$_} @terrain;
}

show;

# We mark the terrain with signs showing how the curve goes.
my %marks = (
    U => {
        U => '|',
        L => '7',
        R => 'F',
    },
    D => {
        D => '|',
        L => 'J',
        R => 'L',
    },
    L => {
        L => '-',
        U => 'L',
        D => 'F',
    },
    R => {
        R => '-',
        U => 'J',
        D => '7',
    },
);

# Mark the terrain
{
    my ($y, $x) = ($y0, $x0);
    my $prev_dir = $ops[-1][0];
    foreach my $op (@ops) {
        my ($dir, $meters, undef) = @$op;
        $terrain[$y][$x] = $marks{$prev_dir}{$dir};
        $prev_dir = $dir;
        my ($dy, $dx) = $vectors{$op->[0]}->@*;
        if ($dy) {
            while ($meters--) {
                $y += $dy;
                $terrain[$y][$x] = '|'
                    unless $y == $y0 && $x == $x0;
            }
        } else {
            while ($meters--) {
                $x += $dx;
                $terrain[$y][$x] = '-'
                    unless $y == $y0 && $x == $x0;
            }
        }
    }
}

show;

# Calculate the lagoon area
my %transitions = (
    out => {
        '|' => 'entering',
        'F' => 'outF',
        'L' => 'outL',
    },
    in => {
        '|' => 'leaving',
        'F' => 'inF',
        'L' => 'inL',
    },
    entering => {
        '|' => 'leaving',
        'F' => 'inF',
        'L' => 'inL',
        '.' => 'in',
    },
    leaving => {
        '|' => 'entering',
        'F' => 'outF',
        'L' => 'outL',
        '.' => 'out',
    },
    outF => {
        '7' => 'leaving',
        'J' => 'entering',
    },
    outL => {
        '7' => 'entering',
        'J' => 'leaving',
    },
    inF => {
        '7' => 'entering',
        'J' => 'leaving',
    },
    inL => {
        '7' => 'leaving',
        'J' => 'entering',
    },
);
my $area = 0;
for (my $y=0; $y < $height; ++$y) {
    my $status = 'out';
    for (my $x=0; $x < $width; ++$x) {
        my $mark = $terrain[$y][$x];
        if (exists $transitions{$status}{$mark}) {
            $status = $transitions{$status}{$mark};
        }
        $area += 1 unless $status eq 'out';
        #ddx $y, $x, $status, $area;
    }
}

say $area;
