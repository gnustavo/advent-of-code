#!/usr/bin/env perl

use 5.030;

my %bags;

# Read input and create the 'contains' graph
while (<>) {
    my ($color, @contains) = split / bags?(?: contain|,|\.) */;
    pop @contains;
    pop @contains if $contains[-1] eq 'no other';
    my $bag = {
        color => $color,
        contains => {},
    };
    foreach (@contains) {
        my ($num, $clr) = split / /, $_, 2;
        $bag->{contains}{$clr} = $num;
    }
    $bags{$color} = $bag;
}

# Calculate the contains_total for each bag

sub contains_total {
    my ($bag) = @_;

    unless (exists $bag->{total}) {
        my $total = 0;
        while (my ($color, $num) = each %{$bag->{contains}}) {
            $total += $num * contains_total($bags{$color});
        }
        $bag->{total} = $total + 1;
    }

    return $bag->{total};
}

say contains_total($bags{'shiny gold'}) - 1;
