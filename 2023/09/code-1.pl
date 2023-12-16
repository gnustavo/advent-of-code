#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use List::Util qw(notall);

my @histories;
while (<>) {
    chomp;
    push @histories, [split ' '];
}

my $sum = 0;

foreach my $history (@histories) {
    my @all_differences = ($history);
    while (notall {$_ == 0} $all_differences[-1]->@*) {
        my @differences;
        my $val = 0;            # start with a canary
        foreach ($all_differences[-1]->@*) {
            push @differences, ($_ - $val);
            $val = $_;
        }
        if (@differences) {
            shift @differences; # discard the difference to the canary
            push @all_differences, \@differences;
        } else {
            last;
        }
    }
    for (my $i=$#all_differences-1; $i >= 0; --$i) {
        push $all_differences[$i]->@*, ($all_differences[$i][-1] + $all_differences[$i+1][-1]);
    }
    $sum += $history->[-1];
}

say $sum;
