#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use List::Util qw(product sum0);

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

my @products;

GAME:
while (my ($id, $game) = each %games) {
    my %minimums;
    foreach my $set (@$game) {
        while (my ($color, $balls) = each %$set) {
            if (! exists $minimums{$color} || $minimums{$color} < $balls) {
                $minimums{$color} = $balls;
            }
        }
    }
    push @products, product(values %minimums)
        if %minimums;
}

say sum0 @products;
