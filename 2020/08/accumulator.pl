#!/usr/bin/env perl

use 5.030;
use warnings;

my @program = map {[split / /]} <>;
my @seen = (0) x @program;
my ($acc, $pc) = (0, 0);

while (! $seen[$pc]) {
    $seen[$pc] = 1;
    my ($op, $num) = @{$program[$pc]};
    if ($op eq 'acc') {
        $acc += $num;
        $pc += 1;
    } elsif ($op eq 'jmp') {
        $pc += $num;
    } elsif ($op eq 'nop') {
        $pc += 1;
    } else {
        die "Invalid op ($op) at line $pc\n";
    }
}

say $acc;
