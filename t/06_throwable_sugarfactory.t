use strictures;

package basic_test;

use Test::InDistDir;
use Test::More;
use Test::Fatal;
use Try::Tiny;

BEGIN {

    package TestExLib;

    use Throwable::SugarFactory 'exception';

    exception PLAIN_ERROR => "plain description";
    exception DATA_ERROR => "data description" => ( has => [ flub => ( is => 'ro' ) ] );

    $INC{"TestExLib.pm"} = 1;
}

BEGIN { TestExLib->import( qw( PLAIN_ERROR DATA_ERROR PLAIN_ERROR_c DATA_ERROR_c ) ) }

run();
done_testing;
exit;

sub run {
    my $p = try { eval { die "wagh\n" } or die PLAIN_ERROR } catch { $_ };
    my $d = try { die DATA_ERROR flub => 'blarb' } catch { $_ };
    ok $p->isa( "TestExLib::PLAIN_ERROR" );
    ok $d->isa( "TestExLib::DATA_ERROR" );
    ok $p->does( "Throwable" );
    ok $d->does( "Throwable" );
    is PLAIN_ERROR_c, "TestExLib::PLAIN_ERROR";
    is DATA_ERROR_c,  "TestExLib::DATA_ERROR";
    is ref $p, "TestExLib::PLAIN_ERROR";
    is ref $d, "TestExLib::DATA_ERROR";
    is $p->description, "plain description";
    is $d->description, "data description";
    is $p->namespace, "TestExLib";
    is $d->namespace, "TestExLib";
    is $p->error, "PLAIN_ERROR";
    is $d->error, "DATA_ERROR";
    is $d->flub,        'blarb';
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
    return;
}
