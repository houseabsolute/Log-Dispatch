# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..124\n"; }
END {print "not ok 1\n" unless $main::loaded;}

use strict;
$^W = 1;

use Log::Dispatch;

my %tests;
BEGIN
{
    foreach ( qw( MailSend MIMELite MailSendmail MailSender ) )
    {
	eval "use Log::Dispatch::Email::$_";
	$tests{$_} = ! $@;
    }

    eval "use Log::Dispatch::Syslog";
    $tests{Syslog} = ! $@;
}

use Log::Dispatch::File;
use Log::Dispatch::Handle;
use Log::Dispatch::Screen;

use IO::File;

if ( eval { require mod_perl } )
{
    require Log::Dispatch::ApacheLog;
}

require Install::TestConfig;

$main::loaded = 1;
result($main::loaded);

my $dispatch = Log::Dispatch->new;
result( defined $dispatch, "Couldn't create Log::Dispatch object\n" );

# 3-6  Test Log::Dispatch::File
{
    $dispatch->add( Log::Dispatch::File->new( name => 'file1',
					      min_level => 'emerg',
					      filename => './emerg_test.log' ) );

    $dispatch->log( level => 'info', message => "info level 1\n" );
    $dispatch->log( level => 'emerg', message => "emerg level 1\n" );

    $dispatch->add( Log::Dispatch::File->new( name => 'file2',
					      min_level => 'debug',
					      filename => 'debug_test.log' ) );

    $dispatch->log( level => 'info', message => "info level 2\n" );
    $dispatch->log( level => 'emerg', message => "emerg level 2\n" );

    # This'll close them filehandles!
    undef $dispatch;

    open LOG1, './emerg_test.log'
	or die "Can't read ./emerg_test.log: $!";
    open LOG2, './debug_test.log'
	or die "Can't read ./debug_test.log: $!";

    my @log = <LOG1>;
    result( $log[0] eq "emerg level 1\n",
	    "First line in log file set to level 'emerg' is '$log[0]', not 'emerg level 1'\n" );
    result( $log[1] eq "emerg level 2\n",
	    "Second line in log file set to level 'emerg' is '$log[0]', not 'emerg level 2'\n" );

    @log = <LOG2>;
    result( $log[0] eq "info level 2\n",
	    "First line in log file set to level 'debug' is '$log[0]', not 'info level 2'\n" );
    result( $log[1] eq "emerg level 2\n",
	    "Second line in log file set to level 'debug' is '$log[0]', not 'emerg level 2'\n" );

    close LOG1;
    close LOG2;

    unlink './emerg_test.log'
	or warn "Can't remove ./emerg_test.log: $!";

    unlink './debug_test.log'
	or warn "Can't remove ./debug_test.log: $!";
}

# 7  max_level test
{
    my $dispatch = Log::Dispatch->new;
    $dispatch->add( Log::Dispatch::File->new( name => 'file1',
					      min_level => 'debug',
					      max_level => 'crit',
					      filename => './max_test.log' ) );

    $dispatch->log( level => 'emerg', message => "emergency\n" );
    $dispatch->log( level => 'crit',  message => "critical\n" );

    open LOG, './max_test.log'
	or die "Can't read ./max_test.log: $!";
    my @log = <LOG>;

    result( $log[0] eq "critical\n",
	    "First line in log file with a max level of 'crit' is 'emergency'\n" );

    close LOG;

    unlink './max_test.log'
	or warn "Can't remove ./max_test.log: $!";
}

# 8  Log::Dispatch::Handle test
{
    my $fh = IO::File->new('>./handle_test.log')
	or die "Can't write to ./handle_test.log: $!";

    my $dispatch = Log::Dispatch->new;
    $dispatch->add( Log::Dispatch::Handle->new( name => 'handle',
						min_level => 'debug',
						handle => $fh ) );

    $dispatch->log( level => 'notice', message =>  "handle test\n" );

    my $handle = $dispatch->remove('handle');
    undef $handle;
    undef $fh;

    open LOG, './handle_test.log'
	or die "Can't open ./handle_test.log: $!";

    my @log = <LOG>;

    result( $log[0] eq "handle test\n",
	    "Log::Dispatch::Handle created log file should contain 'handle test\\n'\n" );

    unlink './handle_test.log'
	or warn "Can't temove ./handle_test.log: $!";
}

