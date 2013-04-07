package Log::Dispatch::Code;

use strict;
use warnings;

use Log::Dispatch::Output;

use base qw( Log::Dispatch::Output );

use Params::Validate qw(validate CODEREF);
Params::Validate::validation_options( allow_extra => 1 );

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    my %p = validate( @_, { code => CODEREF } );

    my $self = bless {}, $class;

    $self->_basic_init(%p);
    $self->{code} = $p{code};

    return $self;
}

sub log_message {
    my $self = shift;
    my %p    = @_;

    delete $p{name};
    $p{level} = $Log::Dispatch::Util::LevelNames[ $p{level} ];

    $self->{code}->(%p);
}

1;

# ABSTRACT: Object for logging to a subroutine reference

__END__

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
