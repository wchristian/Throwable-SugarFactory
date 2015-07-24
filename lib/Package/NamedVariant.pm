package Package::NamedVariant;

use strictures 2;
use Import::Into;
use Package::Variant ();
use Module::Runtime 'module_notional_filename';
use base;

# VERSION

# ABSTRACT: wrap Package::Variant to allow naming of produced packages

# COPYRIGHT

=head1 SYNOPSIS

Set up your variable package as normal, only using P::NV instead of P::V, then
in your user class:

    use My::Variable::Package;
    
    Package Mine => ( my => "vars" ); # no need to grab the return value, as the
                                      # package name is set to "Mine"
    
    my $thing = Mine->foo; # works
    
    Package Mine => ( my => " other vars" ); # dies, because Mine already exists

=head1 DESCRIPTION

This is simply a minimal wrapper around Package::Variant that makes it possible
to create variable packages that allow explicit naming of the created variant
packages.

This should only be necessary until P::V is patched to include this
functionality directly.

=cut

sub build_variant_of {
    my ( $self, $variable, $class, @args ) = @_;

    my $path = module_notional_filename $class;
    die "Won't clobber already loaded: $path => $INC{$path}" if $INC{$path};

    base->import::into( $class, Package::Variant->build_variant_of( $variable, @args ) );

    $INC{$path} ||= sprintf 'Set by "Package::NamedVariant"';

    return $class;
}

no warnings 'once';
*import = \&Package::Variant::import;

1;
