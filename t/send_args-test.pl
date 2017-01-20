#!/usr/bin/perl
# This script tests different ways of specifying send_args
# for each Log::Dispatch::Email module.
#
# This is not an automatic test, it is in fact very time consuming.
#
# See my sample exim.conf to set up an smtp server for these tests.
#
# Test procedure:
# 1. Configure your smtp server (see sample exim.conf)
# 2. Customize this script with your email address, and different send_args to test
# 3. Run this script
# 4. Check exim's log file
# 5. Check your received emails.
#    Verify if send_args were used as expected:
#    check X-Exim-Source header, other headers, envelope, etc.
# 6. Disable successful tests, fix send_args for failed tests, go back to step 3.
#

use strict;
use warnings;
use Log::Dispatch;
use Log::Dispatch::Screen::Color;
use Log::Dispatch::Email::MIMELite;
use Log::Dispatch::Email::MailSend;
use Log::Dispatch::Email::MailSendmail;
use Log::Dispatch::Email::EmailSend; # <- I had to make some changes to this one, mailer_args was not being used

# where to send all emails:
my $email = 'someone@test.com';

# for testing modules that don't support any options or authentication
# in this case we test by setting a custom X-Test header, or HELO
my $server1_host = '127.0.0.1';

# for testing modules that support specifying a custom port number
# but not authentication
my $server2_host = '127.0.0.1';
my $server2_port = 9025;

# for testing modules that support specyfing a custom port number
# but not authentication
my $server3_host = '127.0.0.1';
my $server3_port = 9026;
my $server3_user = 'alan';
my $server3_pass = 'secreto';

my $log = Log::Dispatch->new();
$log->add( Log::Dispatch::Screen::Color->new( min_level => 'info', name => 'Screen-1' ) );
my $i;


#################
#
# Log::Dispatch::Email::MIMELite
#
# for smtp we check that the options are really used by verifying the mail logs and mail headers of received emails, they should indicate that authentication worked.
#
# note: To see debug messages from MIME::Lite:
# global: $MIME::Lite::DEBUG = 1;
# in send_args: Debug => 1

