package Moo::RoleBuilder;

use strictures 1;
use Package::Variant
  importing => ['Moo::Role'],
  subs      => [qw(has requires with before around after)];

# VERSION

# ABSTRACT:

# COPYRIGHT

sub make_variant {
    my ( $class, $target_package, @args ) = @_;
    while ( @args ) {
        my ( $func, $args ) = ( shift @args, shift @args );
        $args = [$args] if ref $args ne "ARRAY";
        __PACKAGE__->can( $func )->( @{$args} );
    }
    return;
}

1;
