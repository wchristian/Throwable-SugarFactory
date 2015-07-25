package MooX::SugarFactory;

use strictures 2;
use Import::Into;
use MooX::BuildClass;
use Constructor::SugarLibrary ();

# VERSION

# ABSTRACT: build a library of syntax-sugared Moo classes

# COPYRIGHT

=head1 SYNOPSIS

    package My::SugarLib;
    use MooX::SugarFactory;
    
    class "My::Moo::Object" => (
        has => [ plus => ( is => 'ro' ) ],
        has => [ more => ( is => 'ro' ) ],
    );
    
    class "My::Moose::Thing" => (
        has     => [ contains => ( is => 'ro' ) ],
        has     => [ meta     => ( is => 'ro' ) ],
        extends => Object(),
    );

    package My::Code;
    use My::SugarLib;
    
    my $obj = object plus => "some", more => "data";
    die if !$obj->isa( Object );
    die if !$obj->plus eq "some";
    
    my $obj2 = thing contains => "other", meta => "data",    #
      plus => "some", more => "data";
    
    die if !$obj2->isa( Thing );
    die if !$obj2->isa( Object );
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
        BuildClass $class, $build->( $class, @args );
        $factory->sweeten_meth( $call );
        return;
    };
}

1;
