#!/usr/bin/env perl

use 5.030;

my ($acc, $pc) = (0, 0);
my @program;

while (<>) {
    if (/(acc|jmp|nop) ([-+]\d+)/) {
        push @program, [0, $1, 0+$2];
    } else {
        die "Invalid instruction: $_";
    }
}

while ($program[$pc][0] == 0) {
    $program[$pc][0] = 1;
    my ($op, $num) = @{$program[$pc]}[1, 2];
    if ($op eq 'acc') {
        $acc += $num;
        $pc += 1;
    } elsif ($op eq 'jmp') {
        $pc += $num;
    } elsif ($op eq 'nop') {
        $pc += 1;
    }
}

say $acc;
