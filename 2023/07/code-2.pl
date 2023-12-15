#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use POSIX qw(ceil floor);
use List::Util qw(max min product);
use Data::Dump;

my %cards = (
    'A' => 12,
    'K' => 11,
    'Q' => 10,
    'T' =>  9,
    '9' =>  8,
    '8' =>  7,
    '7' =>  6,
    '6' =>  5,
    '5' =>  4,
    '4' =>  3,
    '3' =>  2,
    '2' =>  1,
    'J' =>  0,                  # joker
);

my %types = (
    'Five of a kind'  => 6,
    'Four of a kind'  => 5,
    'Full house'      => 4,
    'Three of a kind' => 3,
    'Two pair'        => 2,
    'One pair'        => 1,
    'High card'       => 0,
);

sub type {
    my ($hand) = @_;
    my %kinds;
    foreach my $label (split '', $hand) {
        $kinds{$label} += 1;
    }

    if (my $joker_frequency = delete $kinds{J}) {
        return 'Five of a kind' unless %kinds;
        # Substitute the jokers for the most frequent other card
        my ($mf_label, $mf_frequency) = (undef, 0);
        while (my ($label, $frequency) = each %kinds) {
            if ($frequency > $mf_frequency) {
                ($mf_label, $mf_frequency) = ($label, $frequency);
            }
        }
        $kinds{$mf_label} = $mf_frequency + $joker_frequency;
    }

    if (%kinds == 1) {
        return 'Five of a kind';
    } elsif (%kinds == 2) {
        my $largest_value = max values %kinds;
        if ($largest_value == 4) {
            return 'Four of a kind';
        } else {
            return 'Full house';
        }
    } elsif (%kinds == 3) {
        my $largest_value = max values %kinds;
        if ($largest_value == 3) {
            return 'Three of a kind';
        } else {
            return 'Two pair';
        }
    } elsif (%kinds == 4) {
        return 'One pair';
    } else {
        return 'High card';
    }
}

my @hands;
while (<>) {
    chomp;
    my ($hand, $bid) = (split ' ');
    push @hands, {
        cards => [split '', $hand],
        bid => $bid,
        type => type($hand),
    };
}

sub is_stronger_than {
    if (my $cmp = $types{$a->{type}} <=> $types{$b->{type}}) {
        # If the types are different we're done.
        return $cmp;
    }
    # If types are the same, we have to compare the strength of each hand's
    # card.
    foreach (my $i=0; $i < $a->{cards}->@*; ++$i) {
        if (my $cmp = $cards{$a->{cards}[$i]} <=> $cards{$b->{cards}[$i]}) {
            return $cmp;
        }
    }
    return 0;
}

my @ranked = (undef, sort is_stronger_than @hands);

my $winnings = 0;

for (my $i=1; $i < @ranked; ++$i) {
    $winnings += $i * $ranked[$i]{bid};
}

say $winnings;
