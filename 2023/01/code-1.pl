#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;

my $sum = 0;

while (<>) {
    my ($first_digit) = /(\d)/;
    my ($last_digit) = /(\d)[^\d]+$/;
    $sum += "$first_digit$last_digit";
}

say $sum;
