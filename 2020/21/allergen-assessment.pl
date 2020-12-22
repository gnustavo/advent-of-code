#!/usr/bin/env perl

use 5.030;
use warnings;
use Set::Scalar;

my @foods;

while (<>) {
    if (my ($ingredients, $allergens) = /([a-z ]+?) \(contains ([a-z ,]+)\)/) {
        push @foods, [[split ' ', $ingredients], [split ', ', $allergens]];
    }
}

my %processed_ingredients;
my %processed_allergens;

{
    my %allergens;
    foreach my $food (@foods) {
        my $iset = Set::Scalar->new(@{$food->[0]});
        foreach my $allergen (@{$food->[1]}) {
            if (exists $allergens{$allergen}) {
                $allergens{$allergen} = $allergens{$allergen}->intersection($iset);
            } else {
                $allergens{$allergen} = $iset;
            }
        }
    }

    while (my @uniqs = sort grep {1 == $allergens{$_}->size()} keys %allergens) {
        foreach my $allergen (@uniqs) {
            my ($ingredient) = $allergens{$allergen}->members();
            $processed_allergens{$allergen} = $ingredient;
            $processed_ingredients{$ingredient} = $allergen;
            delete $allergens{$allergen};
            $_->delete($ingredient) foreach values %allergens;
        }
    }
}

my %ingredients_sans_allergens =
    map {($_ => undef)}
    grep {! exists $processed_ingredients{$_}}
    map {@{$_->[0]}}
    @foods;

say scalar grep {exists $ingredients_sans_allergens{$_}} map {@{$_->[0]}} @foods;

say join(',', sort {$processed_ingredients{$a} cmp $processed_ingredients{$b}} keys %processed_ingredients);