fake_test(1, 'Log::Dispatch::Email::MailSend'), goto MailSendmail
    unless $tests{MailSend} && $Install::TestConfig::config{email_address};
# 9  Log::Dispatch::Email::MailSend
{
    my $dispatch = Log::Dispatch->new;

    $dispatch->add( Log::Dispatch::Email::MailSend->new( name => 'Mail::Send',
							 min_level => 'debug',
							 to => $Install::TestConfig::config{email_address},
							 subject => 'Log::Dispatch test suite' ) );

    $dispatch->log( level => 'emerg', message => "Mail::Send test - If you can read this then the test succeeded (PID $$)" );

    warn "Sending email with Mail::Send to $Install::TestConfig::config{email_address}.  If you get it then the test succeeded (PID $$)\n";
    undef $dispatch;

    result(1);
}

MailSendmail:
fake_test(1, 'Log::Dispatch::Email::MailSendmail'), goto MIMELite
    unless $tests{MailSendmail} && $Install::TestConfig::config{email_address};
# 10  Log::Dispatch::Email::MailSendmail
{
    my $dispatch = Log::Dispatch->new;

    $dispatch->add( Log::Dispatch::Email::MailSendmail->new( name => 'Mail::Sendmail',
							     min_level => 'debug',
							     to => $Install::TestConfig::config{email_address},
							     subject => 'Log::Dispatch test suite' ) );

    $dispatch->log( level => 'emerg', message => "Mail::Sendmail test - If you can read this then the test succeeded (PID $$)" );

    warn "Sending email with Mail::Sendmail to $Install::TestConfig::config{email_address}.  If you get it then the test succeeded (PID $$)\n";
    undef $dispatch;

    result(1);
}

MIMELite:
fake_test(1, 'Log::Dispatch::Email::MIMELite'), goto Syslog
    unless $tests{MIMELite} && $Install::TestConfig::config{email_address};
# 11  Log::Dispatch::Email::MIMELite

{
    my $dispatch = Log::Dispatch->new;

    $dispatch->add( Log::Dispatch::Email::MIMELite->new( name => 'Mime::Lite',
							 min_level => 'debug',
							 to => $Install::TestConfig::config{email_address},
							 subject => 'Log::Dispatch test suite' ) );

    $dispatch->log( level => 'emerg', message => "MIME::Lite - If you can read this then the test succeeded (PID $$)" );

    warn "Sending email with MIME::Lite to $Install::TestConfig::config{email_address}.  If you get it then the test succeeded (PID $$)\n";
    undef $dispatch;

    result(1);
}

Syslog:
fake_test(1, 'Log::Dispatch::Syslog'), goto Screen
    unless $tests{Syslog} && $Install::TestConfig::config{syslog};
# 12  Log::Dispatch::Syslog
{
    my $dispatch = Log::Dispatch->new;

    $dispatch->add( Log::Dispatch::Syslog->new( name => 'syslog',
						min_level => 'debug',
						facility => 'daemon',
						socket => 'unix',
						ident => 'Log::Dispatch test' ) );

    my $time = time;
    $dispatch->log( level => 'notice', message => "Log::Dispatch::Syslog testing syslog $time" );

    my $success = 0;
    foreach my $line (`tail -10 $Install::TestConfig::config{syslog_file}`)
    {
	if ( index $line, "Log::Dispatch::Syslog testing syslog $time")
	{
	    $success = 1;
	    last;
	}
    }

    result( $success,
	    "Log::Dispatch::Syslog test failed to write to $Install::TestConfig::config{syslog_file}\n" );
}

# 13  Log::Dispatch::Screen
Screen:
{
    my $dispatch = Log::Dispatch->new;

    $dispatch->add( Log::Dispatch::Screen->new( name => 'screen',
						min_level => 'debug',
					        stderr => 0 ) );

    my $text;
    tie *STDOUT, 'Test::Tie::STDOUT', \$text;
    $dispatch->log( level => 'crit', message => 'testing screen' );
    untie *STDOUT;

    result( $text eq 'testing screen',
	    "Log::Dispatch::Screen didn't send any output to STDOUT\n" );
}

