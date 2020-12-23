#!/usr/bin/env perl

use 5.030;
use warnings;
use List::AllUtils qw(min minmax first_index after before max);

chomp(my $input = <>);

sub play1 {
    my ($moves, @list) = @_;

    my ($min, $max) = minmax @list;

    my $size = @list;

    my $current = 0;

    for (my $move = 1; $move <= $moves; ++$move) {
        #say "-- move $move --";
        #say "cups: ", join(' ', @list[0 .. $current-1], "($list[$current])", @list[$current+1 .. $#list]);

        # ACTION #1
        my @removed;
        my $start_remove = ($current + 1) % $size;
        my $after_remove = ($start_remove + 3) % $size;
        if ($start_remove < $after_remove) {
            @removed = splice @list, $start_remove, 3;
            $current -= 3 if $start_remove < $current;
        } else {
            @removed = splice @list, $start_remove, ($size - $start_remove + 1);
            push @removed, splice @list, 0, $after_remove;
            $current -= $after_remove;
        }
        #say "pick up: ", join(' ', @removed);

        # ACTION #2
        my $destination;
        for (
            my $label = $list[$current] - 1;
            ! defined $destination;
            $label = $label <= $min ? $max : $label - 1
        ) {
            my $index = first_index {$_ == $label} @list;
            $destination = $index if $index != -1;
        }
        #say "destination: ", $list[$destination];

        # ACTION #3
        splice @list, $destination + 1, 0, @removed;
        $current += 3 if $current > $destination;

        # ACTION #4
        $current = ($current + 1) % $size;

        #say '';
    }

    #say "cups: ", join(' ', @list[0 .. $current-1], "($list[$current])", @list[$current+1 .. $#list]);

    return \@list;
}


sub play2 {
    my ($moves, $max, @labels) = @_;

    my $prefix_size = @labels;
    my $min = min @labels;

    push @labels, max(@labels)+1 .. $max;
    # @labels is immutable from now on

    my @prev = ($#labels, 0 .. $#labels-1);
    my @next = (1 .. $#labels, 0);

    my $current = 0;

    my $show = sub {
        print "cups: $labels[$current]";
        for (my $i = $next[$current]; $i != $current; $i = $next[$i]) {
            print " $labels[$i]";
        }
        say '';
    };

    for (my $move = 1; $move <= $moves; ++$move) {
        #say "-- move $move --";
        #$show->();

        # ACTION #1
        my $first_removed = $next[$current];
        my $last_removed = $next[$next[$first_removed]];
        $next[$current] = $next[$last_removed];
        $prev[$next[$last_removed]] = $current;

        # ACTION #2
        my $destination;
        my $label = $labels[$current] == $min ? $max : $labels[$current] - 1;
        while ($label == $labels[$first_removed] || $label == $labels[$next[$first_removed]] || $label == $labels[$next[$next[$first_removed]]]) {
            $label = $label == $min ? $max : $label - 1;
        }
        if ($label > $prefix_size) {
            $destination = $label - 1;
        } else {
            $destination = first_index {$_ == $label} @labels[0 .. $prefix_size - 1];
        }
        #say "destination: ", $labels[$destination];

        # ACTION #3
        $prev[$first_removed] = $destination;
        $next[$last_removed] = $next[$destination];
        $prev[$next[$destination]] = $last_removed;
        $next[$destination] = $first_removed;

        # ACTION #4
        $current = $next[$current];

        #say '';
    }

    #$show->();

    my @result = ($labels[$current]);
    for (my $i = $next[$current]; $i != $current; $i = $next[$i]) {
        push @result, $labels[$i];
    }

    return \@result;
}


my @list = split //, $input;

my $one = play1(100, @list);
say "ONE using play1 = ", join('', after {$_ == 1} @$one), join('', before {$_ == 1} @$one);

my $one2 = play2(100, max(@list), @list);
say "ONE using play2 = ", join('', after {$_ == 1} @$one2), join('', before {$_ == 1} @$one2);

my $moves = 10_000_000;
my $max = 1_000_000;

my $two = play2($moves, $max, @list);
my $index_of_one = first_index {$_ == 1} @$two;
say "TWO using play2 = ", $two->[($index_of_one + 1) % $max] * $two->[($index_of_one + 2) % $max];
