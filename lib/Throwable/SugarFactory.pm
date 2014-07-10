package Throwable::SugarFactory;

use strictures;
use Import::Into;
use Moo::SugarFactory ();

# VERSION

# ABSTRACT: build a library of syntax-sugared exceptions

# COPYRIGHT

sub _getglob { no strict; \*{ $_[0] } }

sub _base_args {
    my ( $description ) = @_;
    return (
        with => "Throwable",
        has  => [ description => ( is => 'ro', default => $description ) ]
    );
}

sub import {
    Moo::SugarFactory->import::into( 1 );
    my $factory = caller;
    *{ _getglob "$factory\::exception" } = sub {
        my ( $id, $description, @args ) = @_;
        $factory->can( "class" )->( $id, _base_args( $description ), @args );
    };
}

1;
