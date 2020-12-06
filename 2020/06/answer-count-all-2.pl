#!/usr/bin/env perl

use 5.030;
use List::Util qw(sum0);

$/ = '';                        # paragraph mode

say sum0 map {count($_)} <>;

sub count {
    my ($forms) = @_;
    my @forms = split /\n/, $forms;
    my %answers;
    foreach my $form (@forms) {
        foreach my $answer (split //, $form) {
            $answers{$answer} += 1;
        }
    }
    return scalar(grep {scalar($_) == @forms} values %answers);
}
