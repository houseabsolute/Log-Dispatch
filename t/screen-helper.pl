use strict;
use warnings;

use Getopt::Long;
use Log::Dispatch;
use Log::Dispatch::Screen;

my ( $stderr, $utf8 );
GetOptions(
    'stderr' => \$stderr,
    'utf8'   => \$utf8,
);

my $dispatch = Log::Dispatch->new(
    outputs => [
        [
            Screen => (
                name      => 'screen',
                min_level => 'debug',
                newline   => 1,
                stderr    => $stderr,
                utf8      => $utf8,
            ),
        ]
    ],
);

my $message = 'test message';
if ($utf8) {
    binmode( $stderr ? \*STDERR : \*STDOUT );
    $message .= " - \x{1f60}";
}
$dispatch->warning($message);

exit 0;
