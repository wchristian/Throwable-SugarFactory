package Throwable::SugarFactory;

use strictures 2;
use Import::Into;
use Moo::SugarFactory ();

# VERSION

# ABSTRACT: build a library of syntax-sugared Throwable-based exceptions

# COPYRIGHT

=head1 SYNOPSIS

    package My::SugarLib;
    use Throwable::SugarFactory;
    
    exception PLAIN_ERROR => "a generic error without metadata";
    exception DATA_ERROR => "data description" => (
        has => [ flub => ( is => 'ro' ) ]
    );

    package My::Code;
    use My::SugarLib;
    use Try::Tiny;
    
    try {
        die PLAIN_ERROR
    }
    catch {
        die if !$_->isa( PLAIN_ERROR_c );
    };
    
    try {
        die DATA_ERROR flub => 'blarb'
    }
    catch {
        die if !$_->isa(DATA_ERROR_c );
        die if $_->flub ne 'blarb';
    };

=cut

sub _getglob { no strict; \*{ $_[0] } }

sub _base_args {
    my ( $namespace, $error, $description ) = @_;
    return (
        with => [ "Throwable", __PACKAGE__ . "::Hashable" ],
        has  => [ namespace => ( is => 'ro', default => $namespace ) ],
        has  => [ error => ( is => 'ro', default => $error ) ],
        has  => [ description => ( is => 'ro', default => $description ) ],
    );
}

sub import {
    Moo::SugarFactory->import::into( 1 );
    my $factory = caller;
    *{ _getglob "$factory\::exception" } = sub {
        my ( $id, $description, @args ) = @_;
        my $class = "$factory\::$id";
        $factory->can( "class" )->(
            "$class->throw", _base_args( $factory, $id, $description ), @args
        );
    };
}

1;
