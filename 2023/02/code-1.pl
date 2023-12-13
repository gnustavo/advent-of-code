#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;

my %games;

while (<>) {
    if (my ($id, $sets) = (/^Game\s+(\d+):\s*(.*)/)) {
        foreach my $set (split ';', $sets) {
            my %set;
            foreach my $balls_color (split ',', $set) {
                my ($balls, $color) = split ' ', $balls_color;
                $set{$color} = $balls;
            }
            push $games{$id}->@*, \%set;
        }
    }
}

#use Data::Dump;
#ddx \%games;

my %limits = (
    red   => 12,
    green => 13,
    blue  => 14,
);

my $sum = 0;

GAME:
while (my ($id, $game) = each %games) {
    foreach my $set (@$game) {
        while (my ($color, $balls) = each %$set) {
            next GAME if ! exists $limits{$color} || $balls > $limits{$color};
        }
    }
    $sum += $id;
}

say $sum;
