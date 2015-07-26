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
        my ( $t_spec, $description, @args ) = @_;
        my ( $id, $ct ) = split / /, $t_spec;
        my @defaults = _base_args( $factory, $id, $description );
        my $s_spec = "${factory}::$id->throw";
        $s_spec .= " $ct" if $ct;
        $factory->can( "class" )->( $s_spec, @defaults, @args );
    };
}

1;
