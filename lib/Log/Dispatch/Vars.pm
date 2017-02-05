package Log::Dispatch::Vars;

use strict;
use warnings;

our $VERSION = '2.59';

use Exporter qw( import );

our @EXPORT_OK = qw(
    %CanonicalLevelNames
    %LevelNamesToNumbers
    @OrderedLevels
);

## no critic (Variables::ProhibitPackageVars)
our %CanonicalLevelNames = (
    (
        map { $_ => $_ }
            qw(
            debug
            info
            notice
            warning
            error
            critical
            alert
            emergency
            )
    ),
    warn  => 'warning',
    err   => 'error',
    crit  => 'critical',
    emerg => 'emergency',
);

our @OrderedLevels = qw(
    debug
    info
    notice
    warning
    error
    critical
    alert
    emergency
);

our %LevelNamesToNumbers = (
    ( map { $OrderedLevels[$_] => $_ } 0 .. $#OrderedLevels ),
    warn  => 3,
    err   => 4,
    crit  => 5,
    emerg => 7,
);

1;

# ABSTRACT: Variables used internally by multiple packages

__END__

=pod

=encoding UTF-8

=head1 DESCRIPTION

There are no user-facing parts here.

=cut
