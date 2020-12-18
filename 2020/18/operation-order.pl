#!/usr/bin/env perl

use 5.030;
use warnings;
use List::AllUtils qw(sum0 reduce);

chomp(my @input = <>);

say sum0 map {solve1(tokenize($_))} @input;
say sum0 map {solve2(tokenize($_))} @input;

sub tokenize {
    my ($exp) = @_;
    return [$exp =~ /(\d+|[+*()])/g];
}

sub solve1 {
    my ($tokens) = @_;

    my $acc = 0;
    my $op;
    while (@$tokens) {
        my $token = shift @$tokens;
        if ($token =~ /\d/) {
            if (! defined $op) {
                $acc = $token;
            } elsif ($op eq '+') {
                $acc += $token;
            } else {
                $acc *= $token;
            }
        } elsif ($token =~ /[+*]/) {
            $op = $token;
        } elsif ($token eq '(') {
            unshift @$tokens, solve1($tokens);
        } elsif ($token eq ')') {
            last;
        } else {
            die "Invalid token '$token'\n";
        }
    }
    return $acc;
}

sub solve2 {
    my ($tokens) = @_;

    my @operands;
    my @operators;

    while (@$tokens) {
        my $token = shift @$tokens;
        if ($token =~ /\d/) {
            if (@operators && $operators[-1] eq '+') {
                $operands[-1] += $token;
                pop @operators;
            } else {
                push @operands, $token;
            }
        } elsif ($token =~ /[+*]/) {
            push @operators, $token;
        } elsif ($token eq '(') {
            unshift @$tokens, solve2($tokens);
        } elsif ($token eq ')') {
            last;
        } else {
            die "Invalid token '$token'\n";
        }
    }

    return reduce {$a * $b} 1, @operands;
}
