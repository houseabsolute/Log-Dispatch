package Log::Dispatch::Base;

use strict;
use vars qw($VERSION @EXPORT_OK);

$VERSION = sprintf "%d.%03d", q$Revision: 1.2 $ =~ /: (\d+)\.(\d+)/;

1;

sub _get_callbacks
{
    shift;
    my %params = @_;

    return unless exists $params{callbacks};

    # If it's not an array ref of some sort its a code ref and this'll
    # cause an error.
    my @cb = eval { @{ $params{callbacks} }; };

    # Must have been a code ref.
    @cb = ($params{callbacks}) unless @cb;

    return @cb;
}

sub _apply_callbacks
{
    my Log::Dispatch $self = shift;
    my %params = @_;

    my $msg = $params{message};
    foreach my $cb ( @{ $self->{callbacks} } )
    {
	$msg = $cb->( message => $msg );
    }

    return $msg;
}

__END__

=head1 NAME

Log::Dispatch::Base - Code shared by dispatch and output objects.

=head1 SYNOPSIS

  use Log::Dispatch::Base;

  ...

  @ISA = qw(Log::Dispatch::Base);

=head1 DESCRIPTION

Unless you are me, you probably don't need to know what this class
does.

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=head1 SEE ALSO

Log::Dispatch, Log::Dispatch::Email, Log::Dispatch::Email::MailSend,
Log::Dispatch::Email::MailSendmail, Log::Dispatch::Email::MIMELite,
Log::Dispatch::Handle, Log::Dispatch::Output, Log::Dispatch::Screen,
Log::Dispatch::Syslog

=cut
