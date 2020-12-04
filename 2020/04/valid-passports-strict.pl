#!/usr/bin/env perl

use 5.030;
use autodie;
use warnings;

my $valid_passports_count = 0;

$/ = '';                        # paragraph mode
PASSPORT:
while (<>) {
    chomp;
    s/\n/ /g;                   # remove newlines
    my %fields = map {split /:/} split /\s+/;

    foreach my $key (qw/byr iyr eyr hgt hcl ecl pid/) {
        next PASSPORT unless exists $fields{$key};
    }

    if (my ($num) = $fields{byr} =~ /^(\d{4})$/) {
        next unless $num >= 1920 && $num <= 2002;
    } else {
        next;
    }

    if (my ($num) = $fields{iyr} =~ /^(\d{4})$/) {
        next unless $num >= 2010 && $num <= 2020;
    } else {
        next;
    }

    if (my ($num) = $fields{eyr} =~ /^(\d{4})$/) {
        next unless $num >= 2020 && $num <= 2030;
    } else {
        next;
    }

    if (my ($num, $unit) = $fields{hgt} =~ /^(\d+)(cm|in)$/) {
        if ($unit eq 'cm') {
            next unless $num >= 150 && $num <= 193;
        } else {
            next unless $num >= 59 && $num <= 76;
        }
    } else {
        next;
    }

    next unless $fields{hcl} =~ /^\#([0-9a-f]{6})$/;

    next unless $fields{ecl} =~ /^(amb|blu|brn|gry|grn|hzl|oth)$/;

    next unless $fields{pid} =~ /^\d{9}$/;

    ++$valid_passports_count;
}

say $valid_passports_count;
