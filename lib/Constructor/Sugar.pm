package Constructor::Sugar;

use strictures 1;

# VERSION

# ABSTRACT: export constructor syntax sugar

# COPYRIGHT

=head1 SYNOPSIS

    { package My::Moo::Object; use Moo; has $_, is => 'ro' for "plus", "more" }
    
    {
        package BasicSyntax;
        
        my $o = My::Moo::Object->new( plus => "some", more => "data" );
        die if !$o->isa( "My::Moo::Object" );
    }
    
    {
        package ConstructorWrapper;
        use Constructor::Sugar 'My::Moo::Object';
        
        my $o = Object plus => "some", more => "data";
        die if !$o->isa( "My::Moo::Object" );
    }

=cut

sub _getglob { no strict; \*{ $_[0] } }

sub _export {
    my ( $pkg, $func, $code ) = @_;
    *{ _getglob "$pkg\::$func" } = $code;
    return $func;
}

sub _arg_loop (&@) {
    my ( $code, @args ) = @_;

    for my $class ( @args ) {
        my ( $id ) = ( reverse split /::/, $class )[0];
        $code->( $class, $id );
    }
}

sub import {
    shift;
    my %flags = map { $_ => 1 } grep /^-/, @_;
    my @args = grep !/^-/, @_;
    my $target = caller;
    my ( @constructors, @iders );

    _arg_loop {
        my ( $class, $id ) = @_;

        push @constructors, _export $target, $id, sub { $class->new( @_ ) };

        push @iders, _export $target, "$id\_c", sub { $class }
          unless $flags{-noids};
    }
    @args;

    return ( \@constructors, \@iders );
}

1;
