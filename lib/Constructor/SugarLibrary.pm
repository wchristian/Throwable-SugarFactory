package Constructor::SugarLibrary;

use strictures;
use Import::Into;
use Constructor::Sugar ();

# VERSION

# ABSTRACT: build a library of generic constructor syntax sugar

# COPYRIGHT

sub _getglob        { no strict; \*{ $_[0] } }
sub _getexport      { no strict; \@{"$_[0]\::EXPORT"} }
sub _getexport_tags { no strict; \%{"$_[0]\::EXPORT_TAGS"} }

sub import {
    base->import::into( 1, "Exporter" );
    my $library      = caller;
    my $sweeten_func = sub {
        Constructor::Sugar::_arg_loop {
            my ( $class, $id ) = @_;
            my ( $ctors, $ids ) = Constructor::Sugar->import::into( $library, $class );
            push @{ _getexport $library}, @{$ctors}, @{$ids};
            my $tags = _getexport_tags $library;
            push @{ $tags->{$id} }, @{$ctors}, @{$ids};
            push @{ $tags->{ctors} }, @{$ctors};
            push @{ $tags->{ids} },   @{$ids};
        }
        @_;
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
