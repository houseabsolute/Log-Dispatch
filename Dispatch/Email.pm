package Log::Dispatch::Email;

use strict;

use Log::Dispatch::Output;

use base qw( Log::Dispatch::Output );
use fields qw( buffer buffered from subject to );

use vars qw[ $VERSION ];

$VERSION = sprintf "%d.%03d", q$Revision: 1.11 $ =~ /: (\d+)\.(\d+)/;

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

    $self->{subject} = $params{subject} || "$0: log email";
    $self->{to} = ref $params{to} ? $params{to} : [$params{to}]
	or die "No addresses provided to new method for ", ref $self, " object";
    $self->{from} = $params{from};

    # Default to buffered for obvious reasons!
    $self->{buffered} = exists $params{buffered} ? $params{buffered} : 1;

    $self->{buffer} = [] if $self->{buffered};

    return $self;
}

sub log
{
    my Log::Dispatch::Email $self = shift;
    my %params = @_;

    return unless $self->_should_log($params{level});

    if ($self->{buffered})
    {
	push @{ $self->{buffer} }, $params{message},
    }
    else
    {
	$self->send_email(@_);
    }
}

sub send_email
{
    my $self = shift;
    my $class = ref $self;

    die "The send_email method must be overridden in the $class subclass";
}


sub DESTROY
{
    my Log::Dispatch::Email $self = shift;

    if ($self->{buffered} && @{ $self->{buffer} })
    {
	my $message = join '', @{ $self->{buffer} };

	$self->send_email( message => $message );
    }
}

__END__

=head1 NAME

Log::Dispatch::Email - Base class for objects that send log messages
via email

=head1 SYNOPSIS

  package Log::Dispatch::Email::MySender

  use Log::Dispatch::Email;
  use base qw( Log::Dispatch::Email );

  sub send_email
  {
      my Log::Dispatch::Email::MySender $self = shift;
      my %params = @_;

      # Send email somehow.  Message is in $params{message}
  }

=head1 DESCRIPTION

This module should be used as a base class to implement
Log::Dispatch::* objects that send their log messages via email.
Implementing a subclass simply requires the code shown in the
L<SYNOPSIS> with a real implementation of the C<send_email()> method.

=head1 METHODS

=over 4

=item * new(%PARAMS)

This method takes a hash of parameters.  The following options are
valid:

=item -- name ($)

The name of the object (not the filename!).  Required.

=item -- min_level ($)

The minimum logging level this object will accept.  See the
Log::Dispatch documentation for more information.  Required.

=item -- max_level ($)

The maximum logging level this obejct will accept.  See the
Log::Dispatch documentation for more information.  This is not
required.  By default the maximum is the highest possible level (which
means functionally that the object has no maximum).

=item -- subject ($)

The subject of the email messages which are sent.  Defaults to "$0:
log email"

=item -- to ($ or \@)

Either a string or a list reference of strings containing email
addresses.  Required.

=item -- from ($)

A string containing an email address.  This is optional and may not
work with all mail sending methods.

=item -- buffered (0 or 1)

This determines whether the object sends one email per message it is
given or whether it stores them up and sends them all at once.  The
default is to buffer messages.

=item * log( level => $, message => $ )

Sends a message if the level is greater than or equal to the object's
minimum level.

=item * send_email(%PARAMS)

This is the method that must be subclassed.  For now the only
parameter in the hash is 'message'.

=item * DESTROY

If the object is buffered, then this method will call the
C<send_email()> method to send the contents of the buffer.

=back

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 SEE ALSO

Log::Dispatch, Log::Dispatch::Email::MailSend,
Log::Dispatch::Email::MailSendmail, Log::Dispatch::Email::MIMELite,
Log::Dispatch::File, Log::Dispatch::Handle, Log::Dispatch::Output,
Log::Dispatch::Screen, Log::Dispatch::Syslog

=cut
