#!perl

use strict;
use warnings;

use Test::More 'no_plan';
use Object::Array;

my $arr = Object::Array->new;
isa_ok($arr, 'Object::Array');

is $arr->size, 0;
is @{$arr}, 0;

is $arr->push(qw(a b c)), 3;
is $arr->size, 3;

is_deeply(
  [ [ @{ $arr } ], [ $arr->elements ] ],
  [ [ qw(a b c) ], [ qw(a b c) ] ],
);

$arr->[3] = "d";

is $arr->element(3), 'd';
is $#{$arr}, 3;

is $arr->shift, "a";
is shift(@{$arr}), "b";

is $arr->pop, "d";
is pop(@{$arr}), "c";

@{$arr}[2,3] = qw(g h);

ok ! $arr->exists(0);
ok ! exists $arr->[1];

delete $arr->[2];
$arr->delete(3);

is $arr->size, 0;

$arr->push(1);
is $arr->size, 1;

@{ $arr } = ();
is $arr->size, 0;

my @orig = qw(a b c);
$arr = Object::Array->new(\@orig);

is $arr->[0], "a";
is $arr->pop, "c";

is_deeply(
  \@orig,
  [ qw(a b) ],
);
