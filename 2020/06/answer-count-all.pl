#!/usr/bin/env perl

use 5.030;

my $count = 0;

$/ = '';                        # paragraph mode

while (<>) {
    my @forms = split /\n/;
    my %answers;
    foreach my $form (@forms) {
        foreach my $answer (split //, $form) {
            $answers{$answer} += 1;
        }
    }
    $count += grep {scalar($_) == @forms} values %answers;
}

say $count;
