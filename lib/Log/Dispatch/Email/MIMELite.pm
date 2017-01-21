package Log::Dispatch::Email::MIMELite;

use strict;
use warnings;

our $VERSION = '2.59';

use Log::Dispatch::Email;

use base qw( Log::Dispatch::Email );

use MIME::Lite;

sub send_email {
    my $self = shift;
    my %p    = @_;

    my %mail = (
        To      => ( join ',', @{ $self->{to} } ),
        Subject => $self->{subject},
        Type    => 'TEXT',
        Data    => $p{message},
    );

    $mail{From} = $self->{from} if defined $self->{from};

    warn "Error sending mail with MIME::Lite" unless
        do {
            local $?;
            if (defined $self->{send_args} && @{$self->{send_args}} > 0 ) {
                my @args = @{$self->{send_args}};
                if ( @args >= 3 ) {
                    MIME::Lite->new(%mail)->send( $args[0], $args[1], @args[2 .. $#args] );
                } elsif ( @args == 2 ) {
                    MIME::Lite->new(%mail)->send( $args[0], $args[1] );
                } else {
                    MIME::Lite->new(%mail)->send( $args[0] );
                }
            } else {
                MIME::Lite->new(%mail)->send;
            }
        };

}

1;

# ABSTRACT: Subclass of Log::Dispatch::Email that uses the MIME::Lite module

__END__

=head1 SYNOPSIS

  use Log::Dispatch;

  my $log = Log::Dispatch->new(
      outputs => [
          [
              'Email::MIMELite',
              min_level => 'emerg',
              to        => [qw( foo@example.com bar@example.org )],
              subject   => 'Big error!',
              send_args => [ 'smtp', 'smtp.example.org', { AuthUser => 'john', AuthPass => 'secret' } ]
          ]
      ],
  );

  $log->emerg("Something bad is happening");

=head1 DESCRIPTION

This is a subclass of L<Log::Dispatch::Email> that implements the
send_email method using the L<MIME::Lite> module.

=head1 CHANGING HOW MAIL IS SENT

To change how mail is sent, set send_args to according to what
L<< MIME::Lite->send >> expects.

=cut
