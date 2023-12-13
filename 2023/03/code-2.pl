#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use List::Util qw(any);
use English;

my @lines;
while (<>) {
    chomp;
    push @lines, ".$_.";
}

unshift @lines, '.' x length($lines[0]);
push    @lines, '.' x length($lines[0]);

my %parts;
my %gears;

for (my $i = 1; $i < $#lines; ++$i) {
    while ($lines[$i] =~ /\d+/gp) {
        my $match = ${^MATCH};
        my $begin = $-[0];

        if (any {/\*/} map {substr($lines[$i+$_], $begin-1, length($match)+2)} -1 .. +1) {
            $parts{$i}{$begin} = $match;
        }
    }

    while ($lines[$i] =~ /\*/gp) {
        $gears{$i}{$-[0]} = undef;
    }
}

my $sum = 0;

foreach my $line (sort {$a <=> $b} keys %gears) {
    foreach my $col (sort {$a <=> $b} keys $gears{$line}->%*) {
        my @parts;
        foreach my $offset (-1 .. +1) {
            while (my ($begin, $match) = each $parts{$line+$offset}->%*) {
                if ($col >= $begin-1 && $col <= $begin+length($match)) {
                    push @parts, $match;
                }
            }
        }

        if (@parts == 2) {
            $sum += $parts[0] * $parts[1];
        } else {
            printf "asterisk at $line\[$col\] is adjacent to %d parts.\n", scalar(@parts);
        }
    }
}

say $sum;
