#!/usr/bin/env perl

use 5.030;
use warnings;

chomp(my $card_pk = <>);
chomp(my $door_pk = <>);

my $sn = 7;
my $loop_size = 0;
my $n = 1;
while ($n != $card_pk && $n != $door_pk) {
    $n = ($n * $sn) % 20201227;
    $loop_size += 1;
}

$sn = $n == $card_pk ? $door_pk : $card_pk;
$n = 1;

for my $i (1 .. $loop_size) {
    $n = ($n * $sn) % 20201227;
}

say $n;

