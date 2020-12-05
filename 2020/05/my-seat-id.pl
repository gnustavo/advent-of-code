#!/usr/bin/env perl

use 5.030;
use List::Util qw(reduce);

reduce {say $a+1 if $b - $a == 2; $b} sort {$a <=> $b} map {tr/FBLR/0101/; eval "0b$_"} <>;
