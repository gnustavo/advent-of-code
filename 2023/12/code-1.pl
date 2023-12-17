#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;

# ???.### 1,1,3
# .??..??...?##. 1,1,3
# ?#?#?#?#?#?#?#? 1,3,1,6
# ????.#...#... 4,1,1
# ????.######..#####. 1,6,5
# ?###???????? 3,2,1

my @records;
while (<>) {
    chomp;
    my ($conditions, $damageds) = split ' ';

    my @conditions;
    my $c;
    my $n;
    foreach (split '', $conditions) {
        if (defined $c) {
            if ($_ eq $c) {
                $n += 1;
            } else {
                push @conditions, [$c, $n];
                $c = $_;
                $n = 1;
            }
        } else {
            $c = $_;
            $n = 1;
        }
    }
    push @conditions, [$c, $n] if defined $c;

    my @damageds = split ',', $damageds;

    push @records, [\@conditions, \@damageds];
}

use Data::Dump;
ddx @records;

sub arrangements {
    my ($state, $conditions, $damageds, $ic, $dc) = @_;

    return 0 if $ic == $conditions->@*;

    my $condition = $conditions->[$ic][0];

    if ($state eq 'start') {
        if ($condition eq '.') {
            if ($ic+1 < $conditions->@*) {
                return arrangements(".->$conditions->[$ic+1][0]", $conditions, $damageds, $ic+1, $dc);
            } else {
                return 0;
            }
        }
        return arrangements(".->$condition" => $conditions, $damageds, $ic, $dc);
    } elsif ($state eq '.->#') {
        # FIXME
    }
}

my $sum = 0;

foreach (@records) {
    $sum += arrangements(start => $_->[0], $_->[1], 0, 0);
}

say $sum;
