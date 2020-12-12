#!/usr/bin/env perl

use 5.030;
use warnings;

my @instructions = map {[/([NSEWLRF])(\d+)/]} <>;

# https://en.wikipedia.org/wiki/Rotation_matrix
sub rotate {
    my ($vector, $angle) = @_;
    state $rotation = {
        0   => [ 1,  0,  1,  0],
        90  => [ 0, -1,  1,  0],
        180 => [-1,  0,  0, -1],
        270 => [ 0,  1, -1,  0],
    };
    my $r = $rotation->{$angle};
    @$vector = (
        $vector->[0] * $r->[0] + $vector->[1] * $r->[1],
        $vector->[0] * $r->[2] + $vector->[1] * $r->[3],
    );
}

sub one {
    my @pos = (0, 0);
    my @dir = (1, 0);

    my %code = (
        N => sub { $pos[1] += $_[0] },
        S => sub { $pos[1] -= $_[0] },
        E => sub { $pos[0] += $_[0] },
        W => sub { $pos[0] -= $_[0] },
        L => sub { rotate(\@dir, $_[0]) },
        R => sub { rotate(\@dir, (360 - $_[0]) % 360) },
        F => sub { @pos = ($pos[0] + $dir[0] * $_[0], $pos[1] + $dir[1] * $_[0]) },
    );

    foreach my $i (@instructions) {
        $code{$i->[0]}($i->[1]);
        #say "$i->[0]$i->[1] ($pos[0], $pos[1]) ($dir[0], $dir[1])";
    }

    return abs($pos[0]) + abs($pos[1]);
}

sub two {
    my @pos = (0, 0);
    my @wp = (10, 1);

    my %code = (
        N => sub { $wp[1] += $_[0] },
        S => sub { $wp[1] -= $_[0] },
        E => sub { $wp[0] += $_[0] },
        W => sub { $wp[0] -= $_[0] },
        L => sub { rotate(\@wp, $_[0]) },
        R => sub { rotate(\@wp, (360 - $_[0]) % 360) },
        F => sub { @pos = ($pos[0] + $wp[0] * $_[0], $pos[1] + $wp[1] * $_[0]) },
    );

    foreach my $i (@instructions) {
        $code{$i->[0]}($i->[1]);
        #say "$i->[0]$i->[1] ($pos[0], $pos[1]) ($wp[0], $wp[1])";
    }

    return abs($pos[0]) + abs($pos[1]);
}

say one();
say two();
