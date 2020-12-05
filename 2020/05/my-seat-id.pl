#!/usr/bin/env perl

use 5.030;
use warnings;
use List::Util qw(reduce);

my $seat;

reduce {$seat = $a+1 if $b - $a == 2; $b}
    sort {$a <=> $b}
    map {tr/FBLR/0101/; eval "0b$_"}
    <>;

say $seat;
