package Moo::SugarFactory;

use strictures 2;
use Import::Into;
use Moo::ClassBuilder;
use Constructor::SugarLibrary ();

# VERSION

# ABSTRACT: build a library of syntax-sugared Moo classes

# COPYRIGHT

=head1 SYNOPSIS

    package My::SugarLib;
    use Moo::SugarFactory;
    
    class "My::Moo::Object" => (
        has => [ plus => ( is => 'ro' ) ],
        has => [ more => ( is => 'ro' ) ],
    );
    class "My::Moose::Thing" => (
        has     => [ contains => ( is => 'ro' ) ],
        has     => [ meta     => ( is => 'ro' ) ],
        extends => Object_c(),
    );

    package My::Code;
    use My::SugarLib;
    
    my $obj = Object plus => "some", more => "data";
    die if !$obj->isa( Object_c );
    die if !$obj->plus eq "some";
    
    my $obj2 = Thing contains => "other", meta => "data", plus => "some", more => "data";
    die if !$obj2->isa( Thing_c );
    die if !$obj2->isa( Object_c );
    die if !$obj2->meta eq "data";

=cut

sub _getglob { no strict; \*{ $_[0] } }

sub import {
    Constructor::SugarLibrary->import::into( 1 );
    my $factory = caller;
    *{ _getglob "$factory\::class" } = sub {
        my ( $call, @args ) = @_;
        my ( $class ) = split /->/, $call;
        my $build = $factory->can( "BUILDARGS" ) || sub { shift; @_ };
        ClassBuilder $class, $build->( $class, @args );
        $factory->sweeten_meth( $call );
        return;
    };
}

1;
