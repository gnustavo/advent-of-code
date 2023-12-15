#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use List::BinarySearch qw(:all);

my (@seeds, @maps, @ranges);

while (<>) {
    if (/^seeds: ([\d\s]+)/) {
        my @seed_ranges = split ' ', $1;
        while (@seed_ranges) {
            push @seeds, [splice(@seed_ranges, 0, 2)];
        }
        @seeds = sort {$a->[0] <=> $b->[0]} @seeds;
    } elsif (/([\w-])\s+map:/) {
        # tuck them in reverse order
        unshift @maps, [sort {$a->{destin_beg} <=> $b->{destin_beg}} @ranges] if @ranges;
        @ranges = ();
    } elsif (my ($destin, $origin, $length) = (/(\d+) (\d+) (\d+)/)) {
        push @ranges, {
            destin_beg => $destin,
            destin_end => $destin + $length,
            origin_beg => $origin,
            origin_end => $origin + $length,
        };
    }
}
unshift @maps, [sort {$a->{destin_beg} <=> $b->{destin_beg}} @ranges] if @ranges;

use Data::Dump;
#ddx \@seeds, \@maps;

sub range_cmp {
    if ($a < $b->{destin_beg}) {
        return -1;
    } elsif ($a < $b->{destin_end}) {
        return 0;
    } else {
        return +1;
    }
}

sub seed_cmp {
    if ($a < $b->[0]) {
        return -1;
    } elsif ($a < ($b->[0] + $b->[1])) {
        return 0;
    } else {
        return +1;
    }
}

# Find the lowest location that can be reached from one of the original seeds.
for (my $i=0; $i <= 1000000000; ++$i) {
    warn "trying $i\n" if $i % 1000000 == 0;
    my $number = $i;
  MAP:
    foreach my $ranges (@maps) {
        my $index = binsearch \&range_cmp, $number, @$ranges;
        if (defined $index) {
            $number = $ranges->[$index]{origin_beg} + ($number - $ranges->[$index]{destin_beg});
        }
    }
    # See if we came from one of the original seeds
    my $index = binsearch \&seed_cmp, $number, @seeds;
    if (defined $index) {
        say $i;
        exit 0;
    }
}

warn "Couldn't find a seed!\n";
exit 1;