# 14  Log::Dispatch::Output->accepted_levels
{
    my $l = Log::Dispatch::Screen->new( name => 'foo',
					min_level => 'warning',
					max_level => 'alert',
					stderr => 0 );

    my @expected = qw(warning error critical alert);
    my @levels = $l->accepted_levels;

    my $pass = 1;
    for (my $x = 0; $x < scalar @expected; $x++)
    {
	$pass = 0 unless $expected[$x] eq $levels[$x];
    }

    result( $pass && (scalar @expected == scalar @levels),
	    "accepted_levels didn't match expected levels\n" );
}

# 15:  Log::Dispatch single callback
{
    my $reverse = sub { my %p = @_;  return reverse $p{message}; };
    my $dispatch = Log::Dispatch->new( callbacks => $reverse );

    $dispatch->add( Log::Dispatch::Screen->new( name => 'foo',
						min_level => 'warning',
						max_level => 'alert',
						stderr => 0 ) );

    my $text;
    tie *STDOUT, 'Test::Tie::STDOUT', \$text;
    $dispatch->log( level => 'warning', message => 'esrever' );
    untie *STDOUT;

    result( $text eq 'reverse',
	    "Log::Dispatch callback did not reverse text as expected: $text\n" );
}

# 16:  Log::Dispatch multiple callbacks
{
    my $reverse = sub { my %p = @_;  return reverse $p{message}; };
    my $uc = sub { my %p = @_; return uc $p{message}; };

    my $dispatch = Log::Dispatch->new( callbacks => [ $reverse, $uc ] );

    $dispatch->add( Log::Dispatch::Screen->new( name => 'foo',
						min_level => 'warning',
						max_level => 'alert',
						stderr => 0 ) );

    my $text;
    tie *STDOUT, 'Test::Tie::STDOUT', \$text;
    $dispatch->log( level => 'warning', message => 'esrever' );
    untie *STDOUT;

    result( $text eq 'REVERSE',
	    "Log::Dispatch callback did not reverse and uppercase text as expected: $text\n" );
}

# 17:  Log::Dispatch::Output single callback
{
    my $reverse = sub { my %p = @_;  return reverse $p{message}; };

    my $dispatch = Log::Dispatch->new;

    $dispatch->add( Log::Dispatch::Screen->new( name => 'foo',
						min_level => 'warning',
						max_level => 'alert',
						stderr => 0,
						callbacks => $reverse ) );

    my $text;
    tie *STDOUT, 'Test::Tie::STDOUT', \$text;
    $dispatch->log( level => 'warning', message => 'esrever' );
    untie *STDOUT;

    result( $text eq 'reverse',
	    "Log::Dispatch::Output callback did not reverse text as expected: $text\n" );
}

# 18:  Log::Dispatch::Output multiple callbacks
{
    my $reverse = sub { my %p = @_;  return reverse $p{message}; };
    my $uc = sub { my %p = @_; return uc $p{message}; };

    my $dispatch = Log::Dispatch->new;

    $dispatch->add( Log::Dispatch::Screen->new( name => 'foo',
						min_level => 'warning',
						max_level => 'alert',
						stderr => 0,
						callbacks => [ $reverse, $uc ] ) );

    my $text;
    tie *STDOUT, 'Test::Tie::STDOUT', \$text;
    $dispatch->log( level => 'warning', message => 'esrever' );
    untie *STDOUT;

    result( $text eq 'REVERSE',
	    "Log::Dispatch callback did not reverse and uppercase text as expected: $text\n" );
}

# 19:  test level paramter to callbacks
{
    my $level = sub { my %p = @_; return uc $p{level}; };

    my $dispatch = Log::Dispatch->new( callbacks => $level );

    $dispatch->add( Log::Dispatch::Screen->new( name => 'foo',
						min_level => 'warning',
						max_level => 'alert',
						stderr => 0 ) );

    my $text;
    tie *STDOUT, 'Test::Tie::STDOUT', \$text;
    $dispatch->log( level => 'warning', message => 'esrever' );
    untie *STDOUT;

    result( $text eq 'WARNING',
	    "Log::Dispatch callback did return an uppercase version of the level parameter as expected: $text\n" );
}

