package Log::Dispatch::Code;

use strict;
use warnings;

our $VERSION = '2.62';

use Log::Dispatch::Types;
use Params::ValidationCompiler qw( validation_for );

use base qw( Log::Dispatch::Output );

{
    my $validator = validation_for(
        params => { code => { type => t('CodeRef') } },
        slurpy => 1,
    );

    sub new {
        my $class = shift;

        my %p = $validator->(@_);

        my $self = bless { code => delete $p{code} }, $class;
        $self->_basic_init(%p);

        return $self;
    }
}

sub log_message {
    my $self = shift;
    my %p    = @_;

    delete $p{name};

    $self->{code}->(%p);
}

1;

# ABSTRACT: Object for logging to a subroutine reference

__END__

=for Pod::Coverage new log_message

=head1 SYNOPSIS

  use Log::Dispatch;

  my $log = Log::Dispatch->new(
      outputs => [
          [
              'Code',
              min_level => 'emerg',
              code      => \&_log_it,
          ],
      ]
  );

  sub _log_it {
      my %p = @_;

      warn $p{message};
  }

=head1 DESCRIPTION

This module supplies a simple object for logging to a subroutine reference.

=head1 CONSTRUCTOR

The constructor takes the following parameters in addition to the standard
parameters documented in L<Log::Dispatch::Output>:

=over 4

=item * code ($)

The subroutine reference.

=back

=head1 HOW IT WORKS

The subroutine you provide will be called with a hash of named arguments. The
two arguments are:

=over 4

=item * level

The log level of the message. This will be a string like "info" or "error".

=item * message

The message being logged.

=back

=cut
