#!/usr/bin/env perl

use 5.030;
use warnings;
use List::Util qw(min max);

my @data = map {chomp; $_} <>;
my $window = 25;

sub one {
    my ($window) = @_;

    my %window;

    for my $i (0 .. $window-1) {
        $window{$data[$i]} += 1;
    }

  FOCUS:
    for my $i ($window .. $#data) {
        my $focus = $data[$i];
        for my $j ($i-$window .. $i-1) {
            my $try = $data[$j];
            if ($focus >= $try) {
                my $complement = $focus - $try;
                next FOCUS if $try != $complement && exists $window{$complement};
            }
        }
        return $focus;
    } continue {
        $window{$data[$i]} += 1;
        $window{$data[$i-$window]} -= 1;
        delete $window{$data[$i-$window]}
            if $window{$data[$i-$window]} == 0;
    }

    die "Couldn't find a result for one($window)\n";
}

sub two {
    my ($number) = @_;

    my ($first, $last) = (0, 0);
    my $sum = $data[0];

    while ($sum != $number) {
        if ($sum < $number) {
            $last += 1;
            last if $last == @data;
            $sum += $data[$last];
        } else {
            $sum -= $data[$first];
            $first += 1;
        }
    }

    die "Couldn't find a result for two($number)\n"
        if $last == @data;

    my @sequence = @data[$first .. $last];

    return min(@sequence) + max(@sequence);
}

my $one = one($window);
my $two = two($one);

say $one;
say $two;
