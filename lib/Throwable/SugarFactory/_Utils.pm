package Throwable::SugarFactory::_Utils;

use parent 'Exporter';

our @EXPORT_OK = qw( _getglob );

sub _getglob { no strict 'refs'; \*{join '::', @_} }

1;
