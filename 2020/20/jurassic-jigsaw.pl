#!/usr/bin/env perl

use 5.030;
use warnings;
no warnings 'recursion';
use List::AllUtils qw(sum0);

my %tiles;
{
    local $/ = '';
    while (<>) {
        my ($id, $lines) = /Tile (\d+):\n(.+)/s;
        my @lines = split /\n/, $lines;
        die "I expected tiles to be 10x10 but tile $id has more lines"
            unless @lines == 10;
        die "I expected tiles to be 10x10 but tile $id has more columns"
            unless length($lines[0]) == 10;
        my @sides = (
            $lines[0],                                # up
            join('', map {substr($_, -1, 1)} @lines), # right
            $lines[-1],                               # down
            join('', map {substr($_,  0, 1)} @lines), # left
        );
        push @sides, map {scalar reverse} @sides;
        $tiles{$id} = {
            id => $id,
            lines => \@lines,
            sides => \@sides,
        };
    }
};

my $size = sqrt(keys %tiles);
die "There should be a square number of tiles, not $size"
    unless $size == int($size);

my @board;
for my $i (0 .. $size) {
    for my $j (0 .. $size) {
        $board[$i][$j] = undef;
    }
}

my @all_side_options = (
    [0, 0],
    [0, 1],
    [0, 2],
    [0, 3],
    [1, 0],
    [1, 1],
    [1, 2],
    [1, 3],
);

sub fit_board {
    my %pile = %tiles;

    my $try = sub {
        my ($i, $j) = @_;
        #say "try($i, $j)";
        return 1 if $i == $size && $j == 0;
        my @fits = do {
            if ($i == 0 && $j == 0) {
                sort {$a->[0]{id} <=> $b->[0]{id}}
                map {my $t = $_; map {[$t, $_]} @all_side_options} values %pile;
            } elsif ($i == 0) {
                my $side = side($board[$i][$j-1], 1);
                map {fit_left($_, $side)} values %pile;
            } elsif ($j == 0) {
                my $side = side($board[$i-1][$j], 2);
                map {fit_up($_, $side)} values %pile;
            } else {
                my $up_side   = side($board[$i-1][$j], 2);
                my $left_side = side($board[$i][$j-1], 1);
                map {fit_up_left($_, $up_side, $left_side)} values %pile;
            }
        };
        my ($next_i, $next_j) = ($i, $j + 1);
        if ($next_j == $size) {
            $next_j = 0;
            $next_i += 1;
        }
        foreach my $fit (@fits) {
            delete local $pile{$fit->[0]{id}};
            $board[$i][$j] = $fit;
            #say "  try($i, $j) = $fit->[0]{id} $fit->[1][0] $fit->[1][1] ", side($fit, 0);
            return 1 if __SUB__->($next_i, $next_j);
        }
        #say "bak($i, $j)";
        return 0;
    };

    my $matches = $try->(0, 0);

    die "Do not match!" unless $matches;
}

my %match_face_rot = (
    up => [
        [0, 0],
        [0, 1],
        [1, 2],
        [1, 1],
        [1, 0],
        [1, 3],
        [0, 2],
        [0, 3],
    ],
    left => [
        [1, 1],
        [1, 0],
        [0, 3],
        [0, 0],
        [0, 1],
        [0, 2],
        [1, 3],
        [1, 2],
    ],
);

sub fit_up {
    my ($tile, $side) = @_;

    return map {[$tile, $match_face_rot{up}[$_]]} grep {$tile->{sides}[$_] eq $side} 0 .. 7;
}

sub fit_left {
    my ($tile, $side) = @_;

    return map {[$tile, $match_face_rot{left}[$_]]} grep {$tile->{sides}[$_] eq $side} 0 .. 7;
}

