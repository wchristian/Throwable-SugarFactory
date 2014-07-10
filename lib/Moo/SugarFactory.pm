package Moo::SugarFactory;

use strictures;
use Import::Into;
use Moo::RoleBuilder;
use Constructor::SugarLibrary ();

# VERSION

# ABSTRACT: build a library of syntax-sugared classes

# COPYRIGHT

sub _getglob { no strict; \*{ $_[0] } }

sub make_class_from_role {
    my ( $class, @args ) = @_;

    my $role = RoleBuilder @args;

    ( my $path = $class ) =~ s/::/\//g;
    $path .= ".pm";
    die "Won't clobber already loaded: $path => $INC{$path}" if $INC{$path};

    require Moo;
    Moo->import::into( $class, qw(with) );
    $class->can( "with" )->( $role );

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
        make_class_from_role $class, $build->( $id, @args );
        $factory->sweeten_meth( $class );
        return;
    };
}

1;
