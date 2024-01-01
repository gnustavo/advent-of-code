#!/usr/bin/env perl

use 5.034;
use strict;
use warnings;
use Data::Dump;

#my ($min, $max) = (7, 27);
my ($min, $max) = (200000000000000, 400000000000000);

my @hailstones;
while (<>) {
    chomp;
    if (/(\d+), (\d+), (\d+) @\s+(-?\d+),\s+(-?\d+),\s+(-?\d+)/) {
        push @hailstones, [[$1, $2, $3], [0+$4, 0+$5, 0+$6]]; # position, velocity
    }
}

ddx \@hailstones;

my $nof_cross_inside = 0;

for (my $i=0; $i < @hailstones; ++$i) {
    my $ihs = $hailstones[$i];
    my ($ipx, $ipy) = $ihs->[0]->@[0, 1];
    my ($ivx, $ivy) = $ihs->[1]->@[0, 1];

    for (my $j=$i+1; $j < @hailstones; ++$j) {
        my $jhs = $hailstones[$j];
        my ($jpx, $jpy) = $jhs->[0]->@[0, 1];
        my ($jvx, $jvy) = $jhs->[1]->@[0, 1];
        #ddx $i, $j;

        # [$ipx + $ivx*$it, $ipy + $ivy*$it] == [$jpx + $jvx*$jt, $jpy + $jvy*$jt]
        # $ipx + $ivx*$it == $jpx + $jvx*$jt
        # $ivx*$it - $jvx*$jt == $jpx - $ipx
        # $ivy*$it - $jvy*$jt == $jpy - $ipy

        # $it == ($jpy - $ipy + $jvy*$jt) / $ivy
        # $ivx*(($jpy - $ipy + $jvy*$jt) / $ivy) - $jvx*$jt == $jpx - $ipx
        # ($ivx/$ivy)*($jpy - $ipy + $jvy*$jt) - $jvx*$jt == $jpx - $ipx
        # $ivD = $ivx / $ivy
        # $jvD = $jvx / $jvy
        # $ivD*($jpy - $ipy + $jvy*$jt) - $jvx*$jt == $jpx - $ipx
        # $ivD*($jpy - $ipy) + ($ivD*$jvy - $jvx)*$jt == $jpx - $ipx
        # $jt = ($jpx - $ipx - $ivD*($jpy - $ipy)) / ($ivD*$jvy - $jvx)

        # avoid division by zero
        if ($ivy == 0) {
            #warn "ivy == 0\n";
            next;
        }

        my $ivD = $ivx / $ivy;

        my $denominator = $ivD*$jvy - $jvx;

        if ($denominator == 0) {
            #warn "denominator == 0\n";
            next;
        }

        my $jt = ($jpx - $ipx - $ivD*($jpy - $ipy)) / $denominator;
        if ($jt < 0) {
            #warn "Paths crossed in the past for j($jt)\n";
            next;
        }
        my $it = ($jpy - $ipy + $jvy*$jt) / $ivy;
        if ($it < 0) {
            #warn "Paths crossed in the past for i($it)\n";
            next;
        }

        #warn "it==$it, jt==$jt\n";

        my $ix = $ipx + $ivx*$it;
        my $iy = $ipy + $ivy*$it;
        my $jx = $jpx + $jvx*$jt;
        my $jy = $jpy + $jvy*$jt;

        #warn "crossings => [$ix, $iy], [$jx, $jy]\n";

        if ($jx < $min || $jx > $max) {
            #warn "jx($jx) is outside the test area\n";
            next;
        }
        if ($jy < $min || $jy > $max) {
            #warn "jy($jy) is outside the test area\n";
            next;
        }
        if ($ix < $min || $ix > $max) {
            #warn "ix($ix) is outside the test area\n";
            next;
        }
        if ($iy < $min || $iy > $max) {
            #warn "iy($iy) is outside the test area\n";
            next;
        }

        $nof_cross_inside += 1;

        #warn "nof_cross_inside == $nof_cross_inside\n";
    }
}

say $nof_cross_inside;
