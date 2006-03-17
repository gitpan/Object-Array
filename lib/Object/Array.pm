package Object::Array;

use strict;
use warnings;
use Scalar::Util ();

use 5.006001;

=head1 NAME

Object::Array - array references with accessors

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

  use Object::Array;
  my $array = Object::Array->new; # or
  $array = Object::Array->new(\@array);
  $array->push(1..5);
  print $array->shift;
  $_++ for grep { $_ < 4 } @{ $array };
  $array->[0] = "a pony";

=head1 METHODS

=head2 C<< new >>

  my $array = Object::Array->new;
  # or use existing array
  my $array = Object::Array->new(\@a);

Creates a new array object, either from scratch or from an
existing array.

Using an existing array will mean that any changes to C<<
$array >> also affect the original array object.  If you
don't want that, copy the data first or use something like
Storable's C<< dclone >>.

=cut

my %real;

sub _addr { Scalar::Util::refaddr($_[0]) }

sub _real { $real{shift->_addr} }
  
sub new {
  my $class = shift;
  my $real  = shift || [];

  my @array;
  my $self  = bless \@array => $class;
  tie @array, $class."::Tie", $self;
  
  $real{$self->_addr} = $real;

  return $self;
}

=head2 C<< size >>

=head2 C<< length >>

Returns the number of elements in the array.

C<< size >> and C<< length >> are synonyms.

=head2 C<< element >>

=head2 C<< elem >>

  print $array->elem(0);
  print $array->[0];

Get a single element's value.

  $array->elem(1 => "hello");
  $array->[1] = "hello";

Set a single element's value.

  print for $array->elem([ 0, 1, 2 ]);
  print for @{$array}[0,1,2];

Get multiple values.

  $array->elem([ 0, 1, 2 ] => [ qw(a b c) ]);
  @{$array}[0,1,2] = qw(a b c);

Set multiple values.

C<< element >> and C<< elem >> are synonyms.

=head2 C<< elements >>

=head2 C<< elems >>

=head2 C<< all >>

Shortcut for all values in the array.

C<< elements >>, C<< elems >>, and C<< all >> are synonyms.

NOTE: Using methods in a for/map/etc. will not do aliasing
via $_.  Use array dereferencing if you need to do this, e.g.

  $_++ for @{$array};

=head2 C<< clear >>

Erase the array.  The following all leave the array empty:

  $array->size(0);
  $array->clear;
  @{ $array } = ();

=head2 C<< push >>

=head2 C<< pop >>

=head2 C<< shift >>

=head2 C<< unshift >>

=head2 C<< exists >>

=head2 C<< delete >>

=head2 C<< splice >>

As the builtin array operations of the same names.

=cut

sub size {
  my $self = shift;
  if (@_) {
    $#{ $self->_real } = shift(@_) - 1;
  }
  return scalar @{ $self->_real };
}

*length = \*size;

sub elem {
  my $self = shift;
  unless (@_) {
    require Carp;
    Carp::croak("must specify index for element lookup");
  }

  my $idx  = shift || 0;

  if (ref $idx eq 'ARRAY') {
    # since tying can deal with this, might as well let it
    # do so
    if (@_) {
      return @{ $self }[ @$idx ] = @{ +shift };
    } else {
      return @{ $self }[ @$idx ];
    }
  }

  if (@_) {
    $self->_real->[$idx] = shift;
  }
  return $self->_real->[$idx];
}
*element = \&elem;

sub elems   { @{ shift->_real } }

*all = *elements = \&elems;

sub clear   { @{ shift->_real } = () }

sub pop     { pop @{ shift->_real } }

sub push    { push @{ shift->_real }, @_ }

sub unshift { unshift @{ shift->_real }, @_ }

sub exists  { exists shift->_real->[shift] }

sub delete  { delete shift->_real->[shift] }

sub splice  { splice @{ shift->_real }, @_ }

# shift goes last to avoid annoying warnings
sub shift   { shift @{ shift->_real } }

=head1 AUTHOR

Hans Dieter Pearcey, C<< <hdp at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-object-array at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Object-Array>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Object::Array

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Object-Array>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Object-Array>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Object-Array>

=item * Search CPAN

L<http://search.cpan.org/dist/Object-Array>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Hans Dieter Pearcey, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

package Object::Array::Tie;

sub TIEARRAY {
  my ($class, $obj) = @_;
  bless \$obj => $class;
}

sub FETCHSIZE { ${+shift}->size }
sub STORESIZE { ${+shift}->size(shift) }
sub STORE     { ${+shift}->elem(shift, shift) }
sub FETCH     { ${+shift}->elem(shift) }
sub CLEAR     { ${+shift}->clear }
sub POP       { ${+shift}->pop }
sub PUSH      { ${+shift}->push(@_) }
sub SHIFT     { ${+shift}->shift }
sub UNSHIFT   { ${+shift}->unshift(@_) }
sub EXISTS    { ${+shift}->exists(shift) }
sub DELETE    { ${+shift}->delete(shift) }
sub SPLICE    { ${+shift}->splice(@_) }
sub EXTEND    { () }

1; # End of Object::Array
