use strict;
use warnings;

use Test::More 0.88;

use Test::Requires {
    'Sys::Syslog' => '0.28',
};

use Log::Dispatch;
use Log::Dispatch::Syslog;

no warnings 'redefine', 'once';

my @sock;
local *Sys::Syslog::setlogsock = sub { @sock = @_ };

local *Sys::Syslog::openlog  = sub { return 1 };
local *Sys::Syslog::closelog = sub { return 1 };

my @log;
local *Sys::Syslog::syslog = sub { push @log, [@_] };

{
    @log = ();

    my $dispatch = Log::Dispatch->new;
    $dispatch->add(
        Log::Dispatch::Syslog->new(
            name      => 'syslog',
            min_level => 'debug',
        )
    );

    $dispatch->info('Foo');

    ok(
        !@sock,
        'no call to setlogsock unless socket is set explicitly'
    );

    is_deeply(
        \@log,
        [ [ 'INFO', 'Foo' ] ],
        'passed message to syslog'
    );
}

{
    @log = ();

    my $dispatch = Log::Dispatch->new;
    $dispatch->add(
        Log::Dispatch::Syslog->new(
            name      => 'syslog',
            min_level => 'debug',
            socket    => { type => 'foo' },
        )
    );

    $dispatch->info('Foo');

    is_deeply(
        \@sock,
        [ { type => 'foo' } ],
        'call to setlogsock is made when logging a message if socket was passed to LD::Syslog constructor'
    );
}

SKIP:
{
    skip 'These tests only run on a threaded perl', 1
        unless eval { require threads; 1 };

    @log = ();

    my $dispatch = Log::Dispatch->new;
    $dispatch->add(
        Log::Dispatch::Syslog->new(
            name      => 'syslog',
            min_level => 'debug',
            lock      => 1,
        )
    );

    $dispatch->info('Foo thread');

    is_deeply(
        \@log,
        [ [ 'INFO', 'Foo thread' ] ],
        'passed message to syslog (with thread lock)'
    );
}

done_testing();
