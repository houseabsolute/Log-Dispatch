package Log::Dispatch::Email::MailSender;

# By: Joseph Annino
# (c) 2002
# Licensed under the same terms as Perl
#

use strict;
use warnings;

use Log::Dispatch::Email;

use base qw( Log::Dispatch::Email );

use Mail::Sender ();

our $VERSION = '1.04';

sub new
{
    my $proto = shift;
    my $class = ref $proto || $proto;

    my %p = @_;

    my $smtp = delete $p{smtp} || 'localhost';

    my $self = $class->SUPER::new(%p);

    $self->{smtp} = $smtp;

    return $self;
}

sub send_email
{
    my $self = shift;
    my %p = @_;

    local $?;
    eval
    {
        my $sender =
            Mail::Sender->new( { from => $self->{from} || 'LogDispatch@foo.bar',
                                 replyto => $self->{from} || 'LogDispatch@foo.bar',
                                 to => ( join ',', @{ $self->{to} } ),
                                 subject => $self->{subject},
                                 smtp => $self->{smtp},
                               } );

        die "Error sending mail ($sender): $Mail::Sender::Error"
            unless ref $sender;

        ref $sender->MailMsg( { msg => $p{message} } )
            or die "Error sending mail: $Mail::Sender::Error";
    };

    warn $@ if $@ && warnings::enabled();
}


1;

__END__

=head1 NAME

Log::Dispatch::Email::MailSender - Subclass of Log::Dispatch::Email that uses the Mail::Sender module

=head1 SYNOPSIS

  use Log::Dispatch::Email::MailSender;

  my $email =
      Log::Dispatch::Email::MailSender->new
          ( name => 'email',
            min_level => 'emerg',
            to => [ qw( foo@bar.com bar@baz.org ) ],
            subject => 'Oh no!!!!!!!!!!!',
            smtp => 'mail.foo.bar' );

  $email->log( message => 'Something bad is happening', level => 'emerg' );

=head1 DESCRIPTION

This is a subclass of Log::Dispatch::Email that implements the
send_email method using the Mail::Sender module.

=head1 AUTHORS

Joseph Annino. <jannino@jannino.com>

Dave Rolsky, <autarch@urth.org>

=cut
