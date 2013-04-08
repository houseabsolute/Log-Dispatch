use strict;
use warnings;

use File::Spec::Functions qw(catdir catfile);
use Test::More 0.88;

my $dir = catdir('t', 'tmp');
mkdir $dir if not -d $dir;

my %params = (
    name      => 'file',
    min_level => 'debug',
    filename  => catfile('t', 'tmp', 'logfile_X.txt'),
);
my @tests = (
  {
    params   => {%params, 'binmode' => ':utf8'},
    message  => "foo bar\x{20AC}",
    expected_message => "foo bar\xe2\x82\xac",
  },
);

use_ok('Log::Dispatch');
use_ok('Log::Dispatch::File');

my @files;

SKIP:
{
    skip "Cannot test utf8 files with this version of Perl ($])", 5 * @tests
        unless $] >= 5.008;

    my $count = 0;
    for my $t (@tests) {
        my $dispatcher = Log::Dispatch->new;
        ok($dispatcher, 'got a logger object');
        $t->{params}{filename} =~ s/X/$count++/e;
        my $file = $t->{params}{filename};
        push @files, $file;
        my $logger = Log::Dispatch::File->new(%{$t->{params}});
        ok($logger, 'got a file output object');
        $dispatcher->add($logger);
        $dispatcher->log( level => 'info', message => $t->{message} );
        ok(-e $file, $file . ' exists');
        open my $fh, '<', $file;
        ok($fh, 'file opened');
        local $/ = undef;
        my $line = <$fh>;
        close $fh;
        is($line, $t->{expected_message}, 'output');
    }
}

done_testing;

END {
    unlink @files if @files;
};

