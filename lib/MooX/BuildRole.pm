package MooX::BuildRole;

use strictures 2;
use Moo::Role 1.004000 ();    # required to get %INC-marking
use Package::Variant 1.003002 #
  importing => ['Moo::Role'],
  subs      => [qw(extends has with before around after requires)];

use MooX::BuildClass::Utils qw( make_variant_package_name make_variant );

# VERSION

# ABSTRACT: build a Moo role at runtime

# COPYRIGHT

=head1 DESCRIPTION

Sister module to L<MooX::BuildClass>, is used identically, but creates roles,
not classes.

Additional exported function is:

requires

Unsupported function is:

extends

=cut

1;
