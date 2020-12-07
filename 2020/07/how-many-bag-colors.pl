#!/usr/bin/env perl

use 5.030;

my (@bags, %bags);

sub bag {
    my ($color) = @_;
    unless (exists $bags{$color}) {
        my $bag = {
            color => $color,
            contains => [],
            is_contained_in => [],
        };
        push @bags, $bag;
        $bags{$color} = $bag;
    }
    return $bags{$color};
}

# Read input and create the 'contains' graph
while (<>) {
    my ($color, @contains) = split / bags?(?: contain|,|\.) */;
    pop @contains;
    pop @contains if $contains[-1] eq 'no other';
    my $bag = bag($color);
    foreach (@contains) {
        my ($num, $clr) = split / /, $_, 2;
        push @{$bag->{contains}}, bag($clr);
    }
}

# Create the 'is_contained_in' graph
foreach my $bag (@bags) {
    foreach my $contained_bag (@{$bag->{contains}}) {
        push @{$contained_bag->{is_contained_in}}, $bag;
    }
}

# Find all bags that eventually contain my color
my @colors_to_consider = ('shiny gold');
my %colors_considered;

while (@colors_to_consider) {
    my $considering_color = shift @colors_to_consider;
    $colors_considered{$considering_color} = undef;
    foreach my $bag (@{$bags{$considering_color}{is_contained_in}}) {
        push @colors_to_consider, $bag->{color}
            unless exists $colors_considered{$bag->{color}};
    }
}

#$,=', ';
#say sort keys %colors_considered;
say scalar(values %colors_considered) - 1;
