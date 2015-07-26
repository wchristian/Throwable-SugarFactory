package Constructor::SugarLibrary;

use strictures 2;
use Import::Into;
use Constructor::Sugar ();
use Throwable::SugarFactory::_Utils '_getglob';

# VERSION

# ABSTRACT: build a library of generic constructor syntax sugar

# COPYRIGHT

=head1 SYNOPSIS

Declare syntax sugar in a library that will export it.

    package My::SugarLib;
    use Constructor::SugarLibrary;
    
    sweeten "My::Moo::Object";
    sweeten "My::Moose::Thing";

This is how you'd normally construct and check objects:

    package My::NormalCode;
    use My::Moo::Object;
    use My::Moose::Thing;
    
    my $obj = My::Moo::Object->new( plus => "some", more => "data" );
    die if !$obj->isa( "My::Moo::Object" );
    my $obj2 = My::Moose::Thing->new( with => "other", meta => "data" );
    die if !$obj->isa( "My::Moose::Thing" );

Using the sugar library the same can be done much more concisely:

    package My::SugaredCode;
    use My::SugarLib;
    
    my $obj = object plus => "some", more => "data";
    die if $obj->isa( Object );
    my $obj2 = thing with => "other", meta => "data";
    die if $obj->isa( Thing );

=cut

{
    ## no critic (ProhibitNoStrict)
    no strict 'refs';
    sub _getexport      { \@{"$_[0]::EXPORT"} }
    sub _getexport_tags { \%{"$_[0]::EXPORT_TAGS"} }
    ## use critic
}

sub import {
    base->import::into( 1, "Exporter" );
    my $library      = caller;
    my $sweeten_func = sub {
        for my $spec ( @_ ) {
            my ( $class ) = split /->/, $spec;
            my ( $id ) = ( reverse split /::/, $class )[0];
            my ( $ctors, $ids ) =
              Constructor::Sugar->import::into( $library, $spec );
            push @{ _getexport $library}, @{$ctors}, @{$ids};
            my $tags = _getexport_tags $library;
            push @{ $tags->{$id} }, @{$ctors}, @{$ids};
            push @{ $tags->{ctors} }, @{$ctors};
            push @{ $tags->{ids} },   @{$ids};
        }
    };
    my $sweeten_meth = sub {
        shift;
        $sweeten_func->( @_ );
    };
    *{ _getglob $library, "sweeten" }      = $sweeten_func;
    *{ _getglob $library, "sweeten_meth" } = $sweeten_meth;
    return;
}

1;
