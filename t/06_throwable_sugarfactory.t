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
    exception "Nested::ERROR" => "nested";    # bat country

    $INC{"TestExLib.pm"} = 1;
}

BEGIN {
    TestExLib->import(
        qw( plain_error data_error error PLAIN_ERROR DATA_ERROR ERROR ) );
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
    my $n = try { die error } catch { $_ };
    ok $p->isa( "TestExLib::PLAIN_ERROR" );
    ok $d->isa( "TestExLib::DATA_ERROR" );
    ok $n->isa( "TestExLib::Nested::ERROR" );
    ok $p->does( "Throwable" );
    ok $d->does( "Throwable" );
    ok $n->does( "Throwable" );
    is PLAIN_ERROR, "TestExLib::PLAIN_ERROR";
    is DATA_ERROR,  "TestExLib::DATA_ERROR";
    is ERROR,       "TestExLib::Nested::ERROR";
    is ref $p, "TestExLib::PLAIN_ERROR";
    is ref $d, "TestExLib::DATA_ERROR";
    is ref $n, "TestExLib::Nested::ERROR";
    is $p->description,          "plain description";
    is $d->description,          "data description";
    is $n->description,          "nested";
    is $p->namespace,            "TestExLib";
    is $d->namespace,            "TestExLib";
    is $n->namespace,            "TestExLib";
    is $p->error,                "PLAIN_ERROR";
    is $d->error,                "DATA_ERROR";
    is $n->error,                "Nested::ERROR";
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
    is_deeply $n->to_hash,
      {
        data               => {},
        description        => 'nested',
        error              => 'Nested::ERROR',
        namespace          => 'TestExLib',
        previous_exception => "",
      };
    return;
}
