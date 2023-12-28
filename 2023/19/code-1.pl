#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;
use List::Util qw(sum0);

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

my @parts;
while (<>) {
    chomp;
    push @parts, {
        map {(/^([xmas])=(\d+)$/)}
        split ',', substr($_, 1, length($_)-2)
    };
}

#ddx \%workflows, \@parts;

my $ratings = 0;

PART:
foreach my $part (@parts) {
    my $workflow = 'in';
  WORKFLOW:
    while (1) {
        if ($workflow eq 'A') {
            $ratings += sum0 values %$part;
            next PART;
        } elsif ($workflow eq 'R') {
            next PART;
        } else {
            foreach my $rule ($workflows{$workflow}->@*) {
                my ($condition, $next_workflow) = @$rule;
                #ddx $condition, $next_workflow;
                if (defined $condition) {
                    my ($category, $op, $number) = @$condition;
                    if ($op eq '<') {
                        if ($part->{$category} < $number) {
                            $workflow = $next_workflow;
                            next WORKFLOW;
                        }
                    } else {
                        if ($part->{$category} > $number) {
                            $workflow = $next_workflow;
                            next WORKFLOW;
                        }
                    }
                } else {
                    $workflow = $next_workflow;
                    next WORKFLOW;
                }
            }
        }
    }
}

say $ratings;
