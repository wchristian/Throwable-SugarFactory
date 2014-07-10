use strictures 1;
use Test::More;

BEGIN {

    package My::Moo::Object;
    use Moo;
    has $_ => ( is => 'ro' ) for qw( plus more );
}

BEGIN {

    package Sugar::Library;
    use Constructor::SugarLibrary;
    sweeten "My::Moo::Object";
    $INC{"Sugar/Library.pm"}++;
}

{
    use Sugar::Library;

    ok my $obj = Object plus => "some", more => "data";
    ok $obj->isa( Object_c );
    is Object_c, "My::Moo::Object";
    is $obj->plus, "some";
    is $obj->more, "data";
}

{

    package A;
    use Test::More;
    use Sugar::Library ':ctors';

    ok __PACKAGE__->can( "Object" );
    ok !__PACKAGE__->can( "Object_c" );
}

{

    package B;
    use Test::More;
    use Sugar::Library ':ids';

    ok !__PACKAGE__->can( "Object" );
    ok __PACKAGE__->can( "Object_c" );
}

{

    package C;
    use Test::More;
    use Sugar::Library ':Object';

    ok __PACKAGE__->can( "Object" );
    ok __PACKAGE__->can( "Object_c" );
}

done_testing;
