#!/usr/bin/env perl

use 5.030;
use warnings;
no warnings 'recursion';
use List::AllUtils qw(before after);

# Parse input

chomp(my @input = <>);

my @rules    = before {length == 0} @input;
my @messages = after {length == 0} @input;

# Process

say one();
say two();

sub one {
    return scalar grep {match($_)} @messages;
}

sub two {
    return scalar grep {match2b($_)} @messages;
}

sub match {
    my ($message) = @_;

    $message = [split //, $message];

    state $rules = grok_rules();

    my $match_at = sub {
        my ($rule_id, $index) = @_;
        my $prefix = ' ' x (2*$index);
        my $exp = $rules->{$rule_id};
        if (ref $exp) {
          ALTERNATIVE:
            foreach my $alternative (@$exp) {
                my $next_index = $index;
                foreach my $id (@$alternative) {
                    next ALTERNATIVE unless $next_index = __SUB__->($id, $next_index);
                }
                return $next_index;
            }
            return 0;
        } else {
            if ($exp eq $message->[$index]) {
                return $index+1;
            } else {
                return 0;
            }
        }
    };

    return $match_at->(0, 0) == @$message;
}

sub grok_rules {
    my %rules;
    foreach (@rules) {
        if (my ($id, $exp) = split /:\s*/) {
            if ($exp =~ /"(.)"/) {
                $rules{$id} = $1;
            } else {
                $rules{$id} = [map {[split / /, $_]} split(/\s*\|\s*/, $exp)];
            }
        }
    }
    return \%rules;
}

sub match_descending {
    my ($message) = @_;

    state $parser = parser();
    return defined $parser->r0($message);
}

sub parser {
    my %rules;
    foreach (@rules) {
        my ($id, $exp) = split /:\s*/;
        $rules{$id} = $exp;
    }
    my @grammar;
    while (my ($id, $exp) = each %rules) {
        $exp =~ s/(\d+)/r$1/g unless $exp =~ /"/;
        push @grammar, "r$id: $exp";
    }

    my $grammar = join "\n", sort @grammar;

    return Parse::RecDescent->new($grammar);
}

sub match2 {
    my ($message) = @_;

    $message = [split //, $message];

    state $grammar = grok_rules();

    my $match_at = sub {
        my ($index, $rules) = @_;
        if ($index == @$message || @$rules == 0) {
            return $index == @$message && @$rules == 0;
        }
        my $rule = shift @$rules;
        if (ref $rule) {
            foreach my $alt (@$rule) {
                unshift @$rules, @$alt;
                if (__SUB__->($index, $rules)) {
                    return 1;
                }
                splice @$rules, 0, scalar(@$alt);
            }
        } elsif ($rule =~ /\d/) {
            unshift @$rules, $grammar->{$rule};
            if (__SUB__->($index, $rules)) {
                return 1;
            } else {
                shift @$rules;
            }
        } elsif ($rule eq $message->[$index]) {
            if (__SUB__->($index+1, $rules)) {
                return 1;
            }
        }
        unshift @$rules, $rule;
        return 0;
    };

    return $match_at->(0, [0]);
}

sub match2b {
    my ($message) = @_;

    $message = [split //, $message];

    state $grammar = grok_rules();

    my $match_at = sub {
        my ($index, $rules) = @_;
        if ($index == @$message || @$rules == 0) {
            return $index == @$message && @$rules == 0;
        }
        my $rule = shift @$rules;
        if (ref $rule) {
            foreach my $alt (@$rule) {
                unshift @$rules, @$alt;
                if (__SUB__->($index, $rules)) {
                    return 1;
                }
                splice @$rules, 0, scalar(@$alt);
            }
        } elsif ($rule =~ /\d/) {
            my $hack = $grammar->{$rule};
            my $n = 1;
            if ($rule eq '8') {
                $hack = [
                    [42],
                    [42, 42],
                    [42, 42, 42],
                    [42, 42, 42, 42],
                    [42, 42, 42, 42, 42],
                    [42, 42, 42, 42, 42, 42],
                    [42, 42, 42, 42, 42, 42, 42],
                    [42, 42, 42, 42, 42, 42, 42, 42],
                    [42, 42, 42, 42, 42, 42, 42, 42, 42],
                    [42, 42, 42, 42, 42, 42, 42, 42, 42, 42],
                    [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42],
                    [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42],
                    [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42],
                    [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42],
                    [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42],
                    [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42],
                ];
                $n = 16;
            } elsif ($rule eq '11') {
                $hack = [
                    [42, 31],
                    [42, 42, 31, 31],
                    [42, 42, 42, 31, 31, 31],
                    [42, 42, 42, 42, 31, 31, 31, 31],
                    [42, 42, 42, 42, 42, 31, 31, 31, 31, 31],
                    [42, 42, 42, 42, 42, 42, 31, 31, 31, 31, 31, 31],
                    [42, 42, 42, 42, 42, 42, 42, 31, 31, 31, 31, 31, 31, 31],
                    [42, 42, 42, 42, 42, 42, 42, 42, 31, 31, 31, 31, 31, 31, 31, 31],
                    [42, 42, 42, 42, 42, 42, 42, 42, 42, 31, 31, 31, 31, 31, 31, 31, 31, 31],
                    [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31],
                    [42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31, 31],
                ];
                $n = 11;
            }
            unshift @$rules, $hack;
            if (__SUB__->($index, $rules)) {
                return 1;
            } else {
                splice @$rules, 0, $n;
            }
        } elsif ($rule eq $message->[$index]) {
            if (__SUB__->($index+1, $rules)) {
                return 1;
            }
        }
        unshift @$rules, $rule;
        return 0;
    };

    return $match_at->(0, [0]);
}

sub match3 {
    my ($message) = @_;

    state $grammar = grok_rules();

    my $matches = sub {
        my ($rule, $tails) = @_;

        my $exp = $grammar->{$rule};
        my %newtails;
        foreach my $tail (keys %$tails) {
            if (ref $exp) {
              ALTERNATIVE:
                foreach my $alt (@$exp) {
                    my $alt_tails = $tails;
                    foreach my $id (@$alt) {
                        $alt_tails = __SUB__->($id, $alt_tails);
                        next ALTERNATIVE unless %$alt_tails;
                    }
                    $newtails{$_} = undef foreach keys %$alt_tails;
                }
            } else {
                if ($exp eq substr($tail, 0, 1)) {
                    $newtails{substr($tail, 1)} = undef;
                }
            }
        }
        return \%newtails;
    };

    my $tails = $matches->(0, {$message => undef});
    return exists $tails->{''};
}
