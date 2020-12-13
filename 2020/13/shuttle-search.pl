#!/usr/bin/env perl

use 5.030;
use warnings;
use List::AllUtils qw(min_by);
use Math::BigInt lib => 'GMP';

my $timestamp = <>;

while (<>) {
    chomp;
    say;
    my $ids = [split /,/, $_];
    one($timestamp, $ids);
    two_a($ids);
    two_b($ids);
    say '';
}

sub one {
    my ($timestamp, $ids) = @_;
    my $earliest =
        min_by { $_ - $timestamp % $_ }
        grep {$_ ne 'x'}
        @$ids;
    say $earliest * ($earliest - $timestamp % $earliest);
}

sub two_a {
    my ($ids) = @_;
    my @deps =
        sort {$a->[1] <=> $b->[1]} # to optimize the search below
        map {[Math::BigInt->new($_), Math::BigInt->new($ids->[$_])]}
        grep {$ids->[$_] ne 'x'}
        0 .. $#$ids;

    my $t    = Math::BigInt->bzero();
    my $step = Math::BigInt->bone();

    foreach (@deps) {
        my ($offset, $id) = @$_;
        $t->badd($step) while ($t + $offset) % $id != 0;
        $step->bmul($id);
    }

    say $t;
}

sub two_b {
    my ($ids) = @_;

    my $t    = Math::BigInt->bzero();
    my $step = Math::BigInt->bone();

    foreach (grep {$ids->[$_] ne 'x'} 0 .. $#$ids) {
        my $offset = Math::BigInt->new($_);
        my $id = Math::BigInt->new($ids->[$offset]);
        $t->badd($step) while ($t + $offset) % $id != 0;
        $step->bmul($id);
    }

    say $t;
}
