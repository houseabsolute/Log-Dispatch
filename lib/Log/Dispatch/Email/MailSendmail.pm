package Log::Dispatch::Email::MailSendmail;

use strict;
use warnings;

use Log::Dispatch::Email;

use base qw( Log::Dispatch::Email );

use Mail::Sendmail ();

our $VERSION = '1.20';


sub send_email
{
    my $self = shift;
    my %p = @_;

    my %mail = ( To      => (join ',', @{ $self->{to} }),
                 Subject => $self->{subject},
                 Message => $p{message},
                 # Mail::Sendmail insists on having this parameter.
                 From    => $self->{from} || 'LogDispatch@foo.bar',
               );

    local $?;
    unless ( Mail::Sendmail::sendmail(%mail) )
    {
        warn "Error sending mail: $Mail::Sendmail::error" if warnings::enabled();
    }
}


1;

__END__

=head1 NAME

Log::Dispatch::Email::MailSendmail - Subclass of Log::Dispatch::Email that uses the Mail::Sendmail module

=head1 SYNOPSIS

  my $log = Log::Dispatch->new(outputs => ['Email::MailSendmail' => { 
            min_level => 'emerg',
            to => [ qw( foo@bar.com bar@baz.org ) ],
            subject => 'Oh no!!!!!!!!!!!''.
    }]);
  $log->emerg("Something bad is happening");

=head1 DESCRIPTION

This is a subclass of Log::Dispatch::Email that implements the
send_email method using the Mail::Sendmail module.

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=cut
