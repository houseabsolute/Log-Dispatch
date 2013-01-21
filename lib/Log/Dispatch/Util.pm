package Log::Dispatch::Util;

use strict;
use warnings;

use Exporter qw( import );

our @EXPORT_OK = qw( _level_is_valid );

our @LevelNames
    = qw( debug info notice warning error critical alert emergency );

my $ln = 0;
our %LevelNumbers = (
    ( map { $_ => $ln++ } @LevelNames ),
    warn  => 3,
    err   => 4,
    crit  => 5,
    emerg => 7
);

sub _level_is_valid {
    return defined $_[0]
        && ( $_[0] =~ /^[0-7]$/ || exists $LevelNumbers{ $_[0] } );
}

1;

# ABSTRACT: Shared variables for Log::Dispatch classes
