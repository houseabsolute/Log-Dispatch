package Log::Dispatch::File;

use strict;

use Log::Dispatch::Output;

use base qw( Log::Dispatch::Output );
use fields qw( fh filename );

use vars qw[ $VERSION ];

use IO::File;

$VERSION = sprintf "%d.%03d", q$Revision: 1.13 $ =~ /: (\d+)\.(\d+)/;

# Prevents death later on if IO::File can't export this constant.
BEGIN
{
    my $exists;
    eval { $exists = O_APPEND(); };

    *O_APPEND = \&APPEND unless defined $exists;
}

sub APPEND {;};

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
    $self->_make_handle(%params);

    return $self;
}

sub _make_handle
{
    my Log::Dispatch::File $self = shift;
    my %params = @_;

    $self->{filename} = $params{filename};

    my $mode;
    if ( exists $params{mode}
	 &&
	 ( $params{mode} =~ /^>>$|^append$|/
	   ||
	   $params{mode} == O_APPEND() ) )
    {
	$mode = '>>';
    }
    else
    {
	$mode = '>';
    }

    $self->{fh} = IO::File->new("$mode$self->{filename}")
	or die "Can't write to '$self->{filename}': $!";
    $self->{fh}->autoflush(1);
}

sub log_message
{
    my Log::Dispatch::File $self = shift;
    my %params = @_;

    $self->{fh}->print($params{message});
}

__END__

=head1 NAME

Log::Dispatch::File - Object for logging to files

=head1 SYNOPSIS

  use Log::Dispatch::File;

  my $file = Log::Dispatch::File->new( name      => 'file1',
                                       min_level => 'info',
                                       filename  => 'Somefile.log',
                                       mode      => 'append' );

  $file->log( level => 'emerg', message => "I've fallen and I can't get up\n" );

=head1 DESCRIPTION

This module provides a simple object for logging to files under the
Log::Dispatch::* system.

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

=item -- filename ($)

The filename to be opened for writing.

=item -- mode ($)

The mode the file should be opened with.  Valid options are 'write',
'>', 'append', '>>', or the relevant constants from Fcntl.  The
default is 'write'.

=item -- callbacks( \& or [ \&, \&, ... ] )

This parameter may be a single subroutine reference or an array
reference of subroutine references.  These callbacks will be called in
the order they are given and passed a hash containing the following keys:

 ( message => $log_message )

It's a hash in case I need to add parameters in the future.

The callbacks are expected to modify the message and then return a
single scalar containing that modified message.  These callbacks will
be called when either the C<log> or C<log_to> methods are called and
will only be applied to a given message once.

=item * log_message( message => $ )

Sends a message to the appropriate output.  Generally this shouldn't
be called directly but should be called through the C<log()> method
(in Log::Dispatch::Output).

=back

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 SEE ALSO

Log::Dispatch, Log::Dispatch::ApacheLog, Log::Dispatch::Email,
Log::Dispatch::Email::MailSend, Log::Dispatch::Email::MailSendmail,
Log::Dispatch::Email::MIMELite, Log::Dispatch::Handle,
Log::Dispatch::Output, Log::Dispatch::Screen, Log::Dispatch::Syslog

=cut
