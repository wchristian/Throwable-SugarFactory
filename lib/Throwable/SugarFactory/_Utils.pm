package Throwable::SugarFactory::_Utils;

use parent 'Exporter';

our @EXPORT_OK = qw( _array _getglob );

sub _array { ref $_[0] eq "ARRAY" ? $_[0] : [ $_[0] ] }

sub _getglob { no strict 'refs'; \*{join '::', @_} }

1;
