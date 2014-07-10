use strictures 1;

use Test::More;
use Test::Fatal;

{

    package My::Moo::Object;
    use Moo;
    has $_ => ( is => 'ro' ) for qw( plus more );
}

{
    use Constructor::Sugar "My::Moo::Object";

    ok my $obj = Object plus => "some", more => "data";
    ok $obj->isa( Object_c );
    is Object_c, "My::Moo::Object";
    is $obj->plus, "some";
    is $obj->more, "data";
}

{
    use Constructor::Sugar qw( -noids OtherObject );

    ok __PACKAGE__->can( "OtherObject" );
    ok !__PACKAGE__->can( "OtherObject_c" );
}

done_testing;