my @MIMELite = (
	{ # 0 works, used sendmail
		# disabled => 1,
		test => "no send_args",
	},
	{ # 1 works, used sendmail
		# disabled => 1,
		test => "send_args =  [ ]",
		         send_args => [ ],
	},
	{ # 2 works?
		# disabled => 1,
		test => "send_args =  [ 'testfile' ]",
		         send_args => [ 'testfile' ]
	},
	{ # 3 works, results in /tmp/MIMELite-test.<pid>
		# disabled => 1,
		test => "send_args =  [ 'testfile', '/tmp/MIMELite-test.$$' ]",
		         send_args => [ 'testfile', "/tmp/MIMELite-test.$$" ]
	},
	{ # 4 works
		# disabled => 1,
		test => "send_args =  [ 'sendmail' ]",
		         send_args => [ 'sendmail' ]
	},
	{ # 5 works
		# disabled => 1,
		test => "send_args =  [ 'sendmail', '/usr/sbin/sendmail -ti' ]",
		         send_args => [ 'sendmail', '/usr/sbin/sendmail -ti' ]
	},
	{ # 6 works, used sendmail instead of smtp
		# disabled => 1,
		test => "send_args =  [ 'smtp' ]",
		         send_args => [ 'smtp' ]
	},
	{ # 7 works
		# disabled => 1,
		test => "send_args =  [ 'smtp', $server1_host ]",
		         send_args => [ 'smtp', $server1_host ]
	},
	{ # 8 works
		# disabled => 1,
		test => "send_args =  [ 'smtp', $server3_host, Port => $server3_port, AuthUser => $server3_user, AuthPass => $server3_pass ]",
		         send_args => [ 'smtp', $server3_host, Port => $server3_port, AuthUser => $server3_user, AuthPass => $server3_pass ]
	},
	{ # 9 works
		# disabled => 1,
		test => "send_args =  [ 'smtp', ['badhost1', 'badhost2', $server3_host, 'unused-host'], Port => $server3_port, AuthUser => $server3_user, AuthPass => $server3_pass",
		         send_args => [ 'smtp', ['badhost1', 'badhost2', $server3_host, 'unused-host'], Port => $server3_port, AuthUser => $server3_user, AuthPass => $server3_pass ]
	},
	{ # 10 fails! (but this works with smtp_simple! see test #16)
		# disabled => 1,
		test => "send_args =  [ 'smtp', Host => ['badhost1', 'badhost2',  $server3_host:$server3_port , 'unused-host'], Port => $server3_port, AuthUser => $server3_user, AuthPass => $server3_pass ]",
		         send_args => [ 'smtp', Host => ['badhost1', 'badhost2', "$server3_host:$server3_port", 'unused-host'], Port => $server3_port, AuthUser => $server3_user, AuthPass => $server3_pass ]
	},
	
	# The smtp_simple method uses Net::SMTP.
	# Net::SMTP->new expects the host first, and args next when number of args is odd.  The host can be an arrayref of hosts.
	# Net::SMTP->new expects the host as a hash element if number of args is even. (note: MIME::Lite removes the first one before calling Net::SMTP->new)
	# smtp_simple doesn't support authentication, so we set some headers instead to test if the args are used
	{ # 11 works (should use .libnetrc to find smtp server, in my test it was missing and used sendmail)
		# disabled => 1,
		test => "send_args =  [ 'smtp_simple' ]",
		         send_args => [ 'smtp_simple' ]
	},
	{ # 12 works
		# disabled => 1,
		test => "send_args =  [ 'smtp_simple', $server1_host ]",
		         send_args => [ 'smtp_simple', $server1_host ]
	},
	{ # 13 works
		# disabled => 1,
		test => "send_args =  [ 'smtp_simple', $server2_host, Port => $server2_port ]",
		         send_args => [ 'smtp_simple', $server2_host, Port => $server2_port ]
	},
	{ # 14 works
		# disabled => 1,
		test => "send_args =  [ 'smtp_simple',  $server2_host:$server2_port ]",
		         send_args => [ 'smtp_simple', "$server2_host:$server2_port" ]
	},
	{ # 15 works
		# disabled => 1,
		test => "send_args =  [ 'smtp_simple', ['server-invalid', $server2_host, 'server-unused'], Port => $server2_port ]",
		         send_args => [ 'smtp_simple', ['server-invalid', $server2_host, 'server-unused'], Port => $server2_port ]
	},
	{ # 16 works
		# disabled => 1,
		test => "send_args =  [ 'smtp_simple', ['server-invalid',  $server2_host:$server2_port , 'server-unused'], ]",
		         send_args => [ 'smtp_simple', ['server-invalid', "$server2_host:$server2_port", 'server-unused'], ]
	},

);

$i = -1;
foreach (@MIMELite) {
	# next; # uncomment to skip MIME::Lite tests
	$i++;
	next if $_->{disabled};
	$_->{name} = sprintf('MIMELite-%02d with %s', $i, delete $_->{test});
	$_->{subject} = 'Log::Dispatch test: ' . $_->{name};
	$_->{to} = $email;
	$_->{min_level} = 'info';
	$log->add(Log::Dispatch::Email::MIMELite->new($_));
}


#################
#
# Log::Dispatch::Email::MailSend
#
# when using smtp: the options will be the same as the constructor for Net::SMTP
# when using smtps: the options will be the same as the constructor for Net::SMTP::SSL
#
# note: we can't prove that the options are working by using smtp with server2 because there is no way to provide auth credentials when using Log::Dispatch::Email::MailSend. Instead we use a custom Hello and later check if it was really used.
#
# note2:
# To see debug messages from Net::SMTP:
# add Debug => 1 to send_args

