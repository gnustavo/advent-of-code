#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;
use POSIX qw(INT_MAX);
use Algorithm::Combinatorics qw(combinations);
use List::MoreUtils qw(frequency);

my (%diagram, @vertices, @wires);
while (<>) {
    chomp;
    my @connecteds = split ' ';
    my $component = shift @connecteds;
    chop $component;
    foreach my $connected (@connecteds) {
        $diagram{$component}{$connected} = undef;
        $diagram{$connected}{$component} = undef;
        push @wires, [$component, $connected];
    }
}

ddx \%diagram, \@wires, scalar(@wires);

sub cliques {
    my %checked;
    my %to_check = map {($_ => undef)} keys %diagram;
    my $clique=1;
    while (%to_check) {
        keys %to_check;                     # reset iterator
        my @to_check = (each %to_check)[0]; # Start with some aleatory component
        while (my $component = shift @to_check) {
            unless (exists $checked{$component}) {
                $checked{$component} = $clique;
                delete $to_check{$component};
                push @to_check, keys $diagram{$component}->%*;
            }
        }
    } continue {
        $clique += 1;
    }
    return values {frequency values %checked}->%*;
}

foreach my $wires (combinations \@wires, 3) {
    my ($w1, $w2, $w3) = @$wires;
    delete local $diagram{$w1->[0]}{$w1->[1]};
    delete local $diagram{$w1->[1]}{$w1->[0]};
    delete local $diagram{$w2->[0]}{$w2->[1]};
    delete local $diagram{$w2->[1]}{$w2->[0]};
    delete local $diagram{$w3->[0]}{$w3->[1]};
    delete local $diagram{$w3->[1]}{$w3->[0]};

    my @cliques = cliques();

    #ddx $wires, \@cliques;

    if (@cliques == 2) {
        say "$cliques[0] * $cliques[1] == ", $cliques[0] * $cliques[1];
        exit 0;
    }
}

die "I couldn't find three wires that disconnect the diagram into two cliques.\n";
