#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;

my $valid_count = 0;

while (<>) {
    if (my ($min, $max, $letter, $password) = /^(\d+)-(\d+) (.): (.+)/) {
        my $num = length($password =~ s/[^$letter]//gr);
        ++$valid_count if $min <= $num && $num <= $max;
    } else {
        die "Invalid line $.: $_";
    }
}

say $valid_count;
