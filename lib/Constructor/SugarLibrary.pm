package Constructor::SugarLibrary;

use strictures 2;
use Import::Into;
use Constructor::Sugar ();
use Throwable::SugarFactory::_Utils qw'_array _getglob';

# VERSION

# ABSTRACT: build a library of generic constructor syntax sugar

# COPYRIGHT

=head1 SYNOPSIS

    # set up the library package
    package My::SugarLib;
    use Constructor::SugarLibrary;
    
    sweeten "My::Moo::Object";
    sweeten "My::Moose::Thing";
    sweeten [ "My::Custom", "make" ];

And now these do the same:

    package My::NormalCode;
    use My::Moo::Object;
    use My::Moose::Thing;
    use My::Custom;
    
    my $obj = My::Moo::Object->new( plus => "some", more => "data" );
    die if !$obj->isa( "My::Moo::Object" );
    my $obj2 = My::Moose::Thing->new( with => "other", meta => "data" );
    die if !$obj2->isa( "My::Moose::Thing" );
    my $obj3 = My::Custom->new;
    die if !$obj3->isa( "My::Custom" );

    package My::SugaredCode;
    use My::SugarLib;
    
    my $obj = object plus => "some", more => "data";
    die if $obj->isa( Object );
    my $obj2 = thing with => "other", meta => "data";
    die if $obj2->isa( Thing );
    my $obj3 = make;
    die if $obj3->isa( Custom );

=cut

sub _getexport      { no strict; \@{"$_[0]::EXPORT"} }
sub _getexport_tags { no strict; \%{"$_[0]::EXPORT_TAGS"} }

sub import {
    base->import::into( 1, "Exporter" );
    my $library      = caller;
    my $sweeten_func = sub {
        for ( @_ ) {
            my $spec = _array $_;
            my ( $class ) = split /->/, $spec->[0];
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
