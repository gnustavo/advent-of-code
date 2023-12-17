#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Crypt::Digest::SHA256 qw(sha256 sha256_hex);
use Data::Dump;

my $cycles = 1_000_000_000;

my @platform;
while (<>) {
    chomp;
    push @platform, [split ''];
}

my $width = $platform[0]->@*;

sub north {
    my ($platform) = @_;

    my @rot;

    for (my $i=0; $i < @$platform; ++$i) {
        for (my $j=0; $j < $width; ++$j) {
            my $char = $platform->[$i][$j];
            my $k = $i;
            if ($char eq 'O') {
                while ($k > 0 && $rot[$k-1][$j] eq '.') {
                    $k -= 1;
                }
                if ($k < $i) {
                    $rot[$i][$j] = '.';
                }
            }
            $rot[$k][$j] = $char;
        }
    }

    return \@rot;
}

sub south {
    my ($platform) = @_;

    my @rot;

    for (my $i=$#$platform; $i >= 0; --$i) {
        for (my $j=0; $j < $width; ++$j) {
            my $char = $platform->[$i][$j];
            my $k = $i;
            if ($char eq 'O') {
                while ($k < $#$platform && $rot[$k+1][$j] eq '.') {
                    $k += 1;
                }
                if ($k > $i) {
                    $rot[$i][$j] = '.';
                }
            }
            $rot[$k][$j] = $char;
        }
    }

    return \@rot;
}

sub west {
    my ($platform) = @_;

    my @rot;

    for (my $j=0; $j < $width; ++$j) {
        for (my $i=0; $i < @$platform; ++$i) {
            my $char = $platform->[$i][$j];
            my $k = $j;
            if ($char eq 'O') {
                while ($k > 0 && $rot[$i][$k-1] eq '.') {
                    $k -= 1;
                }
                if ($k < $j) {
                    $rot[$i][$j] = '.';
                }
            }
            $rot[$i][$k] = $char;
        }
    }

    return \@rot;
}

sub east {
    my ($platform) = @_;

    my @rot;

    for (my $j=$width-1; $j >= 0; --$j) {
        for (my $i=0; $i < @$platform; ++$i) {
            my $char = $platform->[$i][$j];
            my $k = $j;
            if ($char eq 'O') {
                while ($k+1 < $width && $rot[$i][$k+1] eq '.') {
                    $k += 1;
                }
                if ($k > $j) {
                    $rot[$i][$j] = '.';
                }
            }
            $rot[$i][$k] = $char;
        }
    }

    return \@rot;
}

sub cycle {
    my ($platform) = @_;

    my $rot = $platform;
    $rot = north($rot); #ddx north => $rot;
    $rot =  west($rot); #ddx  west => $rot;
    $rot = south($rot); #ddx south => $rot;
    $rot =  east($rot); #ddx  east => $rot;
    return $rot;
}

my $rot = \@platform;
#ddx $rot;

# Cycle until we detect a loop
my %hashes;
my $n;
my $loop_length;
for ($n=1; $n <= $cycles; ++$n) {
    $rot = cycle($rot);
    my $hash = sha256_hex(map {join('', @$_)} @$rot);
    #say "$n\t$hash";
    if (exists $hashes{$hash}) {
        $loop_length = $n - $hashes{$hash};
        say "Found loop of length $loop_length after $n cycles";
        last;
    }
    $hashes{$hash} = $n;
}

#ddx $rot;

if ($n < $cycles) {
    my $extra_cycles = ($cycles - $n) % $loop_length;
    for (1 .. $extra_cycles) {
        $rot = cycle($rot);
    }
}

my $total_load = 0;

while (my ($i, $row) = each @$rot) {
    my $load = @$rot - $i;
    my $rounded_rocks = grep {$_ eq 'O'} @$row;
    $total_load += $load * $rounded_rocks;
}

say $total_load;
