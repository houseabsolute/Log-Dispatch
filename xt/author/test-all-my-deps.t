use strict;
use warnings;

use Cwd qw( abs_path );
use Test::More;

use Test::DependentModules 0.21 qw( test_all_dependents );

$ENV{PERL_TEST_DM_PROCESSES} = 4;
$ENV{PERL_TEST_DM_LOG_DIR}   = abs_path('.');

my @exclude = (
    'Email::Sendmail',    # broken dist
    'Growl',
    'Gtk2-Notify',
    'Kafka',              # has no tests
    'MacGrowl',
    'Scribe',
    'Tk',
    'ToTk',
    'Twilio',
    'Win32EventLog',
    'Wx',
    'XML',                # depends on nonexistent Log::Dispatch::Buffer
    'ZMQ',
);

my $ld_only = qr/(?!Log-Dispatch)/;
my $cannot_run = join '|', map {"Log-Dispatch-$_"} @exclude;

my $exclude = qr/^(?:$ld_only|$cannot_run)/;

test_all_dependents( 'Log::Dispatch', { exclude => $exclude } );
