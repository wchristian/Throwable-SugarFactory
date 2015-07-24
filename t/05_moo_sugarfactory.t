use strictures 2;
use Test::More;

BEGIN {

    package My::SugarFactory;
    use Moo::SugarFactory;
    class "My::Moo::Object" => (
        has => [ plus => ( is => 'ro' ) ],
        has => [ more => ( is => 'ro' ) ],
    );
    class "My::Moo::Thing" => (
        has     => [ contains => ( is => 'ro' ) ],
        has     => [ meta     => ( is => 'ro' ) ],
        extends => Object_c(),
    );
    class "My::Moo::CustomCons->cons" => (
        has     => [ contains => ( is => 'ro' ) ],
        has     => [ meta     => ( is => 'ro' ) ],
        install => [ cons     => sub  { My::Moo::CustomCons->new } ],
    );
    $INC{"My/SugarFactory.pm"}++;
}

use My::SugarFactory;
ok my $obj = Object plus => "some", more => "data";
ok $obj->isa( Object_c );
is $obj->plus, "some";
is Object_c, "My::Moo::Object";

ok my $obj2 =    #
  Thing contains => "other", meta => "data", plus => "some", more => "data";
ok $obj2->isa( Thing_c );
ok $obj2->isa( Object_c );
is $obj2->contains, "other";
is $obj2->plus,     "some";
is Thing_c, "My::Moo::Thing";

ok my $obj3 = CustomCons contains => "other", meta => "data";
ok $obj3->isa( CustomCons_c );
is $obj3->contains, undef;
is CustomCons_c, "My::Moo::CustomCons";

done_testing;
