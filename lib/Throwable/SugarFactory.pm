package Throwable::SugarFactory;

use strictures;
use Import::Into;
use Throwable::SugarFactory::ThrowableVariant;
use base 'Exporter';

our @EXPORT = qw( exception );

# VERSION

# ABSTRACT: build a sweet exception library

# COPYRIGHT

sub import {
    shift->export_to_level( 1 );
    base->import::into( 1, "Exporter" );
    vars->import::into( 1, '@EXPORT_OK' );
}

sub _getglob   { no strict; \*{ $_[0] } }
sub _getexport { no strict; \@{"$_[0]\::EXPORT_OK"} }

sub exception {
    my ( $id ) = @_;
    my $pkg    = caller;
    my $name   = "$pkg\::$id";
    my $role   = ThrowableVariant();
    make_class( $name, $role );
    push @{ _getexport $pkg}, $id, "$id\_c";
    *{ _getglob $name } = sub { $name->new( @_ ) };
    *{ _getglob "$name\_c" } = sub { $name };
    return;
}

sub make_class {
    my ( $name, $role ) = @_;

    ( my $path = $name ) =~ s/::/\//g;
    $path .= ".pm";
    die "Won't clobber already loaded: $path => $INC{$path}" if $INC{$path};

    require Moo;
    Moo->import::into( $name, qw(with) );
    *{ _getglob "$name\::with" }->( $role );

    $INC{"$path\.pm"} ||= 'Set by "Throwable::SugarFactory::exception;" invocation';

    return;
}

1;
