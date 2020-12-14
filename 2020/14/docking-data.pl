#!/usr/bin/env perl

use 5.030;
use warnings;
no warnings 'portable';
use List::Util qw(sum0);

my @input = <>;

sub one {
    my $set_mask   =  0;
    my $clear_mask = ~0;
    my %mem;

    foreach (@input) {
        if (/mask = (?<bits>[01X]{36})/) {
            $set_mask   = oct('0b' . '0' x 18 . $+{bits} =~ tr/X/0/r);
            $clear_mask = oct('0b' . '1' x 18 . $+{bits} =~ tr/X/1/r);
        } elsif (/mem\[(?<address>\d+)\] = (?<value>\d+)/) {
            $mem{$+{address}} = ($+{value} | $set_mask) & $clear_mask;
        } else {
            die "$.: Invalid instruction: $_";
        }
    }

    return sum0(values %mem);
}

sub two {
    my $set_mask   = 0;
    my @float_bits = ();
    my %mem;

    my $set_float_bits = sub {
        my ($string) = @_;
        @float_bits = ();
        for (my $i = 0; length $string; $i += 1) {
            unshift @float_bits, $i if substr($string, -1, 1, '') eq 'X';
        }
    };

    my $store = sub {
        my ($address, $value) = @_;

        $address |= $set_mask;

        my $store_floating = sub {
            my ($addr, @bits) = @_;
            if (@bits) {
                my $bit = shift @bits;
                __SUB__->($addr & ~(1 << $bit), @bits);
                __SUB__->($addr |  (1 << $bit), @bits);
            } else {
                $mem{$addr} = $value;
            }
        };

        $store_floating->($address, @float_bits);
    };

    foreach (@input) {
        if (/mask = (?<bits>[01X]{36})/) {
            $set_mask = oct('0b' . '0' x 18 . $+{bits} =~ tr/X/0/r);
            $set_float_bits->($+{bits});
        } elsif (my ($address, $value) = /mem\[(\d+)\] = (\d+)/) {
            $store->($address, $value);
        } else {
            die "$.: Invalid instruction: $_";
        }
    }

    return sum0(values %mem);
}

say one();
say two();
