#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;

my %number = (
    0     => 0,
    1     => 1,
    2     => 2,
    3     => 3,
    4     => 4,
    5     => 5,
    6     => 6,
    7     => 7,
    8     => 8,
    9     => 9,
    zero  => 0,
    one   => 1,
    two   => 2,
    three => 3,
    four  => 4,
    five  => 5,
    six   => 6,
    seven => 7,
    eight => 8,
    nine  => 9,
);

my $pattern = join('|', keys %number);
my $digit = qr/$pattern/o;

my $sum = 0;

while (<>) {
    my @digits;
    while (/($digit)/g) {
        push @digits, $number{$1};
        pos() = $-[0] + 1;
    }
    my $digits = "$digits[0]$digits[-1]";
    $sum += $digits;
}

say $sum;
