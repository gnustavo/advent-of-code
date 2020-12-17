#!/usr/bin/env perl

use 5.030;
use warnings;
use List::AllUtils qw(sum0 any reduce all);

my (%fields, @tickets);

# Parse
while (<>) {
    chomp;
    if (my ($name, @ranges) = /([^:]+): (\d+)-(\d+) or (\d+)-(\d+)/) {
        $fields{$name} = \@ranges;
    } elsif (/^\d+(?:,\d+)*$/) {
        push @tickets, [split /,/];
    }
}

my $your_ticket = shift @tickets;

# Solve

say one();
say two();

sub one {
    return sum0 grep {! in_some_range($_)} map {@$_} @tickets;
}

sub in_some_range {
    my ($n) = @_;
    return any {in_range($n, $_)} values %fields;
}

sub in_range {
    my ($n, $ranges) = @_;
    return $ranges->[0] <= $n && $n <= $ranges->[1] || $ranges->[2] <= $n && $n <= $ranges->[3];
}

sub two {
    my @valid_tickets;
  TICKET:
    foreach my $ticket (@tickets) {
        foreach my $value (@$ticket) {
            next TICKET unless any {in_range($value, $_)} values %fields;
        }
        push @valid_tickets, $ticket;
    }
    my $indexes = find_field_indexes(\@valid_tickets, {});
    die "Cannot find indexes\n" unless defined $indexes;
    my $result =
        reduce {$a * $b} 1,
        map {$your_ticket->[$indexes->{$_}]}
        grep {$_ =~ /^departure/}
        keys %fields;
    return $result;
}

sub find_field_indexes {
    my ($tickets, $indexes) = @_;

    unless (%fields) {
        my %inverted;
        @inverted{values %$indexes} = (keys %$indexes);
        return \%inverted;
    }

    my $i = keys %$indexes;

    state $cache = {};

  FIELD:
    foreach my $name (sort keys %fields) {
        $cache->{$i}{$name} = all {in_range($_->[$i], $fields{$name})} @$tickets
            unless exists $cache->{$i}{$name};
        if ($cache->{$i}{$name}) {
            delete local $fields{$name};
            local $indexes->{$i} = $name;
            my $result = find_field_indexes($tickets, $indexes);
            return $result if defined $result;
        }
    }

    return;
}
