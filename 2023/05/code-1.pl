#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use List::Util qw(min);

my (@seeds, @maps, $map);

while (<>) {
    if (/^seeds: ([\d\s]+)/) {
        @seeds = split ' ', $1;
    } elsif (/([\w-])\s+map:/) {
        push @maps, $map if defined $map;
        $map = undef;
    } elsif (my ($destin, $origin, $length) = (/(\d+) (\d+) (\d+)/)) {
        push @$map, {
            destin => $destin,
            origin => $origin,
            length => $length,
        };
    }
}
push @maps, $map if defined $map;

use Data::Dump;
#ddx \@seeds, \@maps;

my @locations;
foreach my $number (@seeds) {
  MAP:
    foreach my $map (@maps) {
        foreach my $range (@$map) {
            if (($number >= $range->{origin}) && ($number < ($range->{origin} + $range->{length}))) {
                $number = $range->{destin} + ($number - $range->{origin});
                next MAP;
            }
        }
    }
    push @locations, $number;
}

#ddx \@locations;

say min @locations;
