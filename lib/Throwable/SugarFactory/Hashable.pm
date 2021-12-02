package Throwable::SugarFactory::Hashable;

use strictures 2;
use Class::Inspector;
use Moo::Role;

# VERSION

# ABSTRACT: role provides a generic to_hash function for Throwable exceptions

# COPYRIGHT

=head1 METHODS

=head2 to_hash

Returns a hash reference containing the data of the exception.

=cut

sub to_hash {
    my ( $self ) = @_;
    my @base_methods = qw( error namespace description previous_exception );
    my %skip_methods = map { $_ => 1 } @base_methods,
      qw( BUILDALL BUILDARGS DEMOLISHALL DOES after around before does extends
      has meta new throw previous_exception to_hash with new_with_previous );
    my $methods = Class::Inspector->methods( ref $self, 'public' );
    my %data = map { $_ => $self->$_ } grep { !$skip_methods{$_} } @{$methods};
    my %out = ( data => \%data, map { $_ => $self->$_ } @base_methods );
    return \%out;
}

1;
