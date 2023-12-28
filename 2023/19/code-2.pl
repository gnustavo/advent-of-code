#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;
$Data::Dump::LINEWIDTH = 210;
use List::Util qw(product);

my %workflows;
while (<>) {
    chomp;
    last unless length;
    my ($name, $rules) = (/^([a-z]+)\{(.+)\}$/);
    my @rules;
    foreach (split ',', $rules) {
        if (/^([xmas])([<>])(\d+):([a-z]+|[AR])$/) {
            push @rules, [[$1, $2, $3], $4];
        } elsif (/^([a-z]+|[AR])$/) {
            push @rules, [undef, $1];
        } else {
            die "$.: Invalid rule '$_'";
        }
    }
    $workflows{$name} = \@rules;
}

sub combinations {
    my ($workflow, $rule_no, $ranges) = @_;

    if ($workflow eq 'A') {
        return
            product
            map {$_->[1] - $_->[0] + 1}
            values %$ranges
            ;
    } elsif ($workflow eq 'R') {
        return 0;
    }

    die "Can't happen!" if $rule_no == $workflows{$workflow}->@*;

    my $rule = $workflows{$workflow}[$rule_no];

    my ($condition, $next_workflow) = @$rule;

    if (defined $condition) {
        my ($category, $op, $number) = @$condition;
        my $range = $ranges->{$category};
        if ($op eq '<') {
            if ($range->[0] >= $number) {
                # No way for this range to satisfy this rule. Skip it.
                return combinations($workflow, $rule_no+1, $ranges);
            } elsif ($range->[1] >= $number) {
                # This range satisfy this rule partially.
                return
                    do {
                        local $range->[1] = $number-1;
                        combinations($next_workflow, 0, $ranges);
                    }
                    +
                    do {
                        local $range->[0] = $number;
                        combinations($workflow, $rule_no+1, $ranges);
                    }
                    ;
            } else {
                # This range always satisfy this rule.
                return combinations($next_workflow, 0, $ranges);
            }
        } else {                # $op eq '>'
            if ($range->[1] <= $number) {
                # No way for this range to satisfy this rule. Skip it.
                return combinations($workflow, $rule_no+1, $ranges);
            } elsif ($range->[0] <= $number) {
                # This range satisfy this rule partially.
                return
                    do {
                        local $range->[0] = $number+1;
                        combinations($next_workflow, 0, $ranges);
                    }
                    +
                    do {
                        local $range->[1] = $number;
                        combinations($workflow, $rule_no+1, $ranges);
                    }
                    ;
            } else {
                # This range always satisfy this rule.
                return combinations($next_workflow, 0, $ranges);
            }
        }
    } else {
        return combinations($next_workflow, 0, $ranges);
    }
}

say combinations(
    'in',
    0,
    {
        x => [1, 4000],
        m => [1, 4000],
        a => [1, 4000],
        s => [1, 4000],
    },
);
