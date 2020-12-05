#!/usr/bin/env perl

use 5.030;
use List::Util qw(max);

say max map {tr/FBLR/0101/; eval "0b$_"} <>;
