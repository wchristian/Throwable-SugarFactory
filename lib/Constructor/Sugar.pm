package Constructor::Sugar;

use strictures 2;

use String::CamelCase 'decamelize';
use Throwable::SugarFactory::_Utils '_getglob';

# VERSION

# ABSTRACT: export constructor syntax sugar

# COPYRIGHT

=head1 SYNOPSIS

    { package My::Moo::Object; use Moo; has $_, is => 'ro' for qw( plus more ) }
    { package My::Custom; use Moo; }
    
    {
        package BasicSyntax;
        
        my $o = My::Moo::Object->new( plus => "some", more => "data" );
        die if !$o->isa( "My::Moo::Object" );
    }
    
    {
        package ConstructorWrapper;
        use Constructor::Sugar 'My::Moo::Object';
        use Constructor::Sugar 'My::Custom make';
        
        my $o = object plus => "some", more => "data";
        die if !$o->isa( Object );
        die if Object ne "My::Moo::Object";
        
        my $o2 = make;
        die if !$o2->isa( Custom );
        die if Custom ne "My::Custom";
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
        my ( $call,  $ct )     = split / /,  $spec;
        my ( $class, $ctmeth ) = split /->/, $call;
        $ctmeth ||= "new";
        my $id = ( reverse split /::/, $class )[0];
        $ct ||= decamelize $id;

        push @constructors, _export $target, $ct, sub { $class->$ctmeth( @_ ) };
        push @iders,        _export $target, $id, sub { $class };
    }

    return ( \@constructors, \@iders );
}

1;
