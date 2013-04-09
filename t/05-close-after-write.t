use strict;
use warnings FATAL => 'all';

use Test::More 0.88;
use Test::TempDir;
use Path::Tiny;
use Log::Dispatch;

my $dir = temp_root;

# test that the same handle is returned if close-on-write is not set...

{
    my $logger = Log::Dispatch->new(
        outputs => [
            [
                'File',
                min_level => 'debug',
                newline => 1,
                name => 'no_caw',
                filename => path($dir, 'no_caw.log')->stringify,
                close_after_write => 0,
            ],
            [
                'File',
                min_level => 'debug',
                newline => 1,
                name => 'caw',
                filename => path($dir, 'caw.log')->stringify,
                close_after_write => 1,
            ],
        ],
    );

    ok($logger->output('no_caw')->{fh}, 'no_caw output has created a fh before first write');
    ok(!$logger->output('caw')->{fh}, 'caw output has not created a fh before first write');

    # write the first message...
    $logger->log(level => 'info', message => 'first message');
    is(path($logger->output('no_caw')->{filename})->slurp, "first message\n", 'first line from no_caw output');
    is(path($logger->output('caw')->{filename})->slurp, "first message\n", 'first line from caw output');

    my %handle = (
        no_caw => $logger->output('no_caw')->{fh},
        caw => $logger->output('caw')->{fh},
    );

    # now write another message...
    $logger->log(level => 'info', message => 'second message');

    is(path($logger->output('no_caw')->{filename})->slurp, "first message\nsecond message\n", 'full content from no_caw output');
    is(path($logger->output('caw')->{filename})->slurp, "first message\nsecond message\n", 'full content from caw output');

    # check the filehandles again...
    is($logger->output('no_caw')->{fh}, $handle{no_caw}, 'handle has not changed when not using CAW');
    isnt($logger->output('caw')->{fh}, $handle{caw}, 'handle has changed when using CAW');
}

done_testing;


