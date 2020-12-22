#!/usr/bin/env perl

use 5.030;
use warnings;
use List::AllUtils qw(any);
use Set::Scalar;
use Algorithm::Combinatorics qw(variations);

my @foods;

while (<>) {
    chomp;
    if (my ($ingredients, $allergens) = /([a-z ]+?) \(contains ([a-z ,]+)\)/) {
        push @foods, [[split ' ', $ingredients], [split ', ', $allergens]];
    }
}

my %all_ingredients = map {($_ => undef)} map {@{$_->[0]}} @foods;

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

my @unprocessed_foods = sort {@{$a->[1]} <=> @{$b->[1]} || @{$a->[0]} <=> @{$b->[0]}} @foods;

my $top = 0;

sub process {
    my ($line) = @_;
    return 1 if $line == @unprocessed_foods;
    my ($ingredients, $allergens) = @{$unprocessed_foods[$line]};

    my %unprocessed_ingredients = map {$_ => undef} @$ingredients;
    my %unprocessed_allergens   = map {$_ => undef} @$allergens;

    # Remove ingredients already processed with their respective allergens,
    # if present.
    foreach my $ingredient (@$ingredients) {
        if (my $allergen = $processed_ingredients{$ingredient}) {
            delete $unprocessed_ingredients{$ingredient};
            delete $unprocessed_allergens{$allergen}; # It's OK if it doesn't exist
        }
    }

    return process($line+1) if keys %unprocessed_allergens == 0;

    return 0 if keys %unprocessed_allergens > keys %unprocessed_ingredients;

    return 0 if any {exists $processed_allergens{$_}} keys %unprocessed_allergens;

    # Now there are only unprocesses foods left

    my @unprocessed_allergens = sort keys %unprocessed_allergens;

    foreach my $variation (variations([keys %unprocessed_ingredients], scalar @unprocessed_allergens)) {
        # let's try this variation
        @processed_ingredients{@$variation} = @unprocessed_allergens;
        @processed_allergens{@unprocessed_allergens} = @$variation;

        return 1 if process($line+1);

        delete @processed_ingredients{@$variation};
        delete @processed_allergens{@unprocessed_allergens};
    }
    return 0;
};

process(0) or die "Could not process all the food list\n";

my %ingredients_sans_allergens =
    map {($_ => undef)}
    grep {! exists $processed_ingredients{$_}}
    keys %all_ingredients;

my $count = 0;
foreach my $line (@foods) {
    foreach my $ingredient (@{$line->[0]}) {
        $count += 1 if exists $ingredients_sans_allergens{$ingredient};
    }
}

say "ONE = $count";

say "TWO = ", join(',', sort {$processed_ingredients{$a} cmp $processed_ingredients{$b}} keys %processed_ingredients);
