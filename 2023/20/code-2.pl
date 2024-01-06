#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;
$Data::Dump::LINEWIDTH = 10240;
use List::Util qw(all);

my %modules;
while (<>) {
    chomp;
    if (my ($type, $name, $destinations) = (/^([%&]?)([a-z]+) -> (.+)$/)) {
        $modules{$name} = {
            name => $name,
            type => $type,
            destinations => [split ', ', $destinations],
        };
    }
}

my @circuit;                    # list of [from, to, pulse]

my %types = (
    '' => sub {                 # broadcast
        my ($module) = @_;
        return sub {
            my ($from, $pulse) = @_;
            # broadcast the pulse to every destination
            push @circuit, map {[$module->{name}, $_, $pulse]} $module->{destinations}->@*;
            return;
        };
    },
    '%' => sub {                # flip-flop
        my ($module) = @_;
        $module->{state} = 0;
        return sub {
            my ($from, $pulse) = @_;
            return if $pulse;
            if ($module->{state}) {
                $module->{state} = 0;
                push @circuit, map {[$module->{name}, $_, 0]} $module->{destinations}->@*;
            } else {
                $module->{state} = 1;
                push @circuit, map {[$module->{name}, $_, 1]} $module->{destinations}->@*;
            }
            return;
        };
    },
    '&' => sub {                # conjunction
        my ($module) = @_;
        $module->{inputs} = {};
        return sub {
            my ($from, $pulse) = @_;
            # remember last pulse received by each module
            $module->{inputs}{$from} = $pulse;
            push @circuit, map {[$module->{name}, $_, ((all {$_} values $module->{inputs}->%*) ? 0 : 1)]} $module->{destinations}->@*;
            return;
        };
    },
);

# Add semantics to the modules
while (my ($name, $module) = each %modules) {
    $module->{work} = $types{$module->{type}}->($module);
}
while (my ($name, $module) = each %modules) {
    $_->{inputs}{$name} = 0
        foreach
        grep {$_->{type} eq '&'}
        map {$modules{$_}}
        grep {exists $modules{$_}}
        $module->{destinations}->@*
        ;
}

#ddx \%modules;

my $rx_on = 0;

for (my $nof_presses=1; 1; ++$nof_presses) {
    @circuit = (['button', 'broadcaster', 0]);
    while (my $event = shift @circuit) {
        my ($from, $to, $pulse) = @$event;
        #dd $event;
        $modules{$to}{work}->($from, $pulse)
            if exists $modules{$to};
        if ($to eq 'rx' && $pulse == 0) {
            say "rx_on = 1";
            $rx_on = 1;
        }
    }
    if ($rx_on) {
        say "final = $nof_presses";
        last;
    }
    if ($nof_presses % 1000 == 0) {
        say $nof_presses;
    }
}
