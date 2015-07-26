use strictures 2;

package basic_test;

use Test::InDistDir;
use Test::More;
use Test::Fatal;
use Try::Tiny;

BEGIN {

    package TestExLib;

    use Throwable::SugarFactory 'exception';

    exception PLAIN_ERROR => "plain description";
    exception DATA_ERROR  => "data description" =>
      ( has => [ flub => ( is => 'ro' ) ] );
    exception [ Custom => "make" ] => "has custom constructor sugar";

    $INC{"TestExLib.pm"} = 1;
}

BEGIN {
    my @e = qw( plain_error data_error make PLAIN_ERROR DATA_ERROR Custom );
    TestExLib->import( @e );
}

run();
done_testing;
exit;

sub run {
    my $p = try {
        eval { die "wagh\n" } or die plain_error
    }
    catch { $_ };
    my $d = try { die data_error flub => 'blarb' } catch { $_ };
    my $c = try { die make } catch { $_ };
    ok $p->isa( "TestExLib::PLAIN_ERROR" );
    ok $d->isa( "TestExLib::DATA_ERROR" );
    ok $c->isa( "TestExLib::Custom" );
    ok $p->does( "Throwable" );
    ok $d->does( "Throwable" );
    ok $c->does( "Throwable" );
    is PLAIN_ERROR, "TestExLib::PLAIN_ERROR";
    is DATA_ERROR,  "TestExLib::DATA_ERROR";
    is Custom,      "TestExLib::Custom";
    is ref $p, "TestExLib::PLAIN_ERROR";
    is ref $d, "TestExLib::DATA_ERROR";
    is ref $c, "TestExLib::Custom";
    is $p->description,          "plain description";
    is $d->description,          "data description";
    is $c->description,          "has custom constructor sugar";
    is $p->namespace,            "TestExLib";
    is $d->namespace,            "TestExLib";
    is $d->namespace,            "TestExLib";
    is $p->error,                "PLAIN_ERROR";
    is $d->error,                "DATA_ERROR";
    is $c->error,                "Custom";
    is $d->flub,                 'blarb';
    like $p->previous_exception, qr/wagh/;
    is_deeply $d->to_hash,
      {
        data               => { flub => 'blarb' },
        description        => 'data description',
        error              => 'DATA_ERROR',
        namespace          => 'TestExLib',
        previous_exception => '',
      };
    is_deeply $p->to_hash,
      {
        data               => {},
        description        => 'plain description',
        error              => 'PLAIN_ERROR',
        namespace          => 'TestExLib',
        previous_exception => "wagh\n",
      };
    is_deeply $c->to_hash,
      {
        data               => {},
        description        => 'has custom constructor sugar',
        error              => 'Custom',
        namespace          => 'TestExLib',
        previous_exception => "",
      };
    return;
}
