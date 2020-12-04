#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;

my $valid_passports_count = 0;

$/ = '';                        # paragraph mode
PASSPORT:
while (<>) {
    s/\n/ /g;                   # remove newlines
    my %fields = split /[ :]/;
    foreach my $key (qw/byr iyr eyr hgt hcl ecl pid/) {
        next PASSPORT unless exists $fields{$key};
    }
    ++$valid_passports_count;
}

say $valid_passports_count;
