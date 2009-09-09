package Log::Dispatch::Email::MIMELite;

use strict;
use warnings;

use Log::Dispatch::Email;

use base qw( Log::Dispatch::Email );

use MIME::Lite;

our $VERSION = '1.19';


sub send_email
{
    my $self = shift;
    my %p = @_;

    my %mail = ( To      => (join ',', @{ $self->{to} }),
                 Subject => $self->{subject},
                 Type    => 'TEXT',
                 Data    => $p{message},
               );

    $mail{From} = $self->{from} if defined $self->{from};

    local $?;
    unless ( MIME::Lite->new(%mail)->send )
    {
        warn "Error sending mail with MIME::Lite" if warnings::enabled();
    }
}


1;

__END__

=head1 NAME

Log::Dispatch::Email::MIMELite - Subclass of Log::Dispatch::Email that uses the MIME::Lite module

=head1 SYNOPSIS

  my $log = Log::Dispatch->new(outputs => ['Email::MIMELite' => { 
            min_level => 'emerg',
            to => [ qw( foo@bar.com bar@baz.org ) ],
            subject => 'Oh no!!!!!!!!!!!''.
    }]);
  $log->emerg("Something bad is happening");

=head1 DESCRIPTION

This is a subclass of L<Log::Dispatch::Email|Log::Dispatch::Email> that implements the
send_email method using the MIME::Lite module.

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=cut