# 20 - 107: Comprehensive test of new methods that match level names
{
    my %levels = map { $_ => $_ } ( qw( debug info notice warning error critical alert emergency ) );
    @levels{ qw( err crit emerg ) } = ( qw( error critical emergency ) );

    foreach my $allowed_level ( qw( debug info notice warning error critical alert emergency ) )
    {
	my $dispatch = Log::Dispatch->new;

	$dispatch->add( Log::Dispatch::Screen->new( name => 'foo',
						    min_level => $allowed_level,
						    max_level => $allowed_level,
						    stderr => 0 ) );

	foreach my $test_level ( qw( debug info notice warning err error crit critical alert emerg emergency ) )
	{
	    my $text;
	    tie *STDOUT, 'Test::Tie::STDOUT', \$text;
	    $dispatch->$test_level( $test_level, 'test' );
	    untie *STDOUT;

	    if ( $levels{$test_level} eq $allowed_level )
	    {
		my $expect = join $", $test_level, 'test';
		result( $text eq $expect,
			"Calling $test_level method should have sent message '$expect'\n" );
	    }
	    else
	    {
		result( $text eq '',
			"Calling $test_level method should not have logged anything but we got '$text'\n" );
	    }
	}
    }
}

# 108 - 122:  Log::Dispatch->level_is_valid method
{
    foreach my $l ( qw( debug info notice warning err error crit critical alert emerg emergency ) )
    {
	result( Log::Dispatch->level_is_valid($l) );
    }

    foreach my $l ( qw( debu inf foo bar ) )
    {
	result( ! Log::Dispatch->level_is_valid($l) );
    }
}

# 123: make sure passing mode as write works
{
    local *F;
    open F, '>./write_mode.tst'
	or die "Cannot open ./write_mode.tst: $!";
    print F "test1\n";
    close F;

    my $f1 = Log::Dispatch::File->new( name => 'file',
				       min_level => 1,
				       filename => './write_mode.tst',
				       mode => 'write',
				      );
    $f1->log( level => 'emerg',
	      message => "test2\n" );

    undef $f1;

    open F, '<./write_mode.tst'
	or die "Cannot read ./wr_mode.tst: $!";
    my $data = join '', <F>;
    close F;

    result( $data =~ /^test2/ );
}

# 124  Log::Dispatch::Email::MailSend
if ( $tests{MailSender} && $Install::TestConfig::config{email_address} )
{
    my $dispatch = Log::Dispatch->new;

    $dispatch->add
        ( Log::Dispatch::Email::MailSender->new
              ( name => 'Mail::Sender',
                min_level => 'debug',
                smtp => 'localhost',
                to => $Install::TestConfig::config{email_address},
                subject => 'Log::Dispatch test suite' ) );

    $dispatch->log( level => 'emerg', message => "Mail::Sender - If you can read this then the test succeeded (PID $$)" );

    warn "Sending email with Mail::Sender to $Install::TestConfig::config{email_address}.  If you get it then the test succeeded (PID $$)\n";
    undef $dispatch;

    result(1);
}
else
{
    fake_test(1, 'Log::Dispatch::Email::MailSender')
}

sub fake_test
{
    my ($x, $pm) = @_;

    warn "Skipping $x test", ($x > 1 ? 's' : ''), " for $pm\n";
    result($_) foreach 1 .. $x;
}


sub result
{
    my $ok = !!shift;
    use vars qw($TESTNUM);
    $TESTNUM++;
    print "not "x!$ok, "ok $TESTNUM\n";
    print @_ if !$ok;
}


# Used for testing Log::Dispatch::Screen
package Test::Tie::STDOUT;

sub TIEHANDLE
{
    my $class = shift;
    my $self = {};
    $self->{string} = shift;
    ${ $self->{string} } ||= '';

    return bless $self, $class;
}

sub PRINT
{
    my $self = shift;
    ${ $self->{string} } .= join '', @_;
}

sub PRINTF
{
    my $self = shift;
    my $format = shift;
    ${ $self->{string} } .= sprintf($format, @_);
}
