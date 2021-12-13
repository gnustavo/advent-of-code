#!/usr/bin/env perl

use 5.016;
use common::sense;

my %map;

while (<>) {
    chomp;
    my ($from, $to) = split '-';
    $map{$from}{$to} = $map{$to}{$from} = undef;
}

my %visits = map {$_ => 0} keys %map;

my @paths;
my @path = qw/start/;

sub collect_paths_from {
    my ($from) = @_;

    if ($from eq 'end') {
        push @paths, [@path];
        #warn join(',', @path), "\n";
        return;
    }

    local $visits{$from} = $visits{$from} + 1;

    foreach my $to (keys %{$map{$from}}) {
        if ($to eq 'start') {
            # let's not get back to the start
            next;
        } elsif ($to =~ /^[a-z]+$/) {
            # small cave
            next if $visits{$to} > 0;
        } else {
            # big cave
            warn "Visited '$to' $visits{$to} times\n" if $visits{$to} > 10;
        }
        push @path, $to;
        collect_paths_from($to);
        pop @path;
    }

    return;
}

collect_paths_from('start');

say scalar @paths;

@paths = ();
@path = qw/start/;
my $small_limit = 2;

sub collect_paths_from2 {
    my ($from) = @_;

    if ($from eq 'end') {
        push @paths, [@path];
        #warn join(',', @path), "\n";
        return;
    }

    local $visits{$from} = $visits{$from} + 1;
    my $reduce_limit = $visits{$from} == 2 && $from =~ /^[a-z]+$/;
    $small_limit = 1 if $reduce_limit;

    foreach my $to (keys %{$map{$from}}) {
        if ($to eq 'start') {
            # let's not get back to the start
            next;
        } elsif ($to =~ /^[a-z]+$/) {
            # small cave
            next if $visits{$to} >= $small_limit;
        } else {
            # big cave
            warn "Visited '$to' $visits{$to} times\n" if $visits{$to} > 10;
        }
        push @path, $to;
        collect_paths_from2($to);
        pop @path;
    }

    $small_limit = 2 if $reduce_limit;

    return;
}

collect_paths_from2('start');

say scalar @paths;
