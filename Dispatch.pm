package Log::Dispatch;

require 5.005;

use strict;
use vars qw[ $VERSION ];

use fields qw( outputs );

use Carp ();

$VERSION = sprintf "%d.%03d", q$Revision: 1.9 $ =~ /: (\d+)\.(\d+)/;

1;

sub new
{
    my $proto = shift;
    my $class = ref $proto || $proto;

    my $self;
    {
	no strict 'refs';
	$self = bless [ \%{"${class}::FIELDS"} ], $class;
    }

    return $self;
}

sub add
{
    my Log::Dispatch $self = shift;
    my $object = shift;

    if (exists $self->{outputs}{$object->name} && $^W)
    {
	Carp::carp("Log::Dispatch::* object ", $object->name, " already exists.");
    }

    $self->{outputs}{$object->name} = $object;
}

sub remove
{
    my Log::Dispatch $self = shift;
    my $name = shift;

    return delete $self->{outputs}{$name};
}

sub log
{
    my Log::Dispatch $self = shift;
    my %params = @_;

    foreach (keys %{ $self->{outputs} })
    {
	$params{name} = $_;
	$self->log_to(%params);
    }
}

sub log_to
{
    my Log::Dispatch $self = shift;
    my %params = @_;
    my $name = delete $params{name};

    if (exists $self->{outputs}{$name})
    {
	$self->{outputs}{$name}->log(@_);
    }
    else
    {
	Carp::carp("Log::Dispatch::* object named '$name' not in dispatcher\n");
    }
}

__END__

=head1 NAME

Log::Dispatch - Dispatches messages to multiple Log::Dispatch::* objects

=head1 SYNOPSIS

  use Log::Dispatch;

  my $dispatcher = Log::Dispatch->new;

  $dispatcher->add( Log::Dispatch::File->new( name => 'file1',
                                              min_level => 'debug',
                                              file => 'logfile' ) );

  $dispatcher->log( level => 'info',
                    message => 'Blah, blah' );

=head1 DESCRIPTION

This module manages a set of Log::Dispatch::* objects, allowing you to
add and remove output objects as desired.

=head1 METHODS

=over 4

=item * new

Returns a new Log::Dispatch object.

=item * add(OBJECT)

Adds a new a Log::Dispatch::* object to the dispatcher.  If an object
of the same name already exists, then that object is replaced.  A
warning will be issued if the 'C<-w>' flag is set.

=item * remove($)

Removes the object that matches the name given to the remove method.
The return value is the object being removed or undef if no object
matched this.

=item * log( level => $, message => $ )

Sends the message (at the appropriate level) to all the
Log::Dispatch::* objects that the dispatcher contains (by calling the
C<log_to> method repeatedly).

=item * log_to( name => $, level => $, message => $ )

Sends the message only to the named object.

=back

=head2 Log Levels

The log levels that Log::Dispatch uses are taken directly from the
syslog man pages (except that I expanded them to full words).  Valid
levels are:

 debug
 info
 notice
 warning
 error
 critical
 alert
 emergency

Alternately, the numbers 0 through 7 may be used (debug is 0 and emerg
is 7).  The syslog standard of 'err', 'crit', and 'emerg' are also
acceptable.

=head1 USAGE

This logging system is designed to be used as a one-stop logging
system.  In particular, it was designed to be easy to subclass so that
if you want to handle messaging in a way other than one of the modules
used here, you should be able to implement this with minimal effort.

The basic idea behind Log::Dispatch is that you create a Log::Dispatch
object and then add various logging objects to it (such as a file
logger or screen logger).  Then you call the C<log> method of the
dispatch object, which passes the message to each of the objects,
which in turn decide whether or not to accept the message and what to
do with it.

This makes it possible to call single method and send a message to a
log file, via email, to the screen, and anywhere else all in one
simple command.

The logging levels that Log::Dispatch uses are borrowed from the
standard UNIX syslog levels, except that where syslog uses partial
words ('err') Log::Dispatch also allows the use of the full word as
well ('error').

Please note that because this code uses pseudo-hashes and compile-time
object typing that it will only run under Perl 5.005 or greater.

=head2 Making your own logging objects

Making your own logging object is generally as simple as subclassing
Log::Dispatch::Output and overriding the C<new> and C<log> methods.
See the L<Log::Dispatch::Output> docs for more details.

If you would like to create your own subclass for sending email then
it is even simpler.  Simply subclass L<Log::Dispatch::Email> and
override the C<send_email> method.  See the L<Log::Dispatch::Email>
docs for more details.

You may also want to consider subclassing Log::Dispatch itself.  This
would be a very convenient way of adding a timestamp and process id to
all outgoing messages, for example.  Simply make a subclass that
overrides the C<log> and/or C<log_to> method and have it modify the
message before calling C<SUPER::log>.

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 SEE ALSO

Log::Dispatch::Email, Log::Dispatch::Email::MailSend,
Log::Dispatch::Email::MailSendmail, Log::Dispatch::Email::MIMELite,
Log::Dispatch::File, Log::Dispatch::Handle, Log::Dispatch::Output,
Log::Dispatch::Screen, Log::Dispatch::Syslog

=cut
