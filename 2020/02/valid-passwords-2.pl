#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;

my $valid_count = 0;

while (<>) {
    if (my ($one, $two, $letter, $password) = /^(\d+)-(\d+) (.):( .+)/) {
        ++$valid_count if
            substr($password, $one, 1) eq $letter xor
            substr($password, $two, 1) eq $letter;
    } else {
        die "Invalid line $.: $_";
    }
}

say $valid_count;
