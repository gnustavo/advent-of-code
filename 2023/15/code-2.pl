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
    foreach my $char (split '', $label) {
        $hash += ord($char);
        $hash *= 17;
        $hash %= 256;
    }
    return $hash;
}

my @boxes = map {[]} 1 .. 256;

foreach my $step (@steps) {
    my ($label, $op, $number) = ($step =~ /^([a-z]+)([-=])(\d*)/);
    my $hash = hash($label);
    my $lens = $boxes[$hash];
    #say "$step: ($label, $op, $number, $hash)";
    my $i;
    for ($i=0; $i < @$lens; ++$i) {
        last if $lens->[$i][0] eq $label;
    }
    if ($op eq '=') {
        if ($i < @$lens) {
            $lens->[$i][1] = $number;
        } else {
            push @$lens, [$label, $number];
        }
    } else {                    # '-'
        if ($i < @$lens) {
            splice @$lens, $i, 1;
        }
    }
}

my $total_fp = 0;

#ddx \@boxes;

while (my ($i, $box) = each @boxes) {
    while (my ($j, $lens) = each @$box) {
        #printf "%s: %d * %d * %d\n", $lens->[0], $i+1, $j+1, $lens->[1];
        my $fp = ($i+1) * ($j+1) * $lens->[1];
        $total_fp += $fp;
    }
}

say $total_fp;
