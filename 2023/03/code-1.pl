#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use List::Util qw(any);
use Data::Dump;
use English;

my @lines;
while (<>) {
    chomp;
    push @lines, ".$_.";
}

unshift @lines, '.' x length($lines[0]);
push    @lines, '.' x length($lines[0]);

ddx \@lines;

my $sum = 0;

for (my $i = 1; $i < $#lines; ++$i) {
    while ($lines[$i] =~ /\d+/gp) {
        my $match = ${^MATCH};
        my $begin = $-[0];

        if (any {/[^\.\d]/}
            substr($lines[$i],   $begin-1,              1),
            substr($lines[$i],   $begin+length($match), 1),
            substr($lines[$i-1], $begin-1,              length($match)+2),
            substr($lines[$i+1], $begin-1,              length($match)+2),
        ) {
            say "$i\[$begin\] = $match";
            $sum += $match;
        } else {
            say "$i\[$begin\] = $match (SKIP)";
        }
    }
}

say $sum;
