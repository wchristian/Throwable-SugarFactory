package Throwable::SugarFactory::Hashable;

use strictures 2;
use Class::Inspector;
use Moo::Role;

sub to_hash {
    my ( $self ) = @_;
    my @base_methods = qw( error namespace description previous_exception );
    my %skip_methods = map { $_ => 1 } @base_methods,
      qw( BUILDALL BUILDARGS DEMOLISHALL DOES after around before does extends
      has meta new throw previous_exception to_hash with );
    my $methods = Class::Inspector->methods( ref $self, 'public' );
    my %data = map { $_ => $self->$_ } grep { !$skip_methods{$_} } @{$methods};
    my %out = ( data => \%data, map { $_ => $self->$_ } @base_methods );
    return \%out;
}

1;
