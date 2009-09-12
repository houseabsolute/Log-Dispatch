use strict;
use warnings;
use lib qw(t/lib);
use Test::More tests => 3;
use Log::Dispatch;
use Log::Dispatch::TestUtil qw(cmp_deeply);
use File::Temp qw( tempdir );

my $tempdir = tempdir( CLEANUP => 1 );

{
    my $emerg_log = File::Spec->catdir( $tempdir, 'emerg.log' );
    my $dispatch1 = Log::Dispatch->new(
        outputs => [
            'File' =>
              { name => 'file', min_level => 'emerg', filename => $emerg_log },
            '+Log::Dispatch::Screen' => { name => 'screen', min_level => 'debug' }
        ]
    );

    my $dispatch2 = Log::Dispatch->new;
    $dispatch2->add(
        Log::Dispatch::File->new(
            name      => 'file',
            min_level => 'emerg',
            filename  => $emerg_log
        )
    );
    $dispatch2->add(
        Log::Dispatch::Screen->new( name => 'screen', min_level => 'debug' ) );

    cmp_deeply( $dispatch1, $dispatch2, "created equivalent dispatchers" );
}

{
    eval { Log::Dispatch->new(outputs => ['File']) };
    like($@, qr/odd number of elements/, "got error for odd number of elements");

    eval { Log::Dispatch->new(outputs => ['File', 'foo.log']) };
    like($@, qr/expected hashref/, "got error for expected hashref");
}