sub fit_up_left {
    my ($tile, $up, $left) = @_;

    my @match_up   = map {$match_face_rot{up}[$_]}   grep {$tile->{sides}[$_] eq $up}   0 .. 7;
    return unless @match_up;

    my @match_left = map {$match_face_rot{left}[$_]} grep {$tile->{sides}[$_] eq $left} 0 .. 7;
    return unless @match_left;

    my @match;
    foreach my $up (@match_up) {
        foreach my $left (@match_left) {
            push @match, [$tile, $up] if $up->[0] == $left->[0] && $up->[1] == $left->[1];
        }
    }

    return @match;
}

sub side {
    my ($fit, $side) = @_;

    state $table = [
        [
            [  0,   1,   2,   3], # 0 0
            [  1, 4+2,   3, 4+0], # 0 1
            [4+2, 4+3, 4+0, 4+1], # 0 2
            [4+3,   0, 4+1,   2], # 0 3
        ],
        [
            [4+0,   3, 4+2,   1], # 1 0
            [  3,   2,   1,   0], # 1 1
            [  2, 4+1,   0, 4+3], # 1 2
            [4+1, 4+0, 4+3, 4+2], # 1 3
        ],
    ];

    return $fit->[0]{sides}[$table->[$fit->[1][0]][$fit->[1][1]][$side]];
}

fit_board();

say "One = ", $board[0][0][0]{id} * $board[0][$size-1][0]{id} * $board[$size-1][0][0]{id} * $board[$size-1][$size-1][0]{id};

sub fit_lines {
    my ($fit) = @_;
    my @lines = $fit->[1][0]
        ? map {scalar reverse substr($_, 1, 8)} @{$fit->[0]{lines}}[1 .. 8]
        : map {substr($_, 1, 8)} @{$fit->[0]{lines}}[1 .. 8];
    my $rot = $fit->[1][1];
    if ($rot == 1) {
        @lines = map {my $i=7-$_; join('', map {substr($lines[$_], $i, 1)} 0 .. 7)} 0 .. 7;
    } elsif ($rot == 2) {
        @lines = reverse map {scalar reverse $_} @lines;
    } elsif ($rot == 3) {
        @lines = map {my $i=$_; join('', map {substr($lines[7-$_], $i, 1)} 0 .. 7)} 0 .. 7;
    }
    return @lines;
}

my @image;

for my $i (0 .. $size - 1) {
    for my $j (0 .. $size - 1) {
        my @lines = fit_lines($board[$i][$j]);
        for my $k (0 .. $#lines) {
            $image[$i*8+$k] .= $lines[$k];
        }
    }
}

sub rot90 {
    my ($image) = @_;

    return [map {my $i=$#image-$_; join('', map {substr($image->[$_], $i, 1)} 0 .. $#image)} 0 .. $#image];
}

sub flip {
    my ($image) = @_;

    return [map {scalar reverse} @$image];
}

sub find_monsters {
    my ($image) = @_;

    state $m1 = qr'^..................#.';
    state $m2 = qr'^#....##....##....###';
    state $m3 =  qr'.#..#..#..#..#..#...';

    my @monsters;

    for my $lin (2 .. $#$image) {
        my $third_line = $image->[$lin];
        while ($third_line =~ /$m3/g) {
            my $col = $-[0];
            if (substr($image->[$lin-1], $col) =~ /$m2/ && substr($image->[$lin-2], $col) =~ /$m1/) {
                push @monsters, [$lin-2, $col];
            } else {
                pos($third_line) = $col+1;
            }
        }
    }

    return @monsters;
}

my @monsters;
IMAGE:
for my $image (\@image, flip(\@image)) {
    for my $rot (0 .. 3) {
        say "looking at $image $rot";
        if (@monsters = find_monsters($image)) {
            last IMAGE;
        }
    } continue {
        $image = rot90($image);
    }
}

my $hashes_in_image = sum0 map {tr/\#/\#/} @image;
my $hashes_in_monster = 15;

say "TWO [$hashes_in_image] = ", ($hashes_in_image - scalar(@monsters) * $hashes_in_monster);
