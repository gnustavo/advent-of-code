#!/usr/bin/env perl

use 5.030;
use warnings;
use List::AllUtils qw(after before);

my (@player1, @player2);

{
    chomp(my @input = grep {$_ !~ /Player/} <>);
    @player1 = before {length == 0} @input;
    @player2 = after  {length == 0} @input;
}

sub play1 {
    my ($p1, $p2) = @_;

    while (@$p1 && @$p2) {
        #say '#' x @$p1, ' ', '#' x @$p2;
        if ($p1->[0] > $p2->[0]) {
            push @$p1, shift(@$p1), shift(@$p2);
        } else {
            push @$p2, shift(@$p2), shift(@$p1);
        }
    }
    #say '#' x @$p1, ' ', '#' x @$p2;

    return @$p1 ? $p1 : $p2;
}

sub play2 {
    my ($p1, $p2) = @_;

    my (%mem1, %mem2);

    while (@$p1 && @$p2) {
        # Rule 1
        return (1, $p1) if $mem1{join('', map {chr} @$p1)}++ || $mem2{join('', map {chr} @$p2)}++;

        # Rule 2
        my $card1 = shift @$p1;
        my $card2 = shift @$p2;

        # Rule 3
        if ($card1 <= @$p1 && $card2 <= @$p2) {
            my ($winner) = play2([@{$p1}[0 .. $card1 - 1]], [@{$p2}[0 .. $card2 - 1]]);
            if ($winner == 1) {
                push @$p1, $card1, $card2;
            } else {
                push @$p2, $card2, $card1;
            }
        # Rule 4
        } else {
            if ($card1 > $card2) {
                push @$p1, $card1, $card2;
            } else {
                push @$p2, $card2, $card1;
            }
        }
    }

    return @$p1 ? (1, $p1) : (2, $p2);
}

sub score {
    my ($p) = @_;

    my $score = 0;
    my $mult = 1;

    while (@$p) {
        $score += pop(@$p) * $mult;
        $mult += 1;
    }

    return $score;
}

my $win1 = play1([@player1], [@player2]);
say score($win1);

my (undef, $win2) = play2([@player1], [@player2]);
say score($win2);
