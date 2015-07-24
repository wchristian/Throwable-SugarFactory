use strictures 2;

use Test::More;
use Test::Fatal;

{

    package NamedVar;
    use Package::NamedVariant;

    sub make_variant {
        my ( $class, $target_package, %arguments ) = @_;
        install "foo" => sub { $arguments{foo} };
    }
}

NamedVar->import;
is( NamedVar( Thing => ( foo => "zip" ) ), "Thing" );
is Thing->foo, "zip";
ok $INC{"Thing.pm"};
ok exception { NamedVar( "Thing" ) };
done_testing;
