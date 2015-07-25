package Constructor::Sugar;

use strictures 2;

use String::CamelCase 'decamelize';

# VERSION

# ABSTRACT: export constructor syntax sugar

# COPYRIGHT

=head1 SYNOPSIS

    { package My::Moo::Object; use Moo; has $_, is => 'ro' for qw( plus more ) }
    
    {
        package BasicSyntax;
        
        my $o = My::Moo::Object->new( plus => "some", more => "data" );
        die if !$o->isa( "My::Moo::Object" );
    }
    
    {
        package ConstructorWrapper;
        use Constructor::Sugar 'My::Moo::Object';
        
        my $o = object plus => "some", more => "data";
        die if !$o->isa( Object );
        die if Object ne "My::Moo::Object";
    }

=cut

sub _getglob { no strict; \*{ $_[0] } }

sub _export {
    my ( $pkg, $func, $code ) = @_;
    *{ _getglob "$pkg\::$func" } = $code;
    return $func;
}

sub import {
    my ( undef, @args ) = @_;
    my $target = caller;
    my ( @constructors, @iders );

    for my $call ( @args ) {
        my ( $class, $method ) = split /->/, $call;
        $method ||= "new";
        my $id = ( reverse split /::/, $class )[0];
        my $ct = decamelize $id;

        push @constructors, _export $target, $ct, sub { $class->$method( @_ ) };
        push @iders,        _export $target, $id, sub { $class };
    }

    return ( \@constructors, \@iders );
}

1;
