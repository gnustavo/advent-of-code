#!/usr/bin/env perl

use 5.030;
use List::Util qw(sum0 uniqstr);

$/ = '';                        # paragraph mode

say
sum0
map {scalar(uniqstr sort split //, $_)}
map {tr/a-z//cdr}
<>;
