use strictures 2;

package basic_test;

use Test::InDistDir;
use Test::More;
use Test::Fatal;
use Try::Tiny;
use Throwable::Error;

BEGIN {

    package TestExLib;

    use Throwable::SugarFactory 'exception';

    exception PLAIN_ERROR => "plain description";
    exception DATA_ERROR  => "data description" =>
      ( has => [ flub => ( is => 'ro' ) ] );
    exception "Nested::ERROR" => "nested";    # bat country
    exception PROP_ERROR  => sub { sprintf 'the bad data was: %s', shift->flub } =>
      ( has => [ flub => ( is => 'ro' ) ] );

    $INC{"TestExLib.pm"} = 1;
}

BEGIN {
    TestExLib->import(
        qw( plain_error data_error error prop_error PLAIN_ERROR DATA_ERROR ERROR PROP_ERROR ) );
}

run();
done_testing;
exit;

sub ex_hash {
    return { map { $_ => shift }
          qw( data description error namespace previous_exception ) };
}

sub run {
    my $p = try {
        eval { die "wagh\n" } or die plain_error
    }
    catch { $_ };
    my @d = ( flub => 'blarb' );
    my $d = try { die data_error @d } catch { $_ };
    my $n = try { die error } catch         { $_ };
    my $e = try { die prop_error @d } catch { $_ };
    ok $p->isa( "TestExLib::PLAIN_ERROR" );
    ok $d->isa( "TestExLib::DATA_ERROR" );
    ok $n->isa( "TestExLib::Nested::ERROR" );
    ok $e->isa( "TestExLib::PROP_ERROR" );
    ok $p->does( "Throwable" );
    ok $d->does( "Throwable" );
    ok $n->does( "Throwable" );
    ok $e->does( "Throwable" );
    is PLAIN_ERROR, "TestExLib::PLAIN_ERROR";
    is DATA_ERROR,  "TestExLib::DATA_ERROR";
    is ERROR,       "TestExLib::Nested::ERROR";
    is PROP_ERROR,  "TestExLib::PROP_ERROR";
    is ref $p, "TestExLib::PLAIN_ERROR";
    is ref $d, "TestExLib::DATA_ERROR";
    is ref $n, "TestExLib::Nested::ERROR";
    is ref $e, "TestExLib::PROP_ERROR";
    is $p->description,          "plain description";
    is $d->description,          "data description";
    is $n->description,          "nested";
    is $e->description,          'the bad data was: blarb';
    is $p->namespace,            "TestExLib";
    is $d->namespace,            "TestExLib";
    is $n->namespace,            "TestExLib";
    is $e->namespace,            "TestExLib";
    is $p->error,                "PLAIN_ERROR";
    is $d->error,                "DATA_ERROR";
    is $n->error,                "Nested::ERROR";
    is $e->error,                "PROP_ERROR";
    is $d->flub,                 'blarb';
    like $p->previous_exception, qr/wagh/;

    # different Throwable versions have different prev defaults, thus detect
    my $pe = try { Throwable::Error->throw( { message => "" } ) }    #
    catch { $_->previous_exception };

    is_deeply $d->to_hash,
      ex_hash {@d}, 'data description', 'DATA_ERROR', 'TestExLib', $pe;
    is_deeply $p->to_hash,
      ex_hash {}, 'plain description', 'PLAIN_ERROR', 'TestExLib', "wagh\n";
    is_deeply $n->to_hash,
      ex_hash {}, 'nested', 'Nested::ERROR', 'TestExLib', $pe;
    is_deeply $e->to_hash,
      ex_hash {@d}, 'the bad data was: blarb', 'PROP_ERROR', 'TestExLib', $pe;
    return;
}
