package Throwable::SugarFactory::_Utils;

use strictures 2;
use parent 'Exporter';

# VERSION

# ABSTRACT: provide utility functions for Throwable::SugarFactory and friends

# COPYRIGHT

our @EXPORT_OK = qw( _getglob );

## no critic (ProhibitNoStrict)
sub _getglob { no strict 'refs'; \*{join '::', @_} }
## use critic

1;