my @MailSend = (
	{ # 0 works, sent via sendmail
		# disabled => 1,
		test => "no send_args",
	},
	{ # 1 works, sent via sendmail
		# disabled => 1,
		test => "send_args =  [ ]",
		         send_args => [ ],
	},
	{ # 2 works, sent via sendmail
		# disabled => 1,
		test => "send_args =  [ 'sendmail' ]",
		         send_args => [ 'sendmail' ],
	},
	{ # 3 fails: I don't have qmail installed
		# disabled => 1,
		test => "send_args =  [ 'qmail' ]",
		         send_args => [ 'qmail' ],
	},
	{ # 4 fails: no server specified, and doesn't use .libnetrc
		# disabled => 1,
		test => "send_args =  [ 'smtp' ]",
		         send_args => [ 'smtp' ],
	},
	{ # 5 works
		# disabled => 1,
		test => "send_args =  [ 'smtp', Server => $server1_host ]",
		         send_args => [ 'smtp', Server => $server1_host ],
	},
	{ # 6 works, hello sent correctly
		# disabled => 1,
		test => "send_args =  [ 'smtp', Server => $server1_host, Hello => 'banana.net' ]",
		         send_args => [ 'smtp', Server => $server1_host, Hello => 'banana.net' ],
	},
	{ # 7 fails: I'm missing Net::SMTP::SSL and a working smtps server, repeat test after setting it up properly
		# disabled => 1,
		test => "send_args =  [ 'smtps' ]",
		         send_args => [ 'smtps' ],
	},
	{ # 8 fails: I'm missing Net::SMTP::SSL and a working smtps server, repeat test after setting it up properly
		# disabled => 1,
		test => "send_args =  [ 'smtps', Server => $server1_host, Hello => 'cambur.com' ]",
		         send_args => [ 'smtps', Server => $server1_host, Hello => 'cambur.com' ],
	},
	{ # 9 works: result in $PWD/mailer.testfile
		# disabled => 1,
		test => "send_args =  [ 'testfile' ]",
		         send_args => [ 'testfile' ],
	},
);

$i = -1;
foreach (@MailSend) {
	# next; # uncomment to skip MailSend tests
	$i++;
	next if $_->{disabled};
	$_->{name} = sprintf('MailSend-%02d with %s', $i, delete $_->{test});
	$_->{subject} = 'Log::Dispatch test: ' . $_->{name};
	$_->{to} = $email;
	$_->{min_level} = 'info';
	$log->add(Log::Dispatch::Email::MailSend->new($_));
}


#################
#
# Log::Dispatch::Email::MailSendmail
#
# send_args is a hash reference like %Mail::Sendmail::mailcfg
#
# note1: to see debug messages from Mail::Sendmail add debug => x to send_args, where x is the desired level from 0 to 6.
#
# note2: to prove if the options are really used, we add a custom header: X-Test

my @MailSendmail = (
	{ # 0 works, sent to 127.0.0.1 on port 25
		# disabled => 1,
		test => "no send_args",
	},
	{ # 1 fails: must use a hash reference (should I improve my patch to allow arrayrefs?)
		# disabled => 1,
		test => "send_args =  [ ]",
		         send_args => [ ],
	},
	{ # 2 works, sent to 127.0.0.1 on port 25
		# disabled => 1,
		test => "send_args =  { }",
		         send_args => { },
	},
	{ # 3 works
		# disabled => 1,
		test => "send_args =  { smtp => $server1_host }",
		         send_args => { smtp => $server1_host }
	},
	{ # 4 works, X-Test was present
		# disabled => 1,
		test => "send_args =  { smtp => $server1_host, 'X-Test' => 'matute' }",
		         send_args => { smtp => $server1_host, 'X-Test' => 'matute' }
	},
	{ # 5 works, X-Test was present
		# disabled => 1,
		test => "send_args =  { smtp => [ 'badserver1', 'badserver2', $server1_host ], 'X-Test' => 'comejobo' }",
		         send_args => { smtp => [ 'badserver1', 'badserver2', $server1_host ], 'X-Test' => 'comejobo' }
	},
);

