#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;

my $valid_passports_count = 0;

$/ = '';                        # paragraph mode
while (<>) {
    s/\n/ /g;                   # remove newlines
    my %fields = split /[ :]/;

    next unless
        exists $fields{byr} &&
        $fields{byr} =~ /^(\d{4})$/ &&
        $1 >= 1920 && $1 <= 2002;

    next unless
        exists $fields{iyr} &&
        $fields{iyr} =~ /^(\d{4})$/ &&
        $1 >= 2010 && $1 <= 2020;

    next unless
        exists $fields{eyr} &&
        $fields{eyr} =~ /^(\d{4})$/ &&
        $1 >= 2020 && $1 <= 2030;

    next unless
        exists $fields{hgt} &&
        $fields{hgt} =~ /^(\d+)(cm|in)$/ &&
        $2 eq 'cm' ? $1 >= 150 && $1 <= 193 : $1 >= 59 && $1 <= 76;

    next unless
        exists $fields{hcl} &&
        $fields{hcl} =~ /^\#([0-9a-f]{6})$/;

    next unless
        exists $fields{ecl} &&
        $fields{ecl} =~ /^(amb|blu|brn|gry|grn|hzl|oth)$/;

    next unless
        exists $fields{pid} &&
        $fields{pid} =~ /^\d{9}$/;

    ++$valid_passports_count;
}

say $valid_passports_count;
