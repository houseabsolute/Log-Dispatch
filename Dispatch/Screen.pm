package Log::Dispatch::Screen;

use strict;

use Log::Dispatch::Output;

use base qw( Log::Dispatch::Output );
use fields qw( stderr );

use vars qw[ $VERSION ];

$VERSION = sprintf "%d.%03d", q$Revision: 1.2 $ =~ /: (\d+)\.(\d+)/;

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
    $self->{stderr} = $params{stderr} if $params{stderr};

    return $self;
}

sub log
{
    my Log::Dispatch::Screen $self = shift;
    my %params = @_;

    return unless $self->_should_log($params{level});

    if ($self->{stderr})
    {
	print STDERR $params{message};
    }
    else
    {
	print $params{message};
    }
}

__END__

=head1 NAME

Log::Dispatch::Screen - Object for logging to the screen

=head1 SYNOPSIS

  use Log::Dispatch::Screen;

  my $screen = Log::Dispatch::Screen->new( name      => 'screen',
                                           min_level => 'debug',
                                           stderr    => 1 );

  $screen->log( level => 'alert', message => "I'm searching the city for sci-fi wasabi\n" );

=head1 DESCRIPTION

This module provides an object for logging to the screen (really
STDOUT or STDERR).

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

=item -- stderr (0 or 1)

Indicates whether or not logging information should go to STDERR.  If
false, logging information is printed to STDOUT instead.  This
defaults to true.

=item * log( level => $, message => $ )

Sends a message if the level is greater than or equal to the object's
minimum level.

=back

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 SEE ALSO

Log::Dispatch, Log::Dispatch::Email, Log::Dispatch::Email::MailSend,
Log::Dispatch::Email::MailSendmail, Log::Dispatch::Email::MIMELite,
Log::Dispatch::File, Log::Dispatch::Handle, Log::Dispatch::Output,
Log::Dispatch::Syslog

=cut
