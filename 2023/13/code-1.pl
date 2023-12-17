#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;

my @patterns = ({rows => [], cols => []});
while (<>) {
    chomp;
    if (length) {
        push $patterns[-1]{rows}->@*, $_;
    } else {
        push @patterns, {rows => [], cols => []};
    }
}

# Calculate the columns
foreach my $pattern (@patterns) {
    my $rows = $pattern->{rows};
    my $cols = $pattern->{cols};
    for (my $i=0; $i < length $rows->[0]; ++$i) {
        push @$cols, join('', map {substr($_, $i, 1)} @$rows);
    }
}

use Data::Dump;
#ddx \@patterns;

my $sum = 0;

foreach my $pattern (@patterns) {
    foreach my $lines_mult ([$pattern->{rows}, 100], [$pattern->{cols}, 1]) {
        my ($lines, $mult) = @$lines_mult;
        for (my $i=1; $i < @$lines; ++$i) {
            my $r = 0;          # number of reflected columns
            while ($i-$r-1 >= 0 && $i+$r < @$lines && $lines->[$i-$r-1] eq $lines->[$i+$r]) {
                $r += 1;
            }
            if ($i-$r-1 < 0 || $i+$r == @$lines) {
                #say $i;
                $sum += $i * $mult;
            }
        }
    }
}

say $sum;
