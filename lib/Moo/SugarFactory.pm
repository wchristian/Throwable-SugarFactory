package Moo::SugarFactory;

use strictures;
use Import::Into;
use Moo::ClassBuilder;
use Constructor::SugarLibrary ();

# VERSION

# ABSTRACT: build a library of syntax-sugared classes

# COPYRIGHT

sub _getglob { no strict; \*{ $_[0] } }

sub make_named_class {
    my ( $class, @args ) = @_;

    ( my $path = $class ) =~ s/::/\//g;
    $path .= ".pm";
    die "Won't clobber already loaded: $path => $INC{$path}" if $INC{$path};

    base->import::into( $class, ClassBuilder @args );

    $INC{"$path\.pm"} ||= 'Set by "Throwable::SugarFactory::exception;" invocation';

    return;
}

sub import {
    Constructor::SugarLibrary->import::into( 1 );
    my $factory = caller;
    *{ _getglob "$factory\::class" } = sub {
        my ( $id, @args ) = @_;
        my $class = "$factory\::$id";
        my $build = $factory->can( "BUILDARGS" ) || sub { shift; @_ };
        make_named_class $class, $build->( $id, @args );
        $factory->sweeten_meth( $class );
        return;
    };
}

1;
