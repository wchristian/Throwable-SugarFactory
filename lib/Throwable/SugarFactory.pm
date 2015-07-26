package Throwable::SugarFactory;

use strictures 2;
use Import::Into;
use MooX::SugarFactory ();
use Throwable::SugarFactory::_Utils '_getglob';

# VERSION

# ABSTRACT: build a library of syntax-sugared Throwable-based exceptions

# COPYRIGHT

=head1 SYNOPSIS

Declare exception classes in a library that will export sugar.

    package My::SugarLib;
    use Throwable::SugarFactory;
    
    exception PlainError => "a generic error without metadata";
    exception DataError  => "data description" =>
      has => [ flub => ( is => 'ro' ) ];

Use exception library to export sugar for exception object construction and
class checking.

    package My::Code;
    use My::SugarLib;
    use Try::Tiny;
    
    try {
        die plain_error;
    }
    catch {
        die if !$_->isa( PlainError );
    };
    
    try {
        die data_error flub => 'blarb';
    }
    catch {
        die if !$_->isa( DataError );
        die if $_->flub ne 'blarb';
    };

=head1 DESCRIPTION

This is an effort to create an exception library that is useful and pleases my
aesthetics. The explicit goals were:

1. Declare exception classes at runtime to remove the need for multiple files.

2. Retain the use of the perl builtin C<die> to throw the exception, to
   minimize the difference from common standard Perl code and thus increase
   reading speed.

3. Gain ability to construct the exception class with a short function call, to
   increase reading speed by removing the need to: Use the full class name;
   mention the constructor name at all; use cumbersome method call syntax and
   forced parens.

4. Gain ability to perform ISA checks with a short function call, also to
   increase reading speed by removing the need to use the full class name.

To build an exception library with this module, simply C<use> the module in your
package, which sets it up as a library to export the constructor and class name
shortcuts you will be declaring with the exported keyword C<exception>.

To use the exceptions in your code, C<use> your exception library in the module
where you wish to throw exceptions, whereupon it will export the shortcuts. You
can then create the exception with the snake_cased constructor function and call
die to throw it, and when its caught, can call ->isa with the CamelCased
shortcut that returns the class name.

=head1 DECLARATION

To declare an exception in your library, you call exception with 3 arguments:

- A sugar spec, this is used by L<Constructor::Sugar> to create the shortcuts.
  These will be two functions: One that creates a new exception object by
  passing its argument to the object's constructor, with its name generated by
  converting the error id to snake_case. And one function that will return the
  error's full class name with its name being exactly the error id given.

- An error description which will be found in the attribute description of every
  exception created with that id.

- A list of instructions, which will be used by L<MooX::BuildClass> to construct
  the exception class. The exception's full class name will be the package name
  C<exception> is called in, appended with :: and the id given in the spec. Note
  that the full range of Moo functions is available to declare your exception
  class, including the ability to compose roles into them, so this should
  provide a lot of freedom and even give the ability to modify the syntax of the
  constructor arguments somewhat.

Note: You CAN include C<::> in the spec, but the results may not be what you
expect, and they may change in the future. As of now this is bat country.
Consider yourself warned. Talk to me in #web-simple if you have ideas on this.

=head1 IMPORTING EXCEPTIONS

Your exception library will be a basic L<Exporter> package, which operated like
those usually do. A bare use will export all shortcuts for all exceptions in the
library. When explicit shortcut names are used as parameters in the use, then
only those will be exported.

Additionally there are a few tags you can use. C<:ctors> will export only the
constructor shortcuts, C<:ids> will export only the class name shortcuts, and
C<:$exception> will export the constructor and class name shortcuts for that
exception id only.

=head1 THROWING EXCEPTIONS

To throw your exceptions, you use the snake_cased constructor shortcut to create
the exception object, giving the normal type of object constructor arguments;
followed by calling die to actually throw the exception.

Note that right now the constructor function may actually die with the exception
immediately, but that state is only temporary and will be changed in the near
future. Calling die (or your favourite error function) is mandatory.

=head1 EXCEPTION METHODS

The exception objects constructed by this library come with a few methods
implemented by default. These are as follows:

=head2 Throwable

The role L<Throwable> is composed into each class, providing all methods
provided by that role.

=head2 error

The error id you used to declare the exception class.

=head2 namespace

The package name this exception class was declared in.

=head2 description

The description string used to declare the exception class.

=head2 to_hash

Returns a hash reference containing the data of the exception. Useful for
conversion to JSON.

=head1 SEE ALSO

L<Throwable>, L<Throwable::Factory>, L<Exception::Class>, L<Exception::Base>,
L<Try::Tiny>, L<Try::Tiny::ByClass>

=cut

sub _base_args {
    my ( $namespace, $error, $description ) = @_;
    return (
        with => [ "Throwable", __PACKAGE__ . "::Hashable" ],
        has => [ namespace   => ( is => 'ro', default => $namespace ) ],
        has => [ error       => ( is => 'ro', default => $error ) ],
        has => [ description => ( is => 'ro', default => $description ) ],
    );
}

sub import {
    MooX::SugarFactory->import::into( 1 );
    my $factory = caller;
    *{ _getglob $factory, "exception" } = sub {
        my ( $id, $description, @args ) = @_;
        my $class = "${factory}::$id";
        $factory->can( "class" )->(
            "$class->throw", _base_args( $factory, $id, $description ), @args
        );
    };
}

1;
