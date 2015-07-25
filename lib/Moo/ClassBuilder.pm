package Moo::ClassBuilder;

use strictures 2;
use Package::Variant 1.003002    #
  importing => ['Moo'],
  subs      => [qw(extends has with before around after)];
use Module::Runtime 'module_notional_filename';

# VERSION

# ABSTRACT: build a Moo class at runtime

# COPYRIGHT

=head1 SYNOPSIS

    use Moo::ClassBuilder;
        
    ClassBuilder "Cat::Food" => (
        
        install => [
            feed_lion => sub {
                my $self = shift;
                my $amount = shift || 1;
                
                $self->pounds( $self->pounds - $amount );
            },
        ],
        
        has => [ taste => ( is => 'ro', ) ],
        
        has => [
            brand => (
                is  => 'ro',
                isa => sub {
                    die "Only SWEET-TREATZ supported!" unless $_[0] eq 'SWEET-TREATZ';
                },
            )
        ],
        
        has => [
            pounds => (
                is  => 'rw',
                isa => sub { die "$_[0] is too much cat food!" unless $_[0] < 15 },
            )
        ],
        
        extends => "Food",
        
    );

    1;

=head1 DESCRIPTION

Provides a runtime interface to create Moo classes. Takes a class name and a
pair-list of parameters used to create the class. The pairs are always in the
form of ( function => arguments ), where arguments has to be a single scalar. It
can be either an array-ref, or if it is not one, it will be wrapped in one.
C<function> can be a string from this list:

extends  has  with  before  around  after  install

The obvious ones are proxies for the corresponding Moo class setup functions,
and install is used to set up methods.

=cut

sub make_variant_package_name {
    my ( undef, $name ) = @_;

    my $path = module_notional_filename $name;
    die "Won't clobber already loaded: $path => $INC{$path}" if $INC{$path};

    return $name;
}

sub make_variant {
    my ( $class, undef, undef, @args ) = @_;
    while ( @args ) {
        my ( $func, $args ) = ( shift @args, shift @args );
        $args = [$args] if ref $args ne "ARRAY";
        __PACKAGE__->can( $func )->( @{$args} );
    }
    return;
}

1;
