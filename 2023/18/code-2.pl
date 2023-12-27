#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;

my @directions = (qw/R D L U/);

my @ops;
while (<>) {
    chomp;
    my ($direction, $meters, $color) = split ' ';
    if ($color =~ /\(\#([0-9a-f]{5})([0-9a-f])\)/) {
        push @ops, [$directions[$2], eval "0x$1"];
    }
}

ddx @ops;

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

my %terrain;

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
        $terrain{$y}{$x} = $marks{$prev_dir}{$dir};
        $prev_dir = $dir;
        my ($dy, $dx) = $vectors{$op->[0]}->@*;
        ddx $op, $y, $x, $dy, $dx;
        if ($dy) {
            while ($meters--) {
                $y += $dy;
                $terrain{$y}{$x} = '|'
                    unless $y == $y0 && $x == $x0;
            }
        } else {
            $x += $dx * $meters;
        }
    }
}

#ddx \%terrain;

# Calculate the lagoon area
my %transitions = (
    out => {
        '|' => 'entering',
        'F' => 'outF',
        'L' => 'outL',
    },
    entering => {
        '|' => 'leaving',
        'F' => 'inF',
        'L' => 'inL',
    },
    leaving => {
        '|' => 'entering',
        'F' => 'outF',
        'L' => 'outL',
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

warn scalar(keys %terrain), "lines to check\n";

foreach my $y (sort {$a <=> $b} keys %terrain) {
    my $status = 'leaving';
    my $last_out_x;
    my $row = $terrain{$y};
    foreach my $x (sort {$a <=> $b} keys %$row) {
        if ($status eq 'leaving') {
            $last_out_x = $x - 1;
        }
        $status = $transitions{$status}{$terrain{$y}{$x}};
        if ($status eq 'leaving') {
            $area += $x - $last_out_x;
        }
    }
}

say $area;
