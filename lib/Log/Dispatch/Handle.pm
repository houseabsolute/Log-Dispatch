package Log::Dispatch::Handle;

use strict;
use warnings;

our $VERSION = '2.60';

use Log::Dispatch::Types;
use Params::ValidationCompiler qw( validation_for );

use base qw( Log::Dispatch::Output );

{
    my $validator = validation_for(
        params => { handle => { type => t('CanPrint') } },
        slurpy => 1,
    );

    sub new {
        my $class = shift;
        my %p     = $validator->(@_);

        my $self = bless { handle => delete $p{handle} }, $class;
        $self->_basic_init(%p);

        return $self;
    }
}

sub log_message {
    my $self = shift;
    my %p    = @_;

    $self->{handle}->print( $p{message} )
        or die "Cannot write to handle: $!";
}

1;

# ABSTRACT: Object for logging to IO::Handle classes

__END__

=for Pod::Coverage new log_message

=head1 SYNOPSIS

  use Log::Dispatch;

  my $log = Log::Dispatch->new(
      outputs => [
          [
              'Handle',
              min_level => 'emerg',
              handle    => $io_socket_object,
          ],
      ]
  );

  $log->emerg('I am the Lizard King!');

=head1 DESCRIPTION

This module supplies a very simple object for logging to some sort of
handle object. Basically, anything that implements a C<print()>
method can be passed the object constructor and it should work.

=head1 CONSTRUCTOR

The constructor takes the following parameters in addition to the standard
parameters documented in L<Log::Dispatch::Output>:

=over 4

=item * handle ($)

The handle object. This object must implement a C<print()> method.

=back

=cut