$i=-1;
foreach (@MailSendmail) {
	# next; # uncomment to skip Mail::Sendmail tests
	$i++;
	next if $_->{disabled};
	$_->{name} = sprintf('MailSendmail-%02d with %s', $i, delete $_->{test});
	$_->{subject} = 'Log::Dispatch test: ' . $_->{name};
	$_->{to} = $email;
	$_->{min_level} = 'info';
	$log->add(Log::Dispatch::Email::MailSendmail->new($_));
}


################
#
# Log::Dispatch::Email::EmailSend
#

# These tests also verify backward compatibility

# note1:
# Email::Send uses Net::SMTP, but adds the ability to provide authentication
#
# note2:
# To see debug messages add Debug => 1 to send_args

my @EmailSend = (
	{ # 0 works, sent via sendmail
		# disabled => 1,
		test => "no send_args",
	},
	{ # 1 works, sent via sendmail
		# disabled => 1,
		test => "send_args =  [ ]",
		         send_args => [ ],
	},
	{ # 2 works
		# disabled => 1,
		test => "send_args =  [ 'SMTP', Host => $server1_host ]",
		         send_args => [ 'SMTP', Host => $server1_host ]
	},
	{ # 3 fails with Log::Dispatch::Email::EmailSend 0.03 and Email::Send 2.201 Reason: mailer_args are never used.
	  # works with my changes
		# disabled => 1,
		test => "send_args =  [ 'SMTP', Host => $server3_host, Port => $server3_port, username => $server3_user, password => $server3_pass ]",
		         send_args => [ 'SMTP', Host => $server3_host, Port => $server3_port, username => $server3_user, password => $server3_pass ]
	},
	{ # 4 works
		# disabled => 1,
		test => "send_args =  [ 'Sendmail' ]",
		         send_args => [ 'Sendmail' ]
	},
	{ # 5 fails with Log::Dispatch::Email::EmailSend 0.03 and Email::Send 2.201 Reason: mailer_args are never used.
	  # works with my changes
		# disabled => 1,
		test => "mailer = 'SMTP', mailer_args = [ $server3_host, Port => $server3_port, username => $server3_user, password => $server3_pass ]",
		mailer => 'SMTP',
		mailer_args => [ $server3_host, Port => $server3_port, username => $server3_user, password => $server3_pass ],
	},
	{ # 6 works, old api test
		# disabled => 1,
		test => "mailer = 'Sendmail'",
		mailer => 'Sendmail',
	},
	{ # 7 works, old and new mixed up, ends up using smtp
		# disabled => 1,
		test => "mailer = 'Sendmail', send_args = [ 'SMTP', Host => $server3_host, Port => $server3_port, username => $server3_user, password => $server3_pass ]",
		mailer => 'Sendmail',
		send_args => [ 'SMTP', Host => $server3_host, Port => $server3_port, username => $server3_user, password => $server3_pass ],
	},
	{ # 8 old and new mixed up, should use the new one: sendmail
		# works with my changes
		# disabled => 1,
		test => "mailer = 'SMTP', mailer_args = [ $server1_host ], send_args = [ 'Sendmail' ]",
		mailer => 'SMTP',
		mailer_args => [ $server1_host ],
		send_args => [ 'Sendmail' ],
	},
);

$i=-1;
foreach (@EmailSend) {
	# next; # uncomment to skip Email::EmailSend tests
	$i++;
	next if $_->{disabled};
	$_->{name} = sprintf('EmailSend-%02d with %s', $i, delete $_->{test});
	$_->{subject} = 'Log::Dispatch test: ' . $_->{name};
	$_->{to} = $email;
	$_->{min_level} = 'info';
	$log->add(Log::Dispatch::Email::EmailSend->new($_));
}

$log->info("This is a test message from PID: $$ at: " . localtime . "\n");

foreach my $d ( sort { $a->name cmp $b->name } $log->outputs ) {
	print "Dispatching message via $d->{name}\n";
}

exit 0;
