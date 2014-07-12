use strictures 1;

use Test::More;

use Moo::ClassBuilder;

{ package TestRole; use Moo::Role }
{ package TestClass; use Moo; $INC{"TestClass.pm"}++ }

ClassBuilder Thing => install => [ foo => sub { "foo" } ];
is Thing->new->foo, "foo";

ClassBuilder Thing2 => install => [ foo => sub { "foo" } ],
  around            => [ foo   => sub   { "foo2" } ];
is Thing2->new->foo, "foo2";

ClassBuilder Thing3 => has => [ foo => is => ro => default => "foo5" ];
is Thing3->new->foo, "foo5";

ClassBuilder Thing4 => has   => [ ifoo => is => rw => default => "foo5" ],
  install           => [ foo => sub    { shift->ifoo } ],
  before            => [ foo => sub    { shift->ifoo( "foo3" ) } ];
is Thing4->new->foo, "foo3";

ClassBuilder Thing5 => has   => [ ifoo => is => rw => default => "foo5" ],
  install           => [ foo => sub    { shift->ifoo } ],
  after             => [ foo => sub    { shift->ifoo( "foo4" ) } ];
my $t = Thing5->new;
$t->foo;
is $t->foo, "foo4";

ClassBuilder Thing6 => extends => "TestClass";
ok Thing6->new->isa( "TestClass" );

ClassBuilder Thing7 => with => "TestRole";
ok Thing7->new->does( "TestRole" );

done_testing;
