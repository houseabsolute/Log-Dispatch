package Log::Dispatch::Handle;

use strict;

use Log::Dispatch::Output;

use base qw( Log::Dispatch::Output );
use fields qw( handle );

use vars qw[ $VERSION ];

$VERSION = sprintf "%d.%03d", q$Revision: 1.9 $ =~ /: (\d+)\.(\d+)/;

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
    $self->{handle} = $params{handle};

    return $self;
}

sub log
{
    my Log::Dispatch::Handle $self = shift;
    my %params = @_;

    return unless $self->_should_log($params{level});

    $self->{handle}->print($params{message});
}

__END__

=head1 NAME

Log::Dispatch::Handle - Object for logging to IO::Handle objects (and
subclasses thereof)

=head1 SYNOPSIS

  use Log::Dispatch::Handle;

  my $handle = Log::Dispatch::Handle->new( name      => 'a handle',
                                           min_level => 'emerg',
                                           handle    => $io_socket_object );

  $handle->log( level => 'emerg', message => 'I am the Lizard King!' );

=head1 DESCRIPTION

This module supplies a very simple object for logging to some sort of
handle object.  Basically, anything that implements a C<print()>
method can be passed the object constructor and it should work.

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

=item -- handle ($)

The handle object.  This object must implement a C<print()> method.

=item * log( level => $, message => $ )

Sends a message if the level is greater than or equal to the object's
minimum level.

=back

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 SEE ALSO

Log::Dispatch, Log::Dispatch::Email, Log::Dispatch::Email::MailSend,
Log::Dispatch::Email::MailSendmail, Log::Dispatch::Email::MIMELite,
Log::Dispatch::File, Log::Dispatch::Output, Log::Dispatch::Screen,
Log::Dispatch::Syslog

=cut
