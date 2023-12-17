#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;

my @steps;

while (<>) {
    chomp;
    push @steps, split ',';
}

sub hash {
    my ($label) = @_;

    my $hash = 0;
    foreach my $char (split '') {
        $hash += ord($char);
        $hash *= 17;
        $hash %= 256;
    }
    return $hash;
}

my $sum = 0;
foreach (@steps) {
    $sum += hash($_);
}
say $sum;
