package Constructor::SugarLibrary;

use strictures 2;
use Import::Into;
use Constructor::Sugar ();

# VERSION

# ABSTRACT: build a library of generic constructor syntax sugar

# COPYRIGHT

=head1 SYNOPSIS

    # set up the library package
    package My::SugarLib;
    use Constructor::SugarLibrary;
    
    sweeten "My::Moo::Object";
    sweeten "My::Moose::Thing";

And now these do the same:

    package My::NormalCode;
    use My::Moo::Object;
    use My::Moose::Thing;
    
    my $obj = My::Moo::Object->new( plus => "some", more => "data" );
    die if !$obj->isa( "My::Moo::Object" );
    my $obj2 = My::Moose::Thing->new( with => "other", meta => "data" );
    die if !$obj->isa( "My::Moose::Thing" );

    package My::SugaredCode;
    use My::SugarLib;
    
    my $obj = Object plus => "some", more => "data";
    die if $obj->isa( Object_c );
    my $obj2 = Thing with => "other", meta => "data";
    die if $obj->isa( Thing_c );

=cut

sub _getglob        { no strict; \*{ $_[0] } }
sub _getexport      { no strict; \@{"$_[0]\::EXPORT"} }
sub _getexport_tags { no strict; \%{"$_[0]\::EXPORT_TAGS"} }

sub import {
    base->import::into( 1, "Exporter" );
    my $library      = caller;
    my $sweeten_func = sub {
        for my $call ( @_ ) {
            my ( $class ) = split /->/, $call;
            my ( $id ) = ( reverse split /::/, $class )[0];
            my ( $ctors, $ids ) = Constructor::Sugar->import::into( $library, $call );
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
    *{ _getglob "$library\::sweeten" }      = $sweeten_func;
    *{ _getglob "$library\::sweeten_meth" } = $sweeten_meth;
    return;
}

1;
