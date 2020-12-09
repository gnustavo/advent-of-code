#!/usr/bin/env perl

use 5.030;

my @program = map {[split / /]} <>;

for my $i (0 .. $#program) {
    if ($program[$i][0] =~ /(jmp|nop)/) {
        local $program[$i][0] = $1 eq 'jmp' ? 'nop' : 'jmp';
        my $acc = run();
        if (defined $acc) {
            say $acc;
            exit 0;
        }
    }
}

sub run {
    my ($acc, $pc) = (0, 0);
    my @seen = (0) x @program;

    while ($pc < @program && ! $seen[$pc]) {
        $seen[$pc] = 1;

        my ($op, $num) = @{$program[$pc]};
        if ($op eq 'acc') {
            $acc += $num;
            $pc += 1;
        } elsif ($op eq 'jmp') {
            $pc += $num;
        } elsif ($op eq 'nop') {
            $pc += 1;
        }
    }

    return $pc < @program ? undef : $acc;
}
