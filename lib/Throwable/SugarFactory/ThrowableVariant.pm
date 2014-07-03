package Throwable::SugarFactory::ThrowableVariant;

use strictures 1;
use Package::Variant
  importing => ['Moo::Role'],
  subs      => [qw(has around before after with)];

# VERSION

# ABSTRACT:

# COPYRIGHT

sub make_variant {
    my ( $class, $target_package, %arguments ) = @_;
    with "Throwable";
    return;
}

1;
