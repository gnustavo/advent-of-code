#!/usr/bin/env perl

use 5.030;
use warnings;
use List::AllUtils qw(minmax);

chomp(my @input = <>);

say one();
say two();

sub one {
    my $actives;
    for my $x (0 .. $#input) {
        for my $y (0 .. length($input[0])-1) {
            $actives->{$x}{$y}{0} = 1 if substr($input[$x], $y, 1) eq '#';
        }
    }

    #show3(0, $actives);
    for my $gen (1 .. 6) {
        my %neighbours;
        while (my ($x, $ys) = each %$actives) {
            while (my ($y, $zs) = each %$ys) {
                while (my ($z, $value) = each %$zs) {
                    for my $i (-1, 0, 1) {
                        for my $j (-1, 0, 1) {
                            for my $k (-1, 0, 1) {
                                $neighbours{$x+$i}{$y+$j}{$z+$k} += 1;
                            }
                        }
                    }
                    if (--$neighbours{$x}{$y}{$z} == 0) {
                        delete $neighbours{$x}{$y}{$z};
                    }
                }
            }
        }
        my %new;
        while (my ($x, $ys) = each %neighbours) {
            while (my ($y, $zs) = each %$ys) {
                while (my ($z, $value) = each %$zs) {
                    if ($value == 3 || $value == 2 && exists $actives->{$x}{$y}{$z}) {
                        $new{$x}{$y}{$z} = 1;
                    }
                }
            }
        }
        $actives = \%new;
        #show3($gen, $actives);
    }

    return scalar map {values %$_} map {values %$_} values %$actives;
}

sub show3 {
    my ($gen, $actives) = @_;

    say "\nCycle $gen:";

    my ($xmin, $xmax) = minmax keys %$actives;
    my ($ymin, $ymax) = minmax map {keys %$_} values %$actives;
    my ($zmin, $zmax) = minmax map {keys %$_} map {values %$_} values %$actives;

    for my $z ($zmin .. $zmax) {
        say "\nz=$z";
        for my $x ($xmin .. $xmax) {
            printf '%2d ', $x;
            for my $y ($ymin .. $ymax) {
                print $actives->{$x}{$y}{$z} ? '#' : '.';
            }
            say '';
        }
    }
}

sub two {
    my $actives;
    for my $x (0 .. $#input) {
        for my $y (0 .. length($input[0])-1) {
            $actives->{$x}{$y}{0}{0} = 1 if substr($input[$x], $y, 1) eq '#';
        }
    }

    for my $gen (1 .. 6) {
        my %neighbours;
        while (my ($x, $ys) = each %$actives) {
            while (my ($y, $zs) = each %$ys) {
                while (my ($z, $ws) = each %$zs) {
                    while (my ($w, $value) = each %$ws) {
                        for my $i (-1, 0, 1) {
                            for my $j (-1, 0, 1) {
                                for my $k (-1, 0, 1) {
                                    for my $l (-1, 0, 1) {
                                        $neighbours{$x+$i}{$y+$j}{$z+$k}{$w+$l} += 1;
                                    }
                                }
                            }
                        }
                        if (--$neighbours{$x}{$y}{$z}{$w} == 0) {
                            delete $neighbours{$x}{$y}{$z}{$w};
                        }
                    }
                }
            }
        }
        my %new;
        while (my ($x, $ys) = each %neighbours) {
            while (my ($y, $zs) = each %$ys) {
                while (my ($z, $ws) = each %$zs) {
                    while (my ($w, $value) = each %$ws) {
                        if ($value == 3 || $value == 2 && exists $actives->{$x}{$y}{$z}{$w}) {
                            $new{$x}{$y}{$z}{$w} = 1;
                        }
                    }
                }
            }
        }
        $actives = \%new;
    }

    return scalar map {values %$_} map {values %$_} map {values %$_} values %$actives;
}
