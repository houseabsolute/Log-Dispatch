package Log::Dispatch::Syslog;

use strict;

use Log::Dispatch::Output;

use base qw( Log::Dispatch::Output );
use fields qw( ident logopt facility socket priorities );

use Sys::Syslog ();

# This is old school!
require 'syslog.ph';

use vars qw[ $VERSION ];

$VERSION = sprintf "%d.%03d", q$Revision: 1.10 $ =~ /: (\d+)\.(\d+)/;

1;

sub new
{
    my $proto = shift;
    my $class = ref $proto || $proto;

    my %params = @_;

    my $self;
    {
	no strict 'refs';
	$self = bless [ \%{"${class}::FIELDS"} ], $class;
    }

    $self->_basic_init(%params);
    $self->_init(%params);

    return $self;
}

sub _init
{
    my Log::Dispatch::Syslog $self = shift;
    my %params = @_;

    $self->{ident}    = $params{ident} || $0;
    $self->{logopt}   = $params{logopt} || '';
    $self->{facility} = $params{facility} || 'user';
    $self->{socket}   = $params{socket} || 'unix';

    $self->{priorities} = [ 'DEBUG',
			    'INFO',
			    'NOTICE',
			    'WARNING',
			    'ERR',
			    'CRIT',
			    'ALERT',
			    'EMERG' ];

    Sys::Syslog::setlogsock $self->{socket};
}

sub log
{
    my Log::Dispatch::Syslog $self = shift;
    my %params = @_;

    return unless $self->_should_log($params{level});

    my $pri = $self->_level_as_number($params{level});

    Sys::Syslog::openlog($self->{ident}, $self->{logopt}, $self->{facility});
    Sys::Syslog::syslog($self->{priorities}[$pri], '%s', $params{message});
    Sys::Syslog::closelog;
}

__END__

=head1 NAME

Log::Dispatch::Syslog - Object for logging to system log.

=head1 SYNOPSIS

  use Log::Dispatch::Syslog;

  my $file = Log::Dispatch::Syslog->new( name      => 'file1',
                                         min_level => 'info',
                                         ident     => 'Yadda yadda' );

  $file->log( level => 'emerg', message => "Time to die." );

=head1 DESCRIPTION

This module provides a simple object for sending messages to the
system log (via UNIX syslog calls).

=head1 METHODS

=over 4

=item * new(%PARAMS)

This method takes a hash of parameters.  The following options are
valid:

=item -- name ($)

The name of the object.  Required.

=item -- min_level ($)

The minimum logging level this object will accept.  See the
Log::Dispatch documentation for more information.  Required.

=item -- max_level ($)

The maximum logging level this obejct will accept.  See the
Log::Dispatch documentation for more information.  This is not
required.  By default the maximum is the highest possible level (which
means functionally that the object has no maximum).

=item -- ident ($)

This string will be prepended to all messages in the system log.
Defaults to $0.

=item -- logopt ($)

A string containing the log options (separated by any separator you
like).  Valid options are 'cons', 'pid', 'ndelay', and 'nowait'.  See
the openlog(3) and Sys::Syslog docs for more details.  I would suggest
not using 'cons' but instead using Log::Dispatch::Screen.  Defaults to
''.

=item -- facility ($)

Specifies what type of program is doing the logging to the system log.
Valid options are 'auth', 'authpriv', 'cron', 'daemon', 'kern',
'local0' through 'local7', 'mail, 'news', 'syslog', 'user',
'uucp'.  Defaults to 'user'

=item -- socket ($)

Tells what type of socket to use for sending syslog messages.  Valid
options are 'unix' or 'inet'.  Defaults to 'inet'.

=back

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 SEE ALSO

Log::Dispatch, Log::Dispatch::Email, Log::Dispatch::Email::MailSend,
Log::Dispatch::Email::MailSendmail, Log::Dispatch::Email::MIMELite,
Log::Dispatch::File, Log::Dispatch::Handle, Log::Dispatch::Output,
Log::Dispatch::Screen

=cut
