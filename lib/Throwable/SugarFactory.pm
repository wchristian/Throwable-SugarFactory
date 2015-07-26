package Throwable::SugarFactory;

use strictures 2;
use Import::Into;
use MooX::SugarFactory ();
use Throwable::SugarFactory::_Utils '_getglob';

# VERSION

# ABSTRACT: build a library of syntax-sugared Throwable-based exceptions

# COPYRIGHT

=head1 SYNOPSIS

    package My::SugarLib;
    use Throwable::SugarFactory;
    
    exception PlainError => "a generic error without metadata";
    exception DataError  => "data description" =>
      has => [ flub => ( is => 'ro' ) ];

    package My::Code;
    use My::SugarLib;
    use Try::Tiny;
    
    try {
        die plain_error;
    }
    catch {
        die if !$_->isa( PlainError );
    };
    
    try {
        die data_error flub => 'blarb';
    }
    catch {
        die if !$_->isa( DataError );
        die if $_->flub ne 'blarb';
    };

=cut

sub _base_args {
    my ( $namespace, $error, $description ) = @_;
    return (
        with => [ "Throwable", __PACKAGE__ . "::Hashable" ],
        has => [ namespace   => ( is => 'ro', default => $namespace ) ],
        has => [ error       => ( is => 'ro', default => $error ) ],
        has => [ description => ( is => 'ro', default => $description ) ],
    );
}

sub import {
    MooX::SugarFactory->import::into( 1 );
    my $factory = caller;
    *{ _getglob $factory, "exception" } = sub {
        my ( $id, $description, @args ) = @_;
        my $class = "${factory}::$id";
        $factory->can( "class" )->(
            "$class->throw", _base_args( $factory, $id, $description ), @args
        );
    };
}

1;
