package MooX::SugarFactory;

use strictures 2;
use Import::Into;
use MooX::BuildClass;
use MooX::BuildRole;
use Constructor::SugarLibrary ();
use Throwable::SugarFactory::Utils '_getglob';

# VERSION

# ABSTRACT: build a library of syntax-sugared Moo classes

# COPYRIGHT

=head1 SYNOPSIS

Declare classes in a library that will export sugar.

    package My::SugarLib;
    use MooX::SugarFactory;
    
    class "My::Moo::Object" => (
        has => [ plus => ( is => 'ro' ) ],
        has => [ more => ( is => 'ro' ) ],
    );
    
    class "My::Moose::ThingRole" => (
        has     => [ contains => ( is => 'ro' ) ],
        has     => [ metaa    => ( is => 'ro' ) ],
    );
    
    class "My::Moose::Thing" => ( with => ThingRole(), extends => Object() );

Use class library to export sugar for object construction and class checking.

    package My::Code;
    use My::SugarLib;
    
    my $obj = object plus => "some", more => "data";
    die if !$obj->isa( Object );
    die if !$obj->plus eq "some";
    
    my $obj2 = thing contains => "other", meta => "data",    #
      plus => "some", more => "data";
    
    die if !$obj2->isa( Thing );
    die if !$obj2->does( ThingRole );
    die if !$obj2->isa( Object );
    die if !$obj2->meta eq "data";

=cut

sub import {
    my ( $class ) = @_;
    Constructor::SugarLibrary->import::into( scalar caller );    # I::I 1.001000
    my $factory = caller;
    *{ _getglob $factory, $_ } = $class->_creator_with( $factory, $_ )
      for qw( class role );
}

sub _creator_with {
    my ( $class, $factory, $type ) = @_;

    # put MooX::Build<Class|Role>'s Build<> into sub <target>::<class|role>
    # haarg says this working is a perl bug that ignores strict 'refs'
    my $create = \&{ "Build" . ucfirst $type };
    sub {
        my ( $spec, @args ) = @_;
        my ( $class ) = split /->/, $spec;

        # BUILDARGS can be defined in the factory and munges all class/role's
        # args, unsure what to do about this yet, need to ask haarg
        my $build = $factory->can( "BUILDARGS" ) || sub { shift; @_ };
        $create->( $class, $build->( $class, @args ) );
        $factory->sweeten_meth( $spec );
        return;
    };
}

1;
