use strictures;

package basic_test;

use Test::InDistDir;
use Test::More;
use Test::Fatal;

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
    my $p = PLAIN_ERROR;
    my $d = DATA_ERROR flub => 'blarb';
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
    is $d->flub,        'blarb';
    return;
}
