package MooX::BuildClass::Utils;

use strictures 2;

use Module::Runtime 'module_notional_filename';

use parent 'Exporter';

our @EXPORT_OK = qw( make_variant_package_name make_variant );

# VERSION

# ABSTRACT: methods for MooX::BuildClass and MooX::BuildRole

# COPYRIGHT

=head1 DESCRIPTION

Provides methods for L<MooX::BuildClass> and L<MooX::BuildRole>.

=head1 METHODS

=head2 make_variant_package_name

Advises Package::Variant to use the user-provided name to create the new package
in. Dies if that package has already been defined.

=cut

sub make_variant_package_name {
    my ( undef, $name ) = @_;

    my $path = module_notional_filename $name;
    die "Won't clobber already loaded: $path => $INC{$path}" if $INC{$path};

    return $name;
}

=head2 make_variant

Takes the arguments and executes them as function calls on the target package
to declare the package contents.

=cut

sub make_variant {
    my ( $class, undef, undef, @args ) = @_;
    while ( @args ) {
        my ( $func, $args ) = ( shift @args, shift @args );
        $args = [$args] if ref $args ne "ARRAY";
        $class->can( $func )->( @{$args} );
    }
    return;
}

1;
