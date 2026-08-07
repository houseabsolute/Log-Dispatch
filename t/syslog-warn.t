use strict;
use warnings;

use Test::More 0.88;

use Log::Dispatch;
use Log::Dispatch::Syslog;

{
    my $dispatch = Log::Dispatch->new;
    $dispatch->add(
        Log::Dispatch::Syslog->new(
            name      => 'syslog',
            min_level => 'debug',
            #socket   => { type => 'tcp', host => '127.0.0.1', port => 514 },
            # no connection to syslog available
            # - getservbyname failed 
            socket    => { type => 'tcp', port => '' },
        )
    );

    my $warn = "";
    local $SIG{__WARN__} = sub { $warn .= $_[0] };
    local $^W = 1;
    $dispatch->info('Foo');
    like $warn, qr/no connection/;
}

done_testing();
