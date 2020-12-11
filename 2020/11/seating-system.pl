#!/usr/bin/env perl

use 5.030;
use warnings;

my @input = <>;
chomp @input;

sub seats {
    my ($sentinel) = @_;
    my @seats = ([($sentinel) x (@input+2)]);
    push @seats, map {[$sentinel, split(//, $_), $sentinel]} @input;
    push @seats, $seats[0];
    return (\@seats, scalar(@input), length($input[0]));
}

sub lookup_neighbor {
    my ($seats, $row, $col, $dr, $dc) = @_;
    return $seats->[$row+$dr][$col+$dc];
}

sub lookup_seen {
    my ($seats, $row, $col, $dr, $dc) = @_;
    while (1) {
        $row += $dr;
        $col += $dc;
        last if $seats->[$row][$col] ne '.';
    }
    return $seats->[$row][$col];
}

sub how_many_seated {
    my ($lookup, $sentinel, $adjacents) = @_;

    my ($seats, $rows, $cols) = seats($sentinel);

    my @changes;
    while (1) {
        for my $row (1 .. $rows) {
            for my $col (1 .. $cols) {
                my $seat = \$seats->[$row][$col];
                next if $$seat eq '.';
                my $occupied = 0;
                for my $dr (-1, 0, +1) {
                    for my $dc (-1, 0, +1) {
                        next if $dr == 0 && $dc == 0;
                        $occupied += 1
                            if $lookup->($seats, $row, $col, $dr, $dc) eq '#';
                    }
                }
                push @changes, $seat
                    if ($$seat eq 'L' && $occupied == 0) || ($$seat eq '#' && $occupied >= $adjacents);
            }
        }
        last unless @changes;
        while (my $seat = shift @changes) {
            $$seat = $$seat eq 'L' ? '#' : 'L';
        }
    }

    my $occupied = 0;
    foreach my $row (@$seats) {
        $occupied += grep {$_ eq '#'} @$row;
    }
    return $occupied;
}

say how_many_seated(\&lookup_neighbor, '.', 4);
say how_many_seated(\&lookup_seen,     'L', 5);
