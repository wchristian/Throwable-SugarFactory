package Constructor::Sugar;

use strictures 2;

use String::CamelCase 'decamelize';
use Throwable::SugarFactory::Utils '_getglob';

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

sub _export {
    my ( $pkg, $func, $code ) = @_;
    *{ _getglob $pkg, $func } = $code;
    return $func;
}

sub import {
    my ( undef, @specs ) = @_;
    my $target = caller;
    my ( @constructors, @iders );

    for my $spec ( @specs ) {
        my ( $class, $method ) = split /->/, $spec;
        $method ||= "new";
        my $id = ( reverse split /::/, $class )[0];
        my $ct = decamelize $id;
        die "Converting '$id' into a snake_case constructor did not result in"
          . " a different string."
          if $ct eq $id;

        push @constructors, _export $target, $ct, sub { $class->$method( @_ ) };
        push @iders,        _export $target, $id, sub { $class };
    }

    return ( \@constructors, \@iders );
}

1;
