package Throwable::SugarFactory;

use strictures 2;
use Import::Into;
use MooX::SugarFactory ();
use Throwable::SugarFactory::_Utils qw'_array _getglob';

# VERSION

# ABSTRACT: build a library of syntax-sugared Throwable-based exceptions

# COPYRIGHT

=head1 SYNOPSIS

    package My::SugarLib;
    use Throwable::SugarFactory;
    
    exception PlainError => "a generic error without metadata";
    exception DataError  => "data description" =>
      has => [ flub => ( is => 'ro' ) ];
    exception [ Custom => "make" ] => "has a custom constructor";

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
    
    try {
        die make;
    }
    catch {
        die if !$_->isa( Custom );
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
        my ( $spec, $description, @args ) = @_;
        $spec = _array $spec;
        my @defaults = _base_args( $factory, $spec->[0], $description );
        $spec->[0] = "${factory}::$spec->[0]->throw";
        $factory->can( "class" )->( $spec, @defaults, @args );
    };
}

1;
