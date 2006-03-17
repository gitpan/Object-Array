package Object::Array::Plugin::ListMoreUtils;

use strict;
use warnings;

our @UTILS;
BEGIN {
  @UTILS = qw(
             any
             all
             none
             notall
             true
             false
             firstidx first_index
             lastidx  last_index
             insert_after
             insert_after_string
             apply
             after
             after_incl
             before
             before_incl
             indexes
             firstval first_value
             lastval  last_value
             natatime
             uniq
             minmax
           );
}

use List::MoreUtils ();
use Sub::Install ();
use Sub::Exporter -setup => {
  exports => \@UTILS,
};

my %NEED_REF = (
  map { $_ => 1 }
    qw(
       insert_after
       insert_after_string
     ),
);

=head1 NAME

Object::Array::Plugin::ListMoreUtils

=head1 DESCRIPTION

Add methods to Object::Array corresponding to functions from List::MoreUtils.

=head1 METHODS

See List::MoreUtils for details of these methods (functions).

=head2 C<< any >>

=head2 C<< all >>

=head2 C<< none >>

=head2 C<< notall >>

=head2 C<< true >>

=head2 C<< false >>

=head2 C<< firstidx >>

=head2 C<< first_index >>

=head2 C<< lastidx >>

=head2 C<< last_index >>

=head2 C<< insert_after >>

=head2 C<< insert_after_string >>

=head2 C<< apply >>

=head2 C<< after >>

=head2 C<< after_incl >>

=head2 C<< before >>

=head2 C<< before_incl >>

=head2 C<< indexes >>

=head2 C<< firstval >>

=head2 C<< first_value >>

=head2 C<< lastval >>

=head2 C<< last_value >>

=head2 C<< natatime >>

=head2 C<< uniq >>

=head2 C<< minmax >>

=head1 BROKEN

Currently these methods are not working:

=over

=item * insert_after

=item * insert_after_string

=back

=cut

BEGIN {
  for my $util (@UTILS) {
    no strict 'refs';
    Sub::Install::install_sub({
      as   => $util,
      code => sub {
        my $self = shift;
        &{"List::MoreUtils::$util"}(
          @_,
          $NEED_REF{$util} ? $self : @{ $self },
        );
      },
    });
  }
}

1;
